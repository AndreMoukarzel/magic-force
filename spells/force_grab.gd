extends Node


@export var RAYCAST: RayCast3D
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
	GRABBED_OBJECT = null

func grab() -> bool:
	var object = RAYCAST.get_collider()
	print(object)
	if object and object.is_in_group("pickable"):
		GRABBED_OBJECT = object
		GRAB_FORCE_PER_MASS = GRAB_FORCE / GRABBED_OBJECT.mass
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
