extends HBoxContainer


func get_less_populous_team() -> String:
	## Returns Teams with less Players
	if %TeamAMembers.get_child_count() > %TeamBMembers.get_child_count():
		return "B"
	return "A"


func get_team_players(team_name: String) -> Array:
	## Returns list of names of players on specified Team
	var team_node: VBoxContainer = get_node("Team" + team_name).get_node("Panel/Team" + team_name + "Members")
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
