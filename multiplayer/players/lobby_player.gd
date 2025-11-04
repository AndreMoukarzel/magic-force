extends Node


# Properties must be exported to be synced
@export var PLAYER_ID: int = 1
@export var TEAM: String = "A"
@export var READY: bool = false


func set_player_id(id: int) -> void:
	PLAYER_ID = id


func _enter_tree() -> void:
	var owner_id = name.to_int()
	set_multiplayer_authority(owner_id)
