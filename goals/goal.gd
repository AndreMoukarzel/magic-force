extends Node3D

signal goal_scored


func _on_area_3d_body_entered(body: Node3D) -> void:
	var forward = -global_transform.basis.z.normalized()
	var entry_direction: Vector3 = body.global_position.direction_to(self.global_position).normalized()
	var dot_val = forward.dot(entry_direction)
	
	if dot_val > 0: # Ball entered from the front
		emit_signal("goal_scored")
		deactivate()


func deactivate() -> void:
	$Area3D.set_deferred("monitoring", false)


func activate() -> void:
	$Area3D.monitoring = true
