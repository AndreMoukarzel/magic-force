extends Node3D


@export var HAND: Node3D
@export var COOLDOWN: float = 2.5

var PROJECTILE_SCN: Resource = load("res://spells/grab/hand_projectile.tscn")
var HOLDER_SCN: Resource = load("res://spells/grab/hand_holder.tscn")
var GRABBED_OBJECT: RigidBody3D = null
var HOLDER_OBJECT: Node3D = null
var PROJECTILE_SPAWN_OFFSET: float = 1.0
var SNAP_LERP: float = 5.0
var GRAB_FORCE: float = 18.0
var GRAB_FORCE_PER_MASS: float = 0.0 # Updated when a new object is grabbed


func _ready():
	$Cooldown.wait_time = COOLDOWN
	$CooldownEffect.set_cooldown_duration(COOLDOWN)


func _physics_process(delta: float) -> void:
	if GRABBED_OBJECT:
		hold_object(GRABBED_OBJECT, delta)


func release():
	if GRABBED_OBJECT and GRABBED_OBJECT.has_method("remove_grabber"):
		GRABBED_OBJECT.remove_grabber(self)
	GRABBED_OBJECT = null
	
	if HOLDER_OBJECT != null:
		HOLDER_OBJECT.queue_free()
		HOLDER_OBJECT = null
	
	$Cooldown.start()
	$CooldownEffect.continue_playing()


func forced_release():
	if HOLDER_OBJECT != null:
		HOLDER_OBJECT.queue_free()
		HOLDER_OBJECT = null
	GRABBED_OBJECT = null
	
	$Cooldown.start()
	$CooldownEffect.continue_playing()


func grab():
	if not $Cooldown.is_stopped():
		return
	
	if GRABBED_OBJECT:
		release()
		return
	
	var Proj = PROJECTILE_SCN.instantiate()
	Proj.global_transform = global_transform.translated(
		-global_transform.basis.z * PROJECTILE_SPAWN_OFFSET
	)
	Proj.grabbed.connect(grabbed_body)
	if "velocity" in get_parent():
		Proj.INHERITED_VELOCITY = get_parent().velocity
	get_tree().current_scene.add_child(Proj)
	
	$CooldownEffect.play_full_cooldown_effect()
	$Cooldown.start()
	$GrabbingHand.hide()


func grabbed_body(body: Node3D) -> void:
	if body.has_method("add_grabber"):
		if len(body.GRABBERS) > 0:
			body.clear_all_grabbers()
			return
	
	$Cooldown.stop()
	$CooldownEffect.stop()
	
	
	GRABBED_OBJECT = body
	GRAB_FORCE_PER_MASS = GRAB_FORCE / GRABBED_OBJECT.mass
	if body.has_method("add_grabber"):
		var Holder: Node3D = HOLDER_SCN.instantiate()
		
		HOLDER_OBJECT = Holder
		Holder.TARGET = body
		get_tree().current_scene.add_child(Holder)
		body.add_grabber(self)


func hold_object(grabbed_obj: RigidBody3D, delta: float) -> void:
	var distance: float = HAND.global_position.distance_squared_to(grabbed_obj.global_position)
	var direction: Vector3 = HAND.global_position.direction_to(grabbed_obj.global_position).normalized()
	
	grabbed_obj.linear_velocity = lerp(
		grabbed_obj.linear_velocity,
		-direction * distance * GRAB_FORCE_PER_MASS,
		SNAP_LERP * delta
	)


func _on_cooldown_timeout() -> void:
	$GrabbingHand.show()
