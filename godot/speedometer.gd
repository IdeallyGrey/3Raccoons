extends ColorRect


# -50 50
# y = mx +b
# 0, -50
# 25, 50
# y = 4x - 50
#
#

func _process(delta):
	rotation_degrees = 4 * GlobalVars.speed - 50
	
	
