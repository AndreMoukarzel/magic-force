extends Node

@export var BALL_SCN: PackedScene
@export var POINT_HANDLER: Control
@export var SPAWNERS: Node3D
var ACTIVE_BALL: RigidBody3D = null
var UNAVAILABLE_SPAWNS: Dictionary[String, Array] = {
	"A": [],
	"B": [],
}
var SPAWN_COOLDOWN: float = 1.5


func _ready() -> void:
	spawn_ball()
	POINT_HANDLER.goal_scored.connect(goal_was_scored)


func spawn_ball() -> void:
	var pos: Vector3 = SPAWNERS.get_node("BallSpawn").global_position
	var BallInstance: RigidBody3D = BALL_SCN.instantiate()
	
	self.add_child(BallInstance)
	BallInstance.global_position = pos
	
	ACTIVE_BALL = BallInstance


func spawn_players() -> void:
	spawn_player($"../Player".global_position, "A")


func spawn_player(player_pos: Vector3=Vector3(), team: String="A") -> void:
	var timer := get_tree().create_timer(SPAWN_COOLDOWN)
	var closest_available_spawn: Marker3D = _get_closest_available_spawn(player_pos, team)
	
	# Makes timer unavailable
	UNAVAILABLE_SPAWNS[team].append(closest_available_spawn)
	timer.timeout.connect(func():
		_release_spawn(closest_available_spawn, team)
	)
	
	$"../Player".global_position = closest_available_spawn.global_position


func goal_was_scored() -> void:
	$RespawnTimer.start()
	# DOES NOT exclude the ball, but make it so it can't be interacted with
	ACTIVE_BALL.set_collision_layer_value(2, 0)


func _get_team_spawns(team: String) -> Array[Node]:
	return SPAWNERS.get_node("Spawns" + team).get_children()


func _get_closest_available_spawn(pos: Vector3, team: String) -> Marker3D:
	var team_spawns: Array[Node] = _get_team_spawns(team)
	team_spawns.sort_custom( # Sort team spawns by distance to pos
		func(a, b):
			return a.global_position.distance_to(pos) < b.global_position.distance_to(pos)
	)
	for spawn in team_spawns:
		if spawn not in UNAVAILABLE_SPAWNS[team]:
			return spawn
	return team_spawns[0]


func _on_respawn_timer_timeout() -> void:
	ACTIVE_BALL.queue_free()
	spawn_ball()
	spawn_players()


func _release_spawn(spawn: Marker3D, team: String) -> void:
	## Releases a spawn from the UNAVAILABLE_SPAWNS list of that Team
	UNAVAILABLE_SPAWNS[team].erase(spawn)
