extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	var forward = -global_transform.basis.z.normalized()
	var entry_direction: Vector3 = body.global_position.direction_to(self.global_position).normalized()
	var dot_val = forward.dot(entry_direction)
	
	if dot_val > 0:
		print("GOAL! Ball entered from the front (dot =", dot_val, ")")
		# handle scoring...
	else:
		print("Ignored: entry from behind (dot =", dot_val, ")")
