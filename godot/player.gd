extends CharacterBody3D

@onready var animated_sprite_2d = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var ray_cast_3d = $RayCast3D
@onready var shoot_sound = $ShootSound




const MAX_SPEED = 25
var acceleration = 0.3
var speed = 0
var steering = 0
var forward = 1 # 1 mean forward, -1 means reverse
var direction = Vector3.ZERO
const MOUSE_SENS = 0.2
# add grav
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


var can_shoot = true
var dead = false

func _ready():

	#set_floor_max_angle(1.047198)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animated_sprite_2d.animation_finished.connect(shoot_anim_done)
	$CanvasLayer/DeathScreen/Panel/Button.button_up.connect(restart)

func _input(event):
	if dead:
		return

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		restart()


	if dead:
		return
	if Input.is_action_just_pressed("shoot"):
		shoot()



func _physics_process(delta):
	if dead:
		return

	# add grav
	if not is_on_floor():
		velocity.y -= gravity * delta

	if (transform.basis * Vector3(rotation_degrees.z, 0, -1)).normalized(): # cursed, returns true if Vector is not (0,0,0)
		direction = (transform.basis * Vector3(rotation_degrees.z, 0, -1 * forward)).normalized()
	
	if Input.is_action_just_pressed("shoot"):
		forward = forward * -1
	
	if Input.is_action_pressed("move_forwards"):
		acceleration = 0.125 # hitting the gas
	elif Input.is_action_pressed("move_backwards"):
		acceleration = -0.2 # hit the brakes!
	else:
		acceleration = -0.075 # coasting 
	
	speed = clamp(speed + acceleration, 0, MAX_SPEED)
	
	if Input.is_action_pressed("move_left"):
		steering = steering - 0.02
	elif Input.is_action_pressed("move_right"):
		steering = steering + 0.02
	else:
		steering = move_toward(steering, 0, 0.00001) 
	
	steering = clamp(steering, -1.5, 1.5)
	
	rotation_degrees.y = rotation_degrees.y - steering * speed * 0.05 * forward
	
	GlobalVars.speed = speed
	GlobalVars.steering = steering
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()



func restart():
	get_tree().reload_current_scene()

func shoot():
	if !can_shoot:
		return
	can_shoot = false
	animated_sprite_2d.play("shoot")
	shoot_sound.play()
	if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("kill"):
		ray_cast_3d.get_collider().kill()

func shoot_anim_done():
	can_shoot = true

func kill():
	dead = true
	$CanvasLayer/DeathScreen.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
