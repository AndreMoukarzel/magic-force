extends Node

@export var BALL_SCN: PackedScene
@export var POINT_HANDLER: Control
@export var SPAWNERS: Node3D
var ACTIVE_BALL: RigidBody3D = null


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
	var Spawn: Marker3D = SPAWNERS.get_node("SpawnsA/Spawn4")
	var spawn_pos: Vector3 = Spawn.global_position
	
	$"../Player".global_position = spawn_pos


func goal_was_scored() -> void:
	$RespawnTimer.start()
	# DOES NOT exclude the ball, but make it so it can't be interacted with
	ACTIVE_BALL.set_collision_layer_value(2, 0)


func _on_respawn_timer_timeout() -> void:
	ACTIVE_BALL.queue_free()
	spawn_ball()
	spawn_players()
