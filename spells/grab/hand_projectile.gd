extends Area3D

signal grabbed(object: Node3D)
signal timeout

@export var SPEED: float = 10.0
@export var INHERIT_FACTOR: float = 0.6 # Effect the caster's velocity will have in final movement
var INHERITED_VELOCITY: Vector3 = Vector3.ZERO


func _physics_process(delta: float) -> void:
	var direction = -transform.basis.z
	var base_velocity = direction * SPEED
	var inherited_modified = INHERITED_VELOCITY * INHERIT_FACTOR
	position += (base_velocity + inherited_modified) * delta


func _on_timer_timeout() -> void:
	emit_signal("timeout")
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("add_grabber"):
		emit_signal("grabbed", body)
		queue_free()
