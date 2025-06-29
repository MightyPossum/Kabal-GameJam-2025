extends Node2D
@export var sprites: Array[CompressedTexture2D]
@export var particle_scene: PackedScene

var selected_sprite_index: int = -1
var max_clicks: int = 0
var current_clicks: int = 0
var previous_locked_state: bool = false
var scale_down_tween: Tween
var fade_out_tween: Tween
@export var sprite : Sprite2D

func _ready() -> void:
	# Enable input processing for mouse clicks
	set_process_input(true)
	
	# Initialize the locked state tracking
	previous_locked_state = GLOBAL.LOCKED
	
	# Randomly select a sprite from the array
	if sprites.size() > 0:
		selected_sprite_index = randi() % sprites.size()
		var selected_sprite = sprites[selected_sprite_index]
		
		# Set the texture of the Sprite2D node to the selected sprite
		sprite.texture = selected_sprite
		
		# Set max clicks based on sprite index
		match selected_sprite_index:
			0:
				max_clicks = 5
			1:
				max_clicks = 10
			2:
				max_clicks = 20
			_:
				max_clicks = 5  # Default fallback
		
		print("Planet created with sprite ", selected_sprite_index, " - Max clicks: ", max_clicks)
	else:
		print("No sprites available in the array.")

func _process(_delta: float) -> void:
	# Slow rotation for visual polish
	rotation += 0.2 * _delta  # Very slow rotation
	
	# Check if GLOBAL.LOCKED has changed from false to true
	if previous_locked_state == false and GLOBAL.LOCKED == true:
		print("Planet destroyed due to GLOBAL.LOCKED becoming true")
		_start_destruction_animation()
	
	# Update previous state
	previous_locked_state = GLOBAL.LOCKED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			# Check if the mouse is over this planet
			var mouse_pos = get_global_mouse_position()
			var planet_rect = Rect2(global_position - Vector2(32, 32), Vector2(64, 64))  # Adjust size as needed
			if planet_rect.has_point(mouse_pos):
				_on_planet_clicked(mouse_pos)

func _on_planet_clicked(click_position: Vector2):
	# Increase click count
	current_clicks += 1
	
	# Spawn particles at exact click location
	if particle_scene:
		var particles = particle_scene.instantiate()
		particles.global_position = click_position
		particles.emitting = true
		get_tree().get_root().add_child(particles)
	
	# Add energy
	GLOBAL.ENERGY = GLOBAL.ENERGY.plus(GLOBAL.ENERGY_PER_CELL)
	print("Planet clicked! Energy: " + GLOBAL.ENERGY_STRING + " - Clicks: " + str(current_clicks) + "/" + str(max_clicks))
	
	# Play sound effect
	AudioManager.play_sound(preload("res://assets/audio/powerUp.wav"), 0.5)
	
	# Check if planet should be destroyed
	if current_clicks >= max_clicks:
		print("Planet max clicks reached, starting destruction animation")
		_start_destruction_animation()

func _start_destruction_animation():
	# Disable input to prevent further clicks during destruction
	set_process_input(false)
	
	# Stop any existing tweens first
	if scale_down_tween:
		scale_down_tween.kill()
	if fade_out_tween:
		fade_out_tween.kill()
	
	print("Starting planet destruction animation")
	
	# Create separate tweens for scale and fade
	scale_down_tween = create_tween()
	fade_out_tween = create_tween()
	
	# Scale down animation
	scale_down_tween.tween_property(self, "scale", Vector2.ZERO, 1.5)
	scale_down_tween.set_ease(Tween.EASE_IN)
	scale_down_tween.set_trans(Tween.TRANS_CUBIC)
	
	# Fade out animation
	fade_out_tween.tween_property(self, "modulate:a", 0.0, 1.5)
	fade_out_tween.set_ease(Tween.EASE_IN)
	fade_out_tween.set_trans(Tween.TRANS_CUBIC)
	
	# Hide the planet when the scale tween completes
	scale_down_tween.tween_callback(_destroy_planet)

func _destroy_planet():
	print("Planet destroyed after " + str(max_clicks) + " clicks!")
	queue_free()


