extends Node2D

@export var projectile_scene: PackedScene
@export var spawn_interval: float = 1.0
@export var spawn_point_offset: Vector2 = Vector2(0, 0)

var spawn_timer: Timer

func _ready():
	# Create and setup the spawn timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_spawn_projectile)
	add_child(spawn_timer)
	spawn_timer.start()
	
	# If no projectile scene is assigned, try to load it
	if not projectile_scene:
		projectile_scene = preload("res://assets/scenes/BasicProjectile.tscn")

func _spawn_projectile():
	if not GLOBAL.GAME_SCENE.are_walls_visible():
		return	# Do not spawn if walls are not visible
		
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		
		# Set spawn position (relative to mech position)
		var spawn_position = global_position + spawn_point_offset
		projectile.global_position = spawn_position
		
		# Add to the scene tree (add to parent so projectiles persist if mech is destroyed)
		get_parent().add_child(projectile)
	else:
		print("Warning: No projectile scene assigned to mech!")

func set_spawn_interval(new_interval: float):
	spawn_interval = new_interval
	if spawn_timer:
		spawn_timer.wait_time = spawn_interval

func start_spawning():
	if spawn_timer:
		spawn_timer.start()

func stop_spawning():
	if spawn_timer:
		spawn_timer.stop()
