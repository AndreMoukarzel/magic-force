extends Node


const CAPY_SCN := preload("res://arenas/capybara/capybara.tscn")
const SPAWN_AREA: Vector3 = Vector3(140, 0, 380)

@export var BATCH_SIZE: int = 5


func spawn_capy():
	var body = CAPY_SCN.instantiate()
	
	body.global_position = Vector3(
		randf_range(-SPAWN_AREA.x * 0.5, SPAWN_AREA.x * 0.5),
		randf_range(10.0, 20.0),
		randf_range(-SPAWN_AREA.z * 0.5, SPAWN_AREA.z * 0.5)
	)
	body.angular_velocity = Vector3(10, 10, 10)
	
	add_child(body)


@rpc("call_local")
func spawn_many_capys(count: int):
	for i in range(0, count, BATCH_SIZE):
		for j in BATCH_SIZE:
			spawn_capy()
		await get_tree().create_timer(randf_range(0.05, 0.3)).timeout


@rpc("call_local")
func clean_capys() -> void:
	for child in get_children():
		child.queue_free()
