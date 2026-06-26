extends Node


const MAX_GOAL_HEIGHT: float = 0.0
const INITIAL_GOAL_HEIGHT: float = -20.0

var GoalA: Node3D
var GoalB: Node3D
@onready var PointHandler: Control = $"../PointHandler"


func _ready() -> void:
	GoalA = $"../PointHandler".GOAL_A
	GoalB = $"../PointHandler".GOAL_B
	GoalA.position.y = INITIAL_GOAL_HEIGHT
	GoalB.position.y = INITIAL_GOAL_HEIGHT


func _on_point_handler_goal_scored(team_that_scored: String) -> void:
	update_goal_height.rpc(team_that_scored)


@rpc("authority", "call_local")
func update_goal_height(team_that_scored: String) -> void:
	print(multiplayer.get_unique_id(), " update_goal_height")
	## When a goal is scored, the goal is moved up relative to the max score
	var max_score: int = PointHandler.MAX_SCORE
	var current_score: int = PointHandler.SCORE_A
	var Goal: Node3D = GoalA
	if team_that_scored == "B":
		current_score = PointHandler.SCORE_B
		Goal = GoalB
	var height_progress: float = float(current_score) / float(max(max_score - 1, 1.0))
	var target_height: float = lerpf(INITIAL_GOAL_HEIGHT, MAX_GOAL_HEIGHT, height_progress)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(Goal, "position:y", target_height, 1.5)
	tween.play()
