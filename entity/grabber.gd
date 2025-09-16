extends "res://entity/base_entity.gd"


func _on_timer_timeout() -> void:
	$ForceGrab.grab()
