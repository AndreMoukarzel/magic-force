extends Node3D


var PLAYER_SCN := preload("res://multiplayer/players/multiplayer_player.tscn")
var GAME_HAS_STARTED: bool = false


func _ready() -> void:
	multiplayer.peer_disconnected.connect(_remove_player)
	
	if multiplayer.is_server():
		for player_id in Network.PLAYER_TEAMS:
			var player_team: String = Network.PLAYER_TEAMS[player_id]
			
			print("Adding player %s in Team %s" % [player_id, player_team])
			add_player_mage(int(player_id), player_team) # Adds player to server
			# The player will be automatically added to Clients by the MultiplayerSpawner
			
			if int(player_id) != multiplayer.get_unique_id(): # Syncs players with themselves
				_set_name_and_camera.rpc_id(int(player_id), player_id, player_team)


@rpc
func _set_name_and_camera(player_name, player_team) -> void:
	print(
		"\t[%s] Syncing %s | Team: %s" %
		[str(multiplayer.get_unique_id()), player_name, player_team]
	)
	$Players.get_node(str(player_name)).TEAM = player_team
	$Players.get_node(str(player_name)).set_player_id(int(player_name))
	# Set camera correctly of this player
	$Players.get_node(str(player_name)).get_node("CameraSpring/Camera3D").make_current()
	# Gives the Player authority over themselves
	$Players.get_node(str(player_name)).set_multiplayer_authority(int(player_name))


func add_player_mage(player_id: int, team: String) -> void:
	## Adds PlayerLabel object to specified Team's Members Panel
	var NewPlayer := PLAYER_SCN.instantiate()
	NewPlayer.name = str(player_id)
	NewPlayer.TEAM = team
	NewPlayer.global_position = Vector3(0, 30.0, 0)
	
	NewPlayer.set_player_id(player_id)
	
	$Players.add_child(NewPlayer, true)
	# Relinquishes the Server from having authority over other players
	NewPlayer.set_multiplayer_authority(player_id)


func _remove_player(id: int) -> void:
	print("Player %s left the game!" % id)
	if not $Players.has_node(str(id)):
		return
	
	var PlayerNode: Node = $Players.get_node(str(id))
	PlayerNode.queue_free()
