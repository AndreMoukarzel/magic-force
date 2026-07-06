extends Node3D


var PLAYER_SCN := preload("res://multiplayer/players/multiplayer_player.tscn")
var GAME_HAS_STARTED: bool = false


func _ready() -> void:
	multiplayer.peer_disconnected.connect(_remove_player)
	
	if multiplayer.is_server():
		_create_all_player_characters(multiplayer.get_unique_id())
		_set_players_authority()


func _create_all_player_characters(server_id: int) -> void:
	for player_id in Network.PLAYER_TEAMS:
		var player_team: String = Network.PLAYER_TEAMS[player_id]
		
		print("Adding player %s in Team %s" % [player_id, player_team])
		add_player_mage(int(player_id), player_team) # Adds player to server
		# The player will be automatically added to Clients by the MultiplayerSpawner
		
		if int(player_id) != server_id:
			# Syncs players with themselves
				_set_name_and_camera.rpc_id(int(player_id), player_id, player_team)


func _set_players_authority() -> void:
	## Relinquishes the Server from having authority over other players
	for Player in $Players.get_children():
		_set_authority_to_client.rpc(int(Player.name))


func add_player_mage(player_id: int, team: String) -> void:
	## Adds PlayerLabel object to specified Team's Members Panel
	var NewPlayer := PLAYER_SCN.instantiate()
	NewPlayer.name = str(player_id)
	NewPlayer.TEAM = team
	$GameHandler/SpawnHandler.spawn_player(NewPlayer, team)
	
	NewPlayer.set_player_id(player_id)
	
	$Players.add_child(NewPlayer, true)
	NewPlayer.set_color_per_team()


func _remove_player(id: int) -> void:
	print("Player %s left the game!" % id)
	if not $Players.has_node(str(id)):
		return
	
	var PlayerNode: Node = $Players.get_node(str(id))
	PlayerNode.queue_free()


@rpc
func _set_name_and_camera(player_name, player_team) -> void:
	print(
		"\t[%s] Syncing %s | Team: %s" %
		[str(multiplayer.get_unique_id()), player_name, player_team]
	)
	var ThisPlayer: Node3D = $Players.get_node(str(player_name))
	ThisPlayer.TEAM = player_team
	ThisPlayer.set_player_id(int(player_name))
	ThisPlayer.set_color_per_team()
	# Set camera correctly of this player
	ThisPlayer.get_node("CameraSpring/Camera3D").make_current()


@rpc("call_local")
func _set_authority_to_client(player_id: int) -> void:
	## Relinquishes the Server from having authority over other players
	var Player = $Players.get_node(str(player_id))
	if Player.TEAM == "B":
		Player.get_node("CameraSpring").global_rotation = Vector3(0.0, deg_to_rad(180.0), 0.0)
	Player.set_multiplayer_authority(player_id)


@rpc("call_local")
func back_to_lobby() -> void:
	Network.leave_lobby()
	multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file("res://lobby/starting_menu.tscn")


func _on_point_handler_victory(winner_team: String) -> void:
	$GameHandler/SpawnHandler/GoalRespawnTimer.set_paused(true)
	$BackToLobby.start()
	await $BackToLobby.timeout
	if multiplayer.is_server():
		back_to_lobby.rpc()


func _on_point_handler_brasil() -> void:
	$CapySpawner.spawn_many_capys.rpc(50)


func _on_spawn_handler_respawn() -> void:
	$CapySpawner.clean_capys.rpc()


func _on_point_handler_match_draw() -> void:
	$GameHandler/SpawnHandler/GoalRespawnTimer.set_paused(true)
	$BackToLobby.start()
	await $BackToLobby.timeout
	if multiplayer.is_server():
		back_to_lobby.rpc()
