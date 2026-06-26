extends Node3D


func _on_point_handler_victory(_winner_team: String) -> void:
	get_tree().change_scene_to_file("res://lobby/starting_menu.tscn")
