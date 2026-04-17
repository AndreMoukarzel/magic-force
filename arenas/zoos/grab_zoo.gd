extends Node3D


@export var radius: float = 6.0
@export var speed: float = 2.0  # radians per second

@onready var center: Vector3 = $Hold/Mage1/Marker3D.global_position
var angle: float = 0.0


func _ready() -> void:
	$Hold/Mage1/ProjectileGrab.grab()


func _physics_process(delta: float) -> void:
	angle += speed * delta
	
	var offset = Vector3(
		cos(angle) * radius,
		0,
		sin(angle) * radius
	)
	
	$Hold/Mage1/Marker3D.global_position = center + offset


func _on_distances_timer_timeout() -> void:
	for child in $Distances.get_children():
		if "Mage" in child.name:
			var GrabSpell: Node3D = child.get_node("ProjectileGrab")
			
			if GrabSpell.GRABBED_OBJECT == null:
				GrabSpell.grab()
			else:
				GrabSpell.release()


func _on_conflict_timer_timeout() -> void:
	$Conflict/Mage1/ProjectileGrab.grab()
	await get_tree().create_timer(0.5).timeout
	$Conflict/Mage2/ProjectileGrab.grab()
