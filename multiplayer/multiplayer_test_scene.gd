extends Node3D


var PLAYER_SCN := preload("res://multiplayer/players/multiplayer_player.tscn")
var GAME_HAS_STARTED: bool = false


func _ready() -> void:
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	#if not multiplayer.is_server():
	#	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	if multiplayer.is_server():
		for player in Network.PLAYER_TEAMS:
			_add_player(int(player))
	
	#if not OS.has_feature("dedicated_server"):
	#	_add_player(multiplayer.get_unique_id())


func _add_player(id: int) -> void:
	if not multiplayer.is_server():
		# Only the server spawns the players
		# Clients are updated by signals from the MultiplayerSpawner and RPCs
		return
	print("Player %s joined the game!" % id)
	
	var player_team: String = Network.PLAYER_TEAMS[str(id)]
	add_player_mage(id, str(id), player_team)
	
	# Signals the new player that it was added, so it can add its own copies of Player Labels
	if id != multiplayer.get_unique_id():
		_add_all_player_in_client.rpc_id(id)
		if player_team != "A":
			change_team.rpc(id)


@rpc
func _add_all_player_in_client() -> void:
	## Clients create all labels of active existing Players
	print("Spawining Players in client")
	for Player in $Players.get_children():
		print(Player.name)
		add_player_mage(int(Player.name), Player.name, Player.TEAM)


func add_player_mage(player_id: int, player_name: String, team: String) -> void:
	## Adds PlayerLabel object to specified Team's Members Panel
	var NewPlayer := PLAYER_SCN.instantiate()
	NewPlayer.name = player_name
	NewPlayer.TEAM = team
	NewPlayer.global_position = Vector3(0, 30.0, 0)
	
	NewPlayer.set_player_id(player_id)
	
	$Players.add_child(NewPlayer, true)


@rpc("any_peer", "call_local")
func change_team(player_id: int) -> void:
	var Player = $Players.get_node(str(player_id))
	
	if Player == null:
		return
	
	var team: String = Player.TEAM
	#var player_label: PlayerLabel = %TeamDisplay.find_player_label(Player)
	
	#if PlayerLabel == null:
	#	return
	
	#if team == "A":
	#	player_label.reparent(%TeamBMembers)
	#	Player.TEAM = "B"
	#else:
	#	player_label.reparent(%TeamAMembers)
	#	Player.TEAM = "A"


func _remove_player(id: int) -> void:
	print("Player %s left the game!" % id)
	if not $Players.has_node(str(id)):
		return
	
	var PlayerNode: Node = $Players.get_node(str(id))
	#remove_player_label.rpc(PlayerNode)
	PlayerNode.queue_free()
	
	#update_start_state()


func _on_multiplayer_spawner_spawned(node: Node) -> void:
	print(node.name)
