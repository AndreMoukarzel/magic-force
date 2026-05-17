extends Node3D


const CLOTH_MATERIAL: Material = preload("res://player/team_clothes_material.tres")
const COLORS: Array = [
	Color("ba0011"),
	Color("2736ff")
]
const HEAD_ROTATION_SPEED: float = 6.0
@onready var CAPE: SoftBody3D = $Cape/SoftBody3D
@onready var HAT: MeshInstance3D = $metarig/Skeleton3D/HeadPivot/Head/Hat
@onready var ANIM_TREE: AnimationTree = $AnimationTree


func _ready() -> void:
	lock_cape_to_node()
	set_clothes_material()
	set_clothes_color(COLORS[1])


func lock_cape_to_node(target_node: Node3D=self) -> void:
	var target_path: NodePath = target_node.get_path()
	
	for point_index in CAPE.pinned_points:
		CAPE.set_point_pinned(point_index, true, target_path)


func set_clothes_material() -> void:
	CAPE.mesh.surface_set_material(0, CLOTH_MATERIAL)
	HAT.mesh.surface_set_material(0, CLOTH_MATERIAL)


func set_clothes_color(color: Color) -> void:
	var cape_material: Material = CAPE.mesh.surface_get_material(0)
	var hat_material: Material = HAT.mesh.surface_get_material(0)
	
	cape_material.albedo_color = color
	hat_material.albedo_color = color


func direct_head(target: Node3D, delta: float) -> void:
	var head: Node3D = $metarig/Skeleton3D/HeadPivot
	var body: MeshInstance3D = $metarig/Skeleton3D/Torso
	
	# Positions
	var head_pos = head.global_transform.origin
	var target_pos = target.global_transform.origin
	
	# Direction from head to target
	var target_dir = (target_pos - head_pos).normalized()
	
	# Body forward direction
	var body_forward = body.global_transform.basis.z
	body_forward.y = 0
	body_forward = body_forward.normalized()
	
	# ----- YAW -----
	
	# Flatten target dir for horizontal angle
	var flat_target = target_dir
	flat_target.y = 0
	flat_target = flat_target.normalized()
	
	# Signed horizontal angle
	var yaw = atan2(
		body_forward.cross(flat_target).y,
		body_forward.dot(flat_target)
	)
	
	# Clamp yaw to +/- 60 degrees
	var max_yaw = deg_to_rad(60.0)
	yaw = clamp(yaw, -max_yaw, max_yaw)
	
	# ----- PITCH -----
	
	# Vertical angle
	var pitch = asin(target_dir.y)
	
	# Clamp pitch
	var max_up = deg_to_rad(45.0)
	var max_down = deg_to_rad(30.0)
	pitch = clamp(pitch, -max_down, max_up)
	
	var target_rotation = Vector3(-pitch, yaw, 0.0)
	
	# Smooth interpolation
	head.rotation.x = lerp_angle(
		head.rotation.x,
		target_rotation.x,
		HEAD_ROTATION_SPEED * delta
	)
	
	head.rotation.y = lerp_angle(
		head.rotation.y,
		target_rotation.y,
		HEAD_ROTATION_SPEED * delta
	)


func update_animation_parameters(direction: Vector3, is_on_floor: bool, is_jumping: bool) -> void:
	ANIM_TREE["parameters/conditions/idle"] = (direction == Vector3.ZERO) and is_on_floor
	ANIM_TREE["parameters/conditions/is_moving"] = (direction != Vector3.ZERO) and is_on_floor
	ANIM_TREE["parameters/conditions/jumping"] = is_jumping
	ANIM_TREE["parameters/conditions/on_floor"] = is_on_floor
