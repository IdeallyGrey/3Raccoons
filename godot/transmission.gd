extends RichTextLabel



func _process(delta):
	match GlobalVars.gear:
		-1: text = "R"
		0: text = "P"
		_: text = str(GlobalVars.gear)
	
	
