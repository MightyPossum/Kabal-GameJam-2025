extends Node2D


@export var move_speed: float = 200
@export var delivery_drone : Node2D
var target_position: Vector2
var rotation_angle: float = 0.0
var collided : bool = false
@export var energy_scene: PackedScene
var wall_group : WallGroup
var scale_down_tween: Tween
var fade_out_tween: Tween

func set_rotation_meta(vertical: bool, angle: float = 90.0, flipped: bool = false):
	rotation_angle = 0.0
	if vertical:
		rotation_angle = angle
	if flipped:
		rotation_angle += 180.0
	$Sprite2D.rotation = deg_to_rad(rotation_angle)
	$Area2D.rotation = deg_to_rad(rotation_angle)

func apply_meta():
	var vertical = false
	var angle = 90.0
	var flipped = false
	if has_meta("vertical"):
		vertical = get_meta("vertical")
	if has_meta("vertical_angle"):
		angle = get_meta("vertical_angle")
	if has_meta("flipped"):
		flipped = get_meta("flipped")
	set_rotation_meta(vertical, angle, flipped)

func _ready() -> void:
	apply_meta()
	#await get_tree().create_timer(10.0).timeout
	#queue_free()

func _process(delta: float) -> void:
	if target_position == null:
		return
	if collided:
		return
	else:
		delivery_drone.visible = true
		var dir = (target_position - position)
		position += dir.normalized() * move_speed * delta

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("wall"):
		collided = true
		GLOBAL.LOCKED = true
		_start_drone_scale_down()
	if area.is_in_group("mech"):
		collided = true
		GLOBAL.LOCKED = true
		_start_drone_scale_down()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("wall"):
		collided = false
		GLOBAL.LOCKED = false

func _start_drone_scale_down():
	if delivery_drone and delivery_drone.visible:
		# Stop any existing tweens first
		if scale_down_tween:
			scale_down_tween.kill()
		if fade_out_tween:
			fade_out_tween.kill()
		
		print("Starting drone scale down animation")
		
		# Create separate tweens for scale and fade
		scale_down_tween = create_tween()
		fade_out_tween = create_tween()
		
		# Scale down animation
		scale_down_tween.tween_property(delivery_drone, "scale", Vector2.ZERO, 1.5)
		scale_down_tween.set_ease(Tween.EASE_IN)
		scale_down_tween.set_trans(Tween.TRANS_CUBIC)
		
		# Fade out animation
		fade_out_tween.tween_property(delivery_drone, "modulate:a", 0.0, 1.5)
		fade_out_tween.set_ease(Tween.EASE_IN)
		fade_out_tween.set_trans(Tween.TRANS_CUBIC)
		
		# Hide the drone when the scale tween completes
		scale_down_tween.tween_callback(_hide_drone)

func _hide_drone():
	if delivery_drone:
		print("Hiding drone after animation")
		delivery_drone.visible = false
		# Reset scale and opacity for potential future use
		delivery_drone.scale = Vector2.ONE
		delivery_drone.modulate.a = 1.0

func got_hit() -> void:
	# Handle the wall being hit by a projectile
	wall_group.got_hit(GLOBAL.CURRENT_DAMAGE_CANNON) 

func spawn_energy() -> void:
	var energy = energy_scene.instantiate()
	energy.global_position = global_position		
	get_tree().get_root().add_child(energy)
	AudioManager.play_sound(preload("res://assets/audio/explosion.wav"), 0.5)
