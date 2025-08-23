extends RigidBody3D


@export var HIGHLIGHT: Material
@export var XRAY: Material


func _ready() -> void:
	highlight_off()

func highlight_on():
	$MeshInstance3D.material_overlay = HIGHLIGHT

func highlight_off():
	$MeshInstance3D.material_overlay = XRAY

func clear_momentum() -> void:
	linear_velocity = Vector3(0, 0, 0)
