extends Node2D
@export var particle_scene: PackedScene
@export var float_speed: float = 10.0
@export var rotation_speed: float = 1.0
@export var spawn_duration: float = 0.3

var velocity: Vector2
var screen_size: Vector2
var spawn_tween: Tween

func _ready() -> void:
	# Make sure the energy can receive input events
	set_process_input(true)
	
	# Start with almost zero scale for spawn animation
	scale = Vector2(0.1, 0.1)
	
	# Create and configure spawn animation
	spawn_tween = create_tween()
	spawn_tween.tween_property(self, "scale", Vector2(1.0, 1.0), spawn_duration)
	spawn_tween.set_ease(Tween.EASE_OUT)
	spawn_tween.set_trans(Tween.TRANS_BACK)
	
	# Get screen size
	screen_size = get_viewport().get_visible_rect().size
	
	# Calculate direction away from mech with some random variation
	if GLOBAL.MECH != null:
		var direction = (global_position - GLOBAL.MECH.global_position).normalized()
		# Add some random movement in both directions
		direction.x += randf_range(-0.3, 0.3)
		direction.y += randf_range(-0.5, 0.5)
		velocity = direction.normalized() * float_speed
	else:
		# Fallback: random direction if mech not available
		velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * float_speed

func _process(delta: float) -> void:
	# Rotate slowly
	rotation += rotation_speed * delta
	
	# Move with velocity
	global_position += velocity * delta
	
	# Keep entire object within screen bounds (assuming 32x32 size like in click detection)
	var half_size = 8  # Half of the object size
	
	if global_position.x <= half_size or global_position.x >= screen_size.x - half_size:
		velocity.x = -velocity.x
		global_position.x = clamp(global_position.x, half_size, screen_size.x - half_size)
	
	if global_position.y <= half_size or global_position.y >= screen_size.y - half_size:
		velocity.y = -velocity.y
		global_position.y = clamp(global_position.y, half_size, screen_size.y - half_size)

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			GLOBAL.ENERGY += 1
			var particles = particle_scene.instantiate()
			particles.global_position = global_position
			particles.emitting = true
			get_tree().get_root().add_child(particles)
			print("ENERGY: " + str(GLOBAL.ENERGY))
			queue_free()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			# Check if the mouse is over this energy object
			var mouse_pos = get_global_mouse_position()
			var energy_rect = Rect2(global_position - Vector2(8, 8), Vector2(16, 16))  # Adjust size as needed
			if energy_rect.has_point(mouse_pos):
				var particles = particle_scene.instantiate()
				particles.global_position = global_position
				particles.emitting = true
				get_tree().get_root().add_child(particles)
				GLOBAL.ENERGY += 1
				print("ENERGY: " + str(GLOBAL.ENERGY))
				AudioManager.play_sound(preload("res://assets/audio/powerUp.wav"), 0.5)
				queue_free()
