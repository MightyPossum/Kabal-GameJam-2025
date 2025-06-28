extends Node2D

@export var projectile_scene: PackedScene
@export var spawn_interval: float = 1.0
@export var spawn_point_offset: Vector2 = Vector2(0, 0)
@export var float_speed: float = 15.0
@export var float_range: float = 10.0
@export var rotation_speed: float = 0.2

var spawn_timer: Timer
var origin_position: Vector2
var float_direction: Vector2
var time_passed: float = 0.0

func _ready():
	# Enable input processing for mouse clicks
	set_process_input(true)
	GLOBAL.MECH = self  # Set the global mech variable
	
	# Store the original position as the center point for floating
	origin_position = global_position
	
	# Set initial random floating direction
	float_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	# If no projectile scene is assigned, try to load it
	if not projectile_scene:
		projectile_scene = preload("res://assets/scenes/BasicProjectile.tscn")

func _process(delta: float) -> void:
	time_passed += delta
	
	# Gentle rotation
	rotation += rotation_speed * delta
	
	# Floating movement with sine wave for smooth motion
	var float_offset = Vector2(
		sin(time_passed * 0.8) * float_range * 0.7,
		cos(time_passed * 0.6) * float_range * 0.5
	)
	
	# Apply the floating motion to the origin position
	global_position = origin_position + float_offset

func _spawn_projectile():
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		
		# Set spawn position (relative to mech position)
		var spawn_position = global_position + spawn_point_offset
		projectile.global_position = spawn_position
		
		# Add to the scene tree (add to parent so projectiles persist if mech is destroyed)
		get_parent().add_child(projectile)
		AudioManager.play_sound(preload("res://assets/audio/laserShoot.wav"), 0.5)  # Play shooting sound
	else:
		print("Warning: No projectile scene assigned to mech!")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			# Check if the mouse is over this mech
			var mouse_pos = get_global_mouse_position()
			var mech_rect = Rect2(global_position - Vector2(32, 32), Vector2(64, 64))  # Adjust size as needed
			if mech_rect.has_point(mouse_pos):
				_spawn_projectile()
