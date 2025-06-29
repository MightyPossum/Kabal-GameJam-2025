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
var float_offset: Vector2 = Vector2.ZERO
var locked_time_offset: float = 0.0

var auto_cannon_enabled: bool = false  # Flag to control auto cannon firing
var auto_cannon_initialized: bool = false  # Flag to ensure cannon is initialized only once

var harvester_enabled : bool = false	# Flag to control harvester functionality
var harvester_initialized : bool = false  # Flag to ensure harvester is initialized only once

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
	
func _process(delta: float) -> void:
	# Only increment time when not locked
	if not GLOBAL.LOCKED:
		time_passed += delta
	else:
		# When locked, store the time offset to maintain smooth transition
		locked_time_offset += delta
	
	# Gentle rotation
	rotation += rotation_speed * delta
	
	# Floating movement with sine wave for smooth motion
	if not GLOBAL.LOCKED:
		# When unlocking, adjust time to prevent jerky motion
		var effective_time = time_passed
		
		float_offset = Vector2(
			sin(effective_time * 0.8) * float_range * 0.7,
			cos(effective_time * 0.6) * float_range * 0.5
		)
		
		# Apply the floating motion to the origin position
		global_position = origin_position + float_offset
	
	# Update absorption timer interval if it exists and MECH_ABSORPTION has changed
	if absorption_timer:
		var new_interval = _calculate_absorption_interval()
		if abs(absorption_timer.wait_time - new_interval) > 0.1:  # Only update if significant change
			absorption_timer.wait_time = new_interval
	
	# Update cannon timer interval if it exists and CANNON_SHOOT_RATE has changed
	#if cannon_timer:
	#	var new_cannon_interval : float = _calculate_cannon_interval()
	#	if abs(cannon_timer.wait_time - new_cannon_interval) > 0.1:  # Only update if significant change
	#		cannon_timer.wait_time = new_cannon_interval
	if not auto_cannon_enabled:
		if GLOBAL.CANNON_SHOOT_RATE.isGreaterThan(0):
			# Enable auto cannon firing if the shoot rate is greater than 0
			auto_cannon_enabled = true



func _spawn_projectile():
	if projectile_scene:
		var projectile_count = GLOBAL.PROJECTILE_AMOUNT.mantissa
		
		# Spawn multiple projectiles with small delays
		for i in range(projectile_count):
			# Create a timer for each projectile with increasing delay
			var delay = i * 0.1  # 0.1 second delay between each shot
			
			if delay == 0:
				# Fire the first projectile immediately
				_fire_single_projectile()
			else:
				# Fire subsequent projectiles with delay
				var shot_timer = Timer.new()
				shot_timer.wait_time = delay
				shot_timer.one_shot = true
				shot_timer.timeout.connect(_fire_single_projectile)
				add_child(shot_timer)
				shot_timer.start()
				# Clean up the timer after it's done
				shot_timer.timeout.connect(shot_timer.queue_free)
		
		# Play shooting sound once for the volley
		AudioManager.play_sound(preload("res://assets/audio/laserShoot.wav"), 0.5)
	else:
		print("Warning: No projectile scene assigned to mech!")

func _fire_single_projectile():
	if projectile_scene:
		GLOBAL.MANUAL_SHOTS = GLOBAL.MANUAL_SHOTS.plus(1)
		var projectile = projectile_scene.instantiate()
		
		# Set spawn position (relative to mech position)
		var spawn_position = global_position + spawn_point_offset
		projectile.global_position = spawn_position
		
		# Add to the scene tree (add to parent so projectiles persist if mech is destroyed)
		get_parent().add_child(projectile)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			# Check if the mouse is over this mech
			var mouse_pos = get_global_mouse_position()
			var mech_rect = Rect2(global_position - Vector2(32, 32), Vector2(64, 64))  # Adjust size as needed
			if mech_rect.has_point(mouse_pos):
				GLOBAL.MANUAL_SHOTS.plus(1)
				if not auto_cannon_initialized:
					# Initialize the auto cannon shooting if not already done
					auto_cannon_initialized = true
					shoot_autocannon()  # Start the auto cannon shooting process
				if not harvester_initialized:
					harvester_initialized = true
					trigger_harvester() # Start the harvester functionality

				_spawn_projectile()

func increase_cannon_damage(amount: Big):
	if not GLOBAL.CURRENT_DAMAGE_CANNON:
		GLOBAL.CURRENT_DAMAGE_CANNON = Big.new(0)
	GLOBAL.CURRENT_DAMAGE_CANNON.plusEquals(amount)

func shoot_autocannon():
	var cannon_interval : float = _calculate_cannon_interval()
	await get_tree().create_timer(cannon_interval).timeout
	if auto_cannon_enabled:
		_spawn_projectile()
	shoot_autocannon() # Recursively call to keep shooting at intervals

func _calculate_cannon_interval() -> float:
	# CANNON_SHOOT_RATE is the timer interval in seconds
	
	var attack_speed_stat : Stat = GLOBAL.STATS.stats[GLOBAL.STAT_TYPE.VELOCITY_AMPLIFIER][GLOBAL.STAT_TIER.CORE]
	var attack_speed : float
	if attack_speed_stat.level == 0:
		attack_speed = 1
	else:
		attack_speed = 1*pow(1-(attack_speed_stat.value_increase_per_level/100), attack_speed_stat.level)
		
	var cannon_rate : Big = GLOBAL.CANNON_SHOOT_RATE.multiply(attack_speed)
	
	# If cannon shoot rate is 0 or very low, set a very long interval (effectively disabled)
	if cannon_rate.isLessThanOrEqualTo(0):
		return 1.0
	
	return cannon_rate.toFloat()	# Convert Big to float for timer interval

func _calculate_absorption_interval() -> float:
	# MECH_ABSORPTION is already the timer interval in seconds
	var absorption_value = GLOBAL.MECH_ABSORPTION.toFloat()
	print("Absorption Value",absorption_value)
	# If absorption is 0 or very low, set a very long interval (effectively disabled)
	if absorption_value <= 0:
		return 1  # Very long interval when absorption is 0
	
	return absorption_value

func trigger_harvester():
	var harvester_interval : float = _calculate_absorption_interval()
	await get_tree().create_timer(harvester_interval).timeout
	if harvester_enabled:
		_on_absorption_timer_timeout()
	trigger_harvester() # Recursively call to keep harvesting at intervals

func _on_absorption_timer_timeout():
	# Get all energy objects in the "energy" group
	var energy_nodes = get_tree().get_nodes_in_group("energy")
	
	if energy_nodes.size() > 0:
		# Randomly select one energy object
		var random_energy = energy_nodes[randi() % energy_nodes.size()]
		if not GLOBAL.LOCKED:
			_absorb_energy(random_energy)

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
