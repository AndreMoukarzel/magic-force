extends Node3D


func _on_point_handler_victory(_winner_team: String) -> void:
	get_tree().change_scene_to_file("res://lobby/starting_menu.tscn")


func _on_point_handler_match_draw() -> void:
	get_tree().change_scene_to_file("res://lobby/starting_menu.tscn")


func _on_resume_pressed() -> void:
	$Players/Player/CameraSpring.toggle_mouse_state()


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://lobby/starting_menu.tscn")


func _on_camera_spring_locked() -> void:
	$GameMenu.hide()


func _on_camera_spring_unlocked() -> void:
	$GameMenu.show()
