extends "res://player/simple_camera.gd"


func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventMouseMotion:
			rotation.y -= event.relative.x * SENS
			rotation.y = wrapf(rotation.y, 0.0, TAU)
			rotation.x -= event.relative.y * SENS
			rotation.x = clamp(rotation.x, MIN_V_ANGLE, MAX_V_ANGLE)
		
		if event.is_action_pressed("open_menu"):
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
