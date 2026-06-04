extends Node3D


var ANIM_DURATION: float


func _ready() -> void:
	$Broken.hide()


func set_cooldown_duration(duration: float) -> void:
	ANIM_DURATION = duration
	$Broken.set_animation_duration(duration/2.0)


func play_cooldown_effect() -> void:
	$Broken.show()
	$Broken.play_animation()
	$GlassBreaking.play()


func play_cooldown_reverse_effect() -> void:
	$Broken.play_animation_backwards()
	await $Broken.animation_done
	$Broken.hide()


func play_full_cooldown_effect() -> void:
	play_cooldown_effect()
	
	await $Broken.animation_done
	
	play_cooldown_reverse_effect()


func stop() -> void:
	# Stops the playing animation
	$Broken.set_animation_speed(0.0)


func continue_playing() -> void:
	# Resets animation speed so animations keep playing
	if ANIM_DURATION:
		$Broken.set_animation_speed(ANIM_DURATION)
