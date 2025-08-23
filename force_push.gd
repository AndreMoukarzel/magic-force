extends Node3D


@onready var CAM :Camera3D = $"../Camera3D"
var CATCH_VELOCITY: Vector3 = Vector3(0, -10, 0) # Base velocity set when object is caught
var PUSH_FORCE: float = 220.0


func area_push() -> void:
	$Area3D/MeshInstance3D.show()
	$Timer.start()
	
	var bodies: Array[Node3D] = $Area3D.get_overlapping_bodies()
	for body in bodies:
		push_away(body)

func push_away(object: RigidBody3D) -> void:
	var direction: Vector3 = CAM.global_position.direction_to(object.global_position).normalized()
	object.linear_velocity = Vector3(0, 10, 0)
	object.apply_impulse(direction * PUSH_FORCE)

func _on_timer_timeout() -> void:
	$Area3D/MeshInstance3D.hide()
