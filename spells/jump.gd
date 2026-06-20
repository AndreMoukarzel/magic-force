extends Node


@export var PLAYER: CharacterBody3D
@export var CAM: Camera3D
var JUMP_FORCE: float = 11.5
var MIN_VERTICAL_JUMP: float = 0.65



func jump(dir_modifier: Vector2=Vector2()) -> void:
	# Forward vector of the camera (where it is looking)
	var basis = CAM.global_transform.basis
	var cam_dir: Vector3 = -basis.z.normalized()
	
	var move_dir: Vector3 = Vector3.ZERO
	if dir_modifier != Vector2():
		move_dir = (basis.x * dir_modifier.x) + (basis.z * dir_modifier.y)
		move_dir.y = 0
		move_dir = move_dir.normalized()
	
	var final_dir: Vector3
	if move_dir != Vector3.ZERO:
		# Use movement for horizontal direction
		final_dir = move_dir
		# Add vertical influence from camera tilt
		final_dir.y = cam_dir.y
	else:
		# No input → jump straight up
		final_dir = Vector3.UP
	
	# Ensure upward motion
	final_dir.y = max(final_dir.y, MIN_VERTICAL_JUMP)
	
	PLAYER.velocity = final_dir * JUMP_FORCE
