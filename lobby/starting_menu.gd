extends Control


func fade_out(duration: float = 1.0) -> Tween:
	var tween = create_tween()
	# Transitioning from current volume to -80 dB (which is inaudible)
	tween.tween_property($AudioStreamPlayer, "volume_db", -80.0, duration)
	tween.tween_property($Blackout, "modulate", Color(0.0, 0.0, 0.0, 1.0), 1.0)
	return tween


func _on_options_pressed() -> void:
	$MarginContainer/VBoxContainer/Back.show()
	$MarginContainer/VBoxContainer/Options.hide()
	$OptionsMenu.show()
	$HBoxContainer.hide()


func _on_back_pressed() -> void:
	$MarginContainer/VBoxContainer/Back.hide()
	$MarginContainer/VBoxContainer/Options.show()
	$OptionsMenu.hide()
	$HBoxContainer.show()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_master_volume_volume_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, value)


func _on_music_volume_volume_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, value)


func _on_sfx_volume_volume_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, value)
