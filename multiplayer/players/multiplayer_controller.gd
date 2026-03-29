extends "res://entity/player_controller.gd"


# Properties must be exported to be synced
@export var PLAYER_ID: int = 1
@export var TEAM: String = "A"


func set_player_id(id: int) -> void:
	PLAYER_ID = id
	$Label3D.text = str(id)


func _enter_tree() -> void:
	var owner_id = name.to_int()
	set_multiplayer_authority(owner_id)


func _ready():
	if multiplayer.get_unique_id() == PLAYER_ID:
		$CameraSpring/Camera3D.make_current()
	else:
		$CameraSpring/Camera3D.current = false
