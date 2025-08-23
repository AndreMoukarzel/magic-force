extends Node3D


var DIR: Vector3 = Vector3()
var SENS: float = 0.12
@onready var CAM :Camera3D = $Camera3D
@onready var CHAR: CharacterBody3D = $".."
@onready var RAYCAST: RayCast3D = $Camera3D/RayCast3D
@onready var HAND: Node3D = $Camera3D/Hand

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	RAYCAST.add_exception(CHAR)

func _process(_delta):
	CAM.rotation_degrees.x = DIR.x
	CHAR.rotation_degrees.y = DIR.y

func _input(event):
	if event is InputEventMouseMotion:
		DIR.y -= event.relative.x * SENS
		DIR.x -= event.relative.y * SENS
		DIR.x = clamp(DIR.x, -80, 90)
	if event.is_action_pressed("primary_action"):
		$ForceGrab.grab()
	elif event.is_action_released("primary_action"):
		$ForceGrab.release()
	
	if event.is_action_pressed("secondary_action"):
		$ForcePush.area_push()
