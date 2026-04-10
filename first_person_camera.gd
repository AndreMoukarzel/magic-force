extends Node3D


var DIR: Vector3 = Vector3()
var SENS: float = 0.12
@onready var CAM :SpringArm3D = $SpringArm3D
@onready var CHAR: CharacterBody3D = $".."
@onready var HAND: Node3D = $SpringArm3D/Camera3D/Hand

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta):
	CAM.rotation_degrees.x = DIR.x
	CHAR.rotation_degrees.y = DIR.y

func _input(event):
	if event is InputEventMouseMotion:
		DIR.y -= event.relative.x * SENS
		#DIR.y = wrapf(DIR.y, 0.0, TAU)
		DIR.x -= event.relative.y * SENS
		DIR.x = clamp(DIR.x, -PI/2, PI/4)
	
	if event.is_action_pressed("primary_action"):
		$ForceGrab.grab()
	elif event.is_action_released("primary_action"):
		$ForceGrab.release()
	
	if event.is_action_pressed("secondary_action"):
		$ForcePush.area_push()
