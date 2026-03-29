extends Control


var PLAYER_SCN := preload("res://multiplayer/players/lobby_player.tscn")
var PLAYER_LABEL_SCN := preload("res://lobby/player_label.tscn")


func _ready() -> void:
	multiplayer.peer_connected.connect(_add_lobby_player)
	multiplayer.peer_disconnected.connect(_remove_lobby_player)
	if not multiplayer.is_server():
		multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	if not OS.has_feature("dedicated_server"):
		_add_lobby_player(multiplayer.get_unique_id())
	
	%LobbyId.text = "Session ID: " + str(Network.LOBBY_ID)


func _add_lobby_player(id: int) -> void:
	if not multiplayer.is_server():
		# Only the server spawns the players
		# Clients are updated by signals from the MultiplayerSpawner and RPCs
		return
	print("Player %s joined the game!" % id)
	
	var player_to_add = PLAYER_SCN.instantiate()
	var player_team: String = %TeamDisplay.get_less_populous_team()
	player_to_add.set_player_id(id)
	player_to_add.name = str(id)
	
	$Players.add_child(player_to_add, true)
	
	add_player_label(id, str(id), "A")
	
	# Signals the new player that it was added, so it can add its own copies of Player Labels
	if id != multiplayer.get_unique_id():
		_add_all_player_labels.rpc_id(id)
		if player_team != "A":
			change_team.rpc(id)


func _remove_lobby_player(id: int) -> void:
	print("Player %s left the game!" % id)
	if not $Players.has_node(str(id)):
		return
	
	var PlayerNode: Node = $Players.get_node(str(id))
	remove_player_label.rpc(PlayerNode)
	PlayerNode.queue_free()
	
	update_start_state()


@rpc("call_local")
func remove_player_label(Player: Node) -> void:
	var player_label: PlayerLabel = %TeamDisplay.find_player_label(Player)
	
	if PlayerLabel == null:
		return
	
	player_label.queue_free()


@rpc
func _add_all_player_labels() -> void:
	## Clients create all labels of active existing Players
	for Player in $Players.get_children():
		add_player_label(int(Player.name), Player.name, Player.TEAM, Player.READY)


func add_player_label(player_id: int, player_name: String, team: String, is_ready: bool=false) -> void:
	var NewLabel := PLAYER_LABEL_SCN.instantiate()
	NewLabel.name = str(player_id)
	NewLabel.set_player_name(player_name)
	if is_ready:
		NewLabel.toggle_player_ready()
	
	if team == "A":
		%TeamAMembers.add_child(NewLabel, true)
	elif team == "B":
		%TeamBMembers.add_child(NewLabel, true)


@rpc("any_peer", "call_local")
func change_team(player_id: int) -> void:
	var Player = $Players.get_node(str(player_id))
	
	if Player == null:
		return
	
	var team: String = Player.TEAM
	var player_label: PlayerLabel = %TeamDisplay.find_player_label(Player)
	
	if PlayerLabel == null:
		return
	
	if team == "A":
		player_label.reparent(%TeamBMembers)
		Player.TEAM = "B"
	else:
		player_label.reparent(%TeamAMembers)
		Player.TEAM = "A"


@rpc("any_peer", "call_local")
func get_ready(player_id: int) -> void:
	var Player = $Players.get_node(str(player_id))
	
	if Player == null:
		return
	
	Player.READY = not Player.READY
	var player_label: PlayerLabel = %TeamDisplay.find_player_label(Player)
	player_label.toggle_player_ready()
	
	update_start_state()


@rpc("call_local")
func start_game_to_all() -> void:
	if multiplayer.is_server():
		pass
	
	get_tree().change_scene_to_file("res://arenas/multiplayer_test_scene.tscn")


func get_all_players_info() -> Array:
	## Returns a list with information from all connected players
	var players = []
	for Player in $Players.get_children():
		players.append([Player.name, Player.TEAM, Player.READY])
	return players


func all_players_are_ready() -> bool:
	for Player in $Players.get_children():
		if not Player.READY:
			return false
	return true


func update_change_state() -> void:
	## Updates the state of the ChangeTeam Button based on this Player's state
	var player_id: int = multiplayer.get_unique_id()
	var Player = $Players.get_node(str(player_id))
	
	%ChangeTeam.disabled = Player.READY


func update_start_state() -> void:
	## Updates the state of the Start Button based on the Players' states
	if multiplayer.is_server() and all_players_are_ready():
		# Must be server and all Players must be ready
		if %TeamAMembers.get_child_count() > 0 and %TeamBMembers.get_child_count() > 0:
			# Must have Players in both Teams
			%Start.disabled= false
	else:
		%Start.disabled= true


func _on_change_team_pressed() -> void:
	var player_id: int = multiplayer.get_unique_id()
	change_team.rpc(player_id)


func _on_ready_pressed() -> void:
	var player_id: int = multiplayer.get_unique_id()
	get_ready.rpc(player_id)
	
	update_change_state()


func _on_start_pressed() -> void:
	if multiplayer.is_server():
		start_game_to_all.rpc()


func _on_server_disconnected() -> void:
	print("Server lost")
	if get_tree():
		get_tree().change_scene_to_file("res://lobby/starting_menu.tscn")


func _on_exit_pressed() -> void:
	Network.leave_lobby()
	multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file("res://lobby/starting_menu.tscn")
