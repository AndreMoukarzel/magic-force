extends Node

@export var FLOAT_SPEED: float = 1.5
var is_active: bool = false


func activate():
	is_active = true


func deactivate():
	is_active = false
