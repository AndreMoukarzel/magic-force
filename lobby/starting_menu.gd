extends Control


func fade_out(duration: float = 1.0) -> Tween:
	var tween = create_tween()
	# Transitioning from current volume to -80 dB (which is inaudible)
	tween.tween_property($AudioStreamPlayer, "volume_db", -80.0, duration)
	tween.tween_property($Blackout, "modulate", Color(0.0, 0.0, 0.0, 1.0), 1.0)
	return tween


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
