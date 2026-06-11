extends RigidBody3D


@export var HIGHLIGHT: Material
@export var XRAY: Material

var GRABBERS: Array = []


func _ready() -> void:
	highlight_off()

func highlight_on():
	$MeshInstance3D.material_overlay = HIGHLIGHT

func highlight_off():
	$MeshInstance3D.material_overlay = XRAY

func clear_momentum() -> void:
	linear_velocity = Vector3(0, 0, 0)

func add_grabber(grabber) -> void:
	GRABBERS.append(grabber)

func remove_grabber(grabber) -> void:
	GRABBERS.erase(grabber)
	if grabber.has_method("forced_release"):
		grabber.forced_release()

func clear_all_grabbers() -> void:
	for grabber in GRABBERS:
		remove_grabber(grabber)

func _on_body_entered(_body: Node) -> void:
	$BounceSFX.play()
