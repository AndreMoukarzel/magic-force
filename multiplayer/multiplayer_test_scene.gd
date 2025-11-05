extends Node3D


var PLAYER_SCN := preload("res://multiplayer/players/multiplayer_player.tscn")

func _ready() -> void:
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	#if not multiplayer.is_server():
		#multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	if not OS.has_feature("dedicated_server"):
		_add_player(multiplayer.get_unique_id())


func _add_player(id: int) -> void:
	if not multiplayer.is_server():
		# Only the server spawns the players
		# Clients are updated by signals from the MultiplayerSpawner and RPCs
		return
	print("Player %s joined the game!" % id)
	
	var player_to_add = PLAYER_SCN.instantiate()
	#var player_team: String = "A"
	player_to_add.PLAYER_ID = id
	player_to_add.name = str(id)
	#player_to_add.TEAM = player_team
	
	$Players.add_child(player_to_add, true)
	
	#add_player_label(id, str(id), player_team)
	
	# Signals the new player that it was added, so it can add its own copies of Player Labels
	#if id != multiplayer.get_unique_id():
	#	_add_all_player_labels.rpc_id(id)


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
