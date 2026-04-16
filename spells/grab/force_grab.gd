extends Node3D


@export var HAND: Node3D

var SNAP_LERP: float = 5.0
var GRAB_FORCE: float = 18.0
var LET_GO_DISTANCE: float = 25.0
var GRABBED_OBJECT: RigidBody3D = null
var GRAB_FORCE_PER_MASS: float = 0.0 # Updated when a new object is grabbed


func _physics_process(delta: float) -> void:
	if GRABBED_OBJECT:
		hold_object(GRABBED_OBJECT, delta)


func release():
	if GRABBED_OBJECT and GRABBED_OBJECT.has_method("remove_grabber"):
		GRABBED_OBJECT.remove_grabber(self)
	GRABBED_OBJECT = null


func forced_release():
	GRABBED_OBJECT = null


func grab() -> bool:
	var bodies: Array[Node3D] = $Area3D.get_overlapping_bodies()
	var closest_body: Node3D = _get_closets_pickable_body(bodies)
	
	if closest_body != null:
		GRABBED_OBJECT = closest_body
		GRAB_FORCE_PER_MASS = GRAB_FORCE / GRABBED_OBJECT.mass
		if closest_body.has_method("add_grabber"):
			closest_body.add_grabber(self)
		
		return true
	return false

func hold_object(grabbed_obj: RigidBody3D, delta: float) -> void:
	var distance: float = HAND.global_position.distance_squared_to(grabbed_obj.global_position)
	var direction: Vector3 = HAND.global_position.direction_to(grabbed_obj.global_position).normalized()
	
	if distance >= LET_GO_DISTANCE:
		release()
		return
	
	grabbed_obj.linear_velocity = lerp(
		grabbed_obj.linear_velocity,
		-direction * distance * GRAB_FORCE_PER_MASS,
		SNAP_LERP * delta
	)


func _get_closets_pickable_body(bodies: Array[Node3D]) -> Node3D:
	var closest_body: Node3D = null
	var closest_distance: float = 99999999.9
	for body in bodies:
		if body.is_in_group("pickable"):
			var body_distance: float = self.global_position.distance_squared_to(body.global_position)
			
			if closest_body == null:
				closest_body = body
				closest_distance = body_distance
			else:
				if body_distance < closest_distance:
					closest_body = body
					closest_distance = body_distance
	return closest_body


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("highlight_on"):
		body.highlight_on()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.has_method("highlight_off"):
		body.highlight_off()
