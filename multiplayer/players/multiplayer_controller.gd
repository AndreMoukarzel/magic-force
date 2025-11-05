extends "res://entity/player_controller.gd"

var PLAYER_ID: int = 1:
	set(id):
		PLAYER_ID = id
		#%InputSynchronizer.set_multiplayer_authority(id)


func _ready():
	if multiplayer.get_unique_id() == PLAYER_ID:
		$CameraSpring/Camera3D.make_current()
	else:
		$CameraSpring/Camera3D.enabled = false
