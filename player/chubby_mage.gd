extends Node3D


const CLOTH_MATERIAL: Material = preload("res://player/team_clothes_material.tres")
const COLORS: Array = [
	Color("ba0011"),
	Color("2736ff")
]


func _ready() -> void:
	lock_cape_to_node()
	set_clothes_material()
	set_clothes_color(COLORS[1])


func lock_cape_to_node(target_node: Node3D=self) -> void:
	var cape: SoftBody3D = $Cape/SoftBody3D
	var target_path: NodePath = target_node.get_path()
	
	for point_index in cape.pinned_points:
		cape.set_point_pinned(point_index, true, target_path)


func set_clothes_material() -> void:
	var cape: SoftBody3D = $Cape/SoftBody3D
	var hat: MeshInstance3D = $metarig/Skeleton3D/Head/Hat
	
	cape.mesh.surface_set_material(0, CLOTH_MATERIAL)
	hat.mesh.surface_set_material(0, CLOTH_MATERIAL)


func set_clothes_color(color: Color) -> void:
	var cape: SoftBody3D = $Cape/SoftBody3D
	var cape_material: Material = cape.mesh.surface_get_material(0)
	
	cape_material.albedo_color = color
	
	var hat: MeshInstance3D = $metarig/Skeleton3D/Head/Hat
	var hat_material: Material = hat.mesh.surface_get_material(0)
	
	hat_material.albedo_color = color
