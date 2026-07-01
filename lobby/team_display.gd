extends HBoxContainer


var PLAYER_LABEL_SCN := preload("res://lobby/player_label.tscn")


func get_less_populous_team() -> String:
	## Returns Teams with less Players
	if %TeamAMembers.get_child_count() > %TeamBMembers.get_child_count():
		return "B"
	return "A"


func get_team_players(team_name: String) -> Array:
	## Returns list of names of players on specified Team
	var team_node: VBoxContainer = get_node(
		"Team" + team_name
		).get_node(
			"VBoxContainer/TeamMargin/Team" + team_name + "Members"
	)
	var player_names: Array[String] = []
	
	for player_label in team_node.get_children():
		player_names.append(player_label.get_node("Name").text)
	
	return player_names


func find_player_label(Player: Node) -> PlayerLabel:
	## Finds the equivalent player node inside of Player display
	var TeamMembers = %TeamAMembers
	if Player.TEAM == "B":
		TeamMembers = %TeamBMembers
	
	for player_label in TeamMembers.get_children():
		if player_label.name == str(Player.name):
			return player_label
	return null


func add_player_label(
	player_id: int, player_name: String, team: String, is_ready: bool=false, steam_name: String=""
	) -> void:
	## Adds PlayerLabel object to specified Team's Members Panel
	print("Adding player label for ", player_id)
	var NewLabel := PLAYER_LABEL_SCN.instantiate()
	NewLabel.name = str(player_id)
	NewLabel.set_player_name(player_name)
	if steam_name != "":
		NewLabel.set_player_name(steam_name)
	if is_ready:
		NewLabel.toggle_player_ready()
	
	if team == "A":
		%TeamAMembers.add_child(NewLabel, true)
	elif team == "B":
		%TeamBMembers.add_child(NewLabel, true)


func update_player_label_ready(Player):
	## Toggles the "Ready" state being displayed for Player's label
	var player_label: PlayerLabel = find_player_label(Player)
	player_label.toggle_player_ready()
