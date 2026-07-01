extends HBoxContainer

signal volume_changed(value: float)


var VOLUME: float = 0.0:
	set(new_value):
		$Value.text = "%02d" % int(round(100 * new_value))
		VOLUME = linear_to_db(new_value)


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var new_value: float = $HSlider.value
		VOLUME = new_value
		print(VOLUME)
		emit_signal("volume_changed", VOLUME)
