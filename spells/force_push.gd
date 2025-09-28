extends Node3D


@export var PLAYER: CharacterBody3D
@export var CAM: Camera3D
var CATCH_VELOCITY: Vector3 = Vector3(0, -10, 0) # Base velocity set when object is caught
var PUSH_FORCE: float = 220.0
var SELF_PUSH_FORCE: float = 4.3


func area_push() -> void:
	$Area3D/MeshInstance3D.show()
	$Cooldown.start()
	
	var bodies: Array[Node3D] = $Area3D.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("apply_impulse"):
			push_away(body)
			
			if body.has_method("clear_all_grabbers"):
				body.clear_all_grabbers()
	
	var floors: Array[Node3D] = $AreaFloorPush.get_overlapping_bodies()
	if len(floors) > 0:
		push_player()


func _get_push_direction(object: RigidBody3D) -> Vector3:
	if CAM:
		return CAM.global_position.direction_to(object.global_position).normalized()
	return self.global_position.direction_to(object.global_position).normalized()


func push_away(object: RigidBody3D) -> void:
	var direction: Vector3 = _get_push_direction(object)
	object.linear_velocity = Vector3(0, 10, 0)
	object.apply_impulse(direction * PUSH_FORCE)


func push_player() -> void:
	# Forward vector of the camera (where it is looking)
	var cam_forward: Vector3 = -CAM.global_transform.basis.z.normalized()
	
	# Opposite direction (push AWAY from where camera is looking)
	var push_dir: Vector3 = -cam_forward
	PLAYER.apply_knockback(push_dir * SELF_PUSH_FORCE)


func _on_timer_timeout() -> void:
	$Area3D/MeshInstance3D.hide()
