extends Node2D

@export var projectile_scene: PackedScene
@export var spawn_interval: float = 1.0
@export var spawn_point_offset: Vector2 = Vector2(0, 0)
@export var float_speed: float = 15.0
@export var float_range: float = 10.0
@export var rotation_speed: float = 0.2

var spawn_timer: Timer
var absorption_timer: Timer
var cannon_timer: Timer
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
		projectile_scene = preload("res://assets/scenes/basic_projectile.tscn")
	
	# Set up absorption timer
	_setup_absorption_timer()
	
	# Set up auto cannon timer
	_setup_cannon_timer()

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
	
	# Update absorption timer interval if it exists and MECH_ABSORPTION has changed
	if absorption_timer:
		var new_interval = _calculate_absorption_interval()
		if abs(absorption_timer.wait_time - new_interval) > 0.1:  # Only update if significant change
			absorption_timer.wait_time = new_interval
	
	# Update cannon timer interval if it exists and CANNON_SHOOT_RATE has changed
	if cannon_timer:
		var new_cannon_interval = _calculate_cannon_interval()
		if abs(cannon_timer.wait_time - new_cannon_interval) > 0.1:  # Only update if significant change
			cannon_timer.wait_time = new_cannon_interval

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

func increase_cannon_damage(amount: Big):
	if not GLOBAL.CURRENT_DAMAGE_CANNON:
		GLOBAL.CURRENT_DAMAGE_CANNON = Big.new(0)
	GLOBAL.CURRENT_DAMAGE_CANNON.plusEquals(amount)

func _setup_absorption_timer():
	absorption_timer = Timer.new()
	absorption_timer.wait_time = _calculate_absorption_interval()
	absorption_timer.timeout.connect(_on_absorption_timer_timeout)
	absorption_timer.autostart = true
	add_child(absorption_timer)

func _setup_cannon_timer():
	cannon_timer = Timer.new()
	cannon_timer.wait_time = _calculate_cannon_interval()
	cannon_timer.timeout.connect(_on_cannon_timer_timeout)
	cannon_timer.autostart = true
	add_child(cannon_timer)

func _calculate_cannon_interval() -> float:
	# CANNON_SHOOT_RATE is the timer interval in seconds
	var cannon_rate = GLOBAL.CANNON_SHOOT_RATE.toFloat()
	
	# If cannon shoot rate is 0 or very low, set a very long interval (effectively disabled)
	if cannon_rate <= 0:
		return 999999.0  # Very long interval when cannon shoot rate is 0
	
	return cannon_rate

func _on_cannon_timer_timeout():
	# Auto-shoot when timer triggers
	_spawn_projectile()
	
	# Update timer interval based on current cannon shoot rate
	cannon_timer.wait_time = _calculate_cannon_interval()

func _calculate_absorption_interval() -> float:
	# MECH_ABSORPTION is already the timer interval in seconds
	var absorption_value = GLOBAL.MECH_ABSORPTION.toFloat()
	
	# If absorption is 0 or very low, set a very long interval (effectively disabled)
	if absorption_value <= 0:
		return 999999.0  # Very long interval when absorption is 0
	
	return absorption_value

func _on_absorption_timer_timeout():
	# Get all energy objects in the "energy" group
	var energy_nodes = get_tree().get_nodes_in_group("energy")
	
	if energy_nodes.size() > 0:
		# Randomly select one energy object
		var random_energy = energy_nodes[randi() % energy_nodes.size()]
		if not GLOBAL.LOCKED:
			_absorb_energy(random_energy)
	
	# Update timer interval based on current absorption value
	absorption_timer.wait_time = _calculate_absorption_interval()

func _absorb_energy(energy_node: Node2D):
	# Create a tween to move the energy to the mech
	var absorption_tween = create_tween()
	var move_duration = 1.0  # Duration for energy to move to mech
	
	# Stop the energy's normal movement by setting its velocity to zero
	if energy_node.has_method("set") and "velocity" in energy_node:
		energy_node.velocity = Vector2.ZERO
	
	# Animate the energy moving towards the mech center
	absorption_tween.tween_property(energy_node, "global_position", global_position, move_duration)
	absorption_tween.set_ease(Tween.EASE_IN)
	absorption_tween.set_trans(Tween.TRANS_CUBIC)
	
	# When the tween completes, trigger the energy collection effects
	absorption_tween.tween_callback(_trigger_energy_collection.bind(energy_node))

func _trigger_energy_collection(energy_node: Node2D):
	# Check if the energy node still exists
	if not is_instance_valid(energy_node):
		return
	
	# Trigger the same effects as clicking on energy
	if energy_node.has_method("get") and energy_node.get("particle_scene"):
		var particles = energy_node.particle_scene.instantiate()
		particles.global_position = global_position
		particles.emitting = true
		get_tree().get_root().add_child(particles)
	
	# Add energy to global energy
	GLOBAL.ENERGY = GLOBAL.ENERGY.plus(GLOBAL.ENERGY_PER_CELL)
	print("ENERGY ABSORBED: " + GLOBAL.ENERGY_STRING)
	
	# Play absorption sound
	AudioManager.play_sound(preload("res://assets/audio/powerUp.wav"), 0.5)
	
	# Remove the energy node
	energy_node.queue_free()
