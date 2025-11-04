extends HFlowContainer
class_name PlayerLabel


func set_player_name(text: String) -> void:
	$Name.text = text

func toggle_player_ready() -> void:
	$Ready.button_pressed = not $Ready.button_pressed

func is_ready() -> bool:
	return $Ready.button_pressed
