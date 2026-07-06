extends Control

signal match_draw
signal victory(winner_team: String)
signal brasil
signal goal_scored(team_that_scored: String)

@export var GOAL_A: Node3D
@export var GOAL_B: Node3D
@export var MAX_SCORE: int = 10

var SCORE_A: int = 0
var SCORE_B: int = 0


func _ready() -> void:
	GOAL_A.goal_scored.connect(goal_was_scored.bind("A"))
	GOAL_B.goal_scored.connect(goal_was_scored.bind("B"))
	update_timer()


func _process(_delta: float) -> void:
	update_timer()


func goal_was_scored(team: String) -> void:
	if team == "A":
		SCORE_A += 1
		%ScoreA.text = str(SCORE_A)
		
		if SCORE_A >= MAX_SCORE:
			emit_signal("victory", "A")
		emit_signal("goal_scored", "A")
		
	elif team == "B":
		SCORE_B += 1
		%ScoreB.text = str(SCORE_B)
		
		if SCORE_B >= MAX_SCORE:
			emit_signal("victory", "B")
		emit_signal("goal_scored", "B")
	
	if (SCORE_A == 7 and SCORE_B == 1) or (SCORE_A == 1 and SCORE_B == 7):
		emit_signal("brasil")


func reactivate_goals() -> void:
	## A goal is disabled after scoring. This reactivates them
	GOAL_A.activate()
	GOAL_B.activate()


func update_timer() -> void:
	var time_left: float = $Timer.time_left
	var mins: int = floori(time_left / 60)
	var secs: int = floori(time_left) % 60
	$%TimerLabel.text = "%02d:%02d" % [mins, secs]


func _on_timer_timeout() -> void:
	if SCORE_A > SCORE_B:
		emit_signal("goal_scored", "A")
	elif SCORE_B > SCORE_A:
		emit_signal("goal_scored", "B")
	else:
		emit_signal("match_draw")
