extends Node3D


signal animation_done


const HandMaterial = preload("res://spells/cooldown_effect/cooldown_material.tres")


func _ready() -> void:
	$AnimationPlayer7.animation_finished.connect(
		func(_anim_name):
			animation_done.emit()
	)
	
	for i in range(8):
		var mesh_name: String = "Piece_00" + str(i)
		if i == 0:
			mesh_name = "Piece"
		var PieceMesh: MeshInstance3D = get_node(mesh_name)
		PieceMesh.set_surface_override_material(0, HandMaterial)


func play_animation() -> void:
	for i in range(8):
		var anim_name: String = "Piece_00" + str(i) + "Action"
		var anim_player_name: String = "AnimationPlayer"
		if i > 0:
			anim_player_name += str(i)
		else:
			anim_name = "PieceAction"
		
		get_node(anim_player_name).play(anim_name)


func play_animation_backwards() -> void:
	for i in range(8):
		var anim_name: String = "Piece_00" + str(i) + "Action"
		var anim_player_name: String = "AnimationPlayer"
		if i > 0:
			anim_player_name += str(i)
		else:
			anim_name = "PieceAction"
		
		get_node(anim_player_name).play_backwards(anim_name)


func set_animation_speed(speed: float) -> void:
	for i in range(8):
		var anim_player_name: String = "AnimationPlayer"
		if i > 0:
			anim_player_name += str(i)
		var AnimPlayer: AnimationPlayer = get_node(anim_player_name)
		
		AnimPlayer.set_speed_scale(speed)


func set_animation_duration(anim_duration: float) -> void:
	var default_duration: float = $AnimationPlayer.get_animation("PieceAction").length
	var anim_speed: float = default_duration / anim_duration
	
	set_animation_speed(anim_speed)
