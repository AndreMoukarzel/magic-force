extends SpringArm3D


@export var SENS: float = 0.005
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var MIN_V_ANGLE: float = -PI/2
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var MAX_V_ANGLE: float = PI/4


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
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
