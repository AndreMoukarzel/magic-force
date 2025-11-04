extends Control


var PLAYER_SCN := preload("res://multiplayer/players/lobby_player.tscn")


func _ready() -> void:
	multiplayer.peer_connected.connect(_add_lobby_player)
	multiplayer.peer_disconnected.connect(_remove_lobby_player)
	
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
	var player_team: String = "A"
	player_to_add.set_player_id(id)
	player_to_add.name = str(id)
	player_to_add.TEAM = player_team
	
	$Players.add_child(player_to_add, true)
	
	add_player_label(id, str(id), player_team)
	
	# Signals the new player that it was added, so it can add its own copies of Player Labels
	if id != multiplayer.get_unique_id():
		_add_all_player_labels.rpc_id(id)


func _remove_lobby_player(id: int) -> void:
	print("Player %s left the game!" % id)
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()


@rpc
func _add_all_player_labels() -> void:
	for Player in $Players.get_children():
		add_player_label(int(Player.name), Player.name, Player.TEAM)


func add_player_label(player_id: int, player_name: String, team: String) -> void:
	var NewLabel: Label = Label.new()
	NewLabel.name = str(player_id)
	NewLabel.text = player_name
	
	if team == "A":
		%TeamAMembers.add_child(NewLabel, true)
	elif team == "B":
		%TeamBMembers.add_child(NewLabel, true)


func find_player_display(Player) -> Label:
	## Finds the equivalent player node inside of Player display
	var TeamMembers = %TeamAMembers
	if Player.TEAM == "B":
		TeamMembers = %TeamBMembers
	
	for player_label in TeamMembers.get_children():
		if player_label.name == str(Player.name):
			return player_label
	return null


@rpc("any_peer", "call_local")
func change_team(player_id: int) -> void:
	var Player = $Players.get_node(str(player_id))
	
	if Player == null:
		return
	
	var team: String = Player.TEAM
	var PlayerLabel: Label = find_player_display(Player)
	
	if not multiplayer.is_server():
		print("ID: ", player_id)
		print("Team: ", team)
	
	if PlayerLabel == null:
		return
	
	if team == "A":
		PlayerLabel.reparent(%TeamBMembers)
		Player.TEAM = "B"
	else:
		PlayerLabel.reparent(%TeamAMembers)
		Player.TEAM = "A"


func _on_change_team_pressed() -> void:
	var player_id: int = multiplayer.get_unique_id()
	change_team.rpc(player_id)


func _on_ready_pressed() -> void:
	pass # Replace with function body.


func _on_start_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	Network.leave_lobby()
	get_tree().change_scene_to_file("res://lobby/starting_menu.tscn")
