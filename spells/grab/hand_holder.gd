extends Node3D

@export var MAX_TILT := 0.4
@export var TILT_SMOOTH := 6.0
@export var TILT_STRENGHT := 0.5

var TARGET: Node3D = null
var _prev_pos: Vector3


func _ready() -> void:
	$GrabbingHand/AnimationPlayer.play("hold")
	highlight_off()


func _physics_process(delta: float) -> void:
	if TARGET:
		if not _prev_pos:
			_prev_pos = TARGET.global_position
		
		var current_pos = TARGET.global_position # + Vector(0.0, -V_OFFSET, 0.0)
		var velocity = (current_pos - _prev_pos) / delta
		_prev_pos = current_pos
		
		global_position = current_pos
		
		_apply_tilt(velocity, delta)


func _apply_tilt(velocity: Vector3, delta: float) -> void:
	# Convert world velocity into local-ish tilt idea
	var lateral = -velocity

	# Clamp influence so it doesn't go crazy
	var tilt_x = clamp(-lateral.z * TILT_STRENGHT, -MAX_TILT, MAX_TILT)
	var tilt_z = clamp(lateral.x * TILT_STRENGHT, -MAX_TILT, MAX_TILT)

	var target_rotation = Vector3(tilt_x, 0.0, tilt_z)

	global_rotation = global_rotation.lerp(target_rotation, TILT_SMOOTH * delta)


func highlight_on() -> void:
	$GrabbingHand/Armature/Skeleton3D/Hand/Outline.show()


func highlight_off() -> void:
	$GrabbingHand/Armature/Skeleton3D/Hand/Outline.hide()
