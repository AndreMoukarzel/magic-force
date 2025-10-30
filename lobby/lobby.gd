extends Control


func _ready() -> void:
	if Network.IS_HOST:
		%Start.disabled = false
		add_player(Global.STEAM_USERNAME, "A")
	%LobbyId.text = "Session ID: " + str(Network.LOBBY_ID)


func add_player(player_name: String, team: String) -> void:
	var NewLabel: Label = Label.new()
	NewLabel.text = player_name
	
	if team == "A":
		%TeamAMembers.add_child(NewLabel)
	elif team == "B":
		%TeamBMembers.add_child(NewLabel)


func find_player(player_name: String, team: String) -> Label:
	var TeamMembers = %TeamAMembers
	if team == "B":
		TeamMembers = %TeamBMembers
	
	for player in TeamMembers.get_children():
		if player.text == player_name:
			return player
	return null


func _on_change_team_pressed() -> void:
	var PlayerLabel: Label = find_player(Global.STEAM_USERNAME, "A")
	
	if PlayerLabel != null:
		PlayerLabel.reparent(%TeamBMembers)
	if PlayerLabel == null:
		PlayerLabel = find_player(Global.STEAM_USERNAME, "B")
		PlayerLabel.reparent(%TeamAMembers)


func _on_ready_pressed() -> void:
	pass # Replace with function body.


func _on_start_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	Network.leave_lobby()
	get_tree().change_scene_to_file("res://lobby/starting_menu.tscn")
