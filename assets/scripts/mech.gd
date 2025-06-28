extends Node2D

@export var projectile_scene: PackedScene
@export var spawn_interval: float = 1.0
@export var spawn_point_offset: Vector2 = Vector2(0, 0)

var spawn_timer: Timer

func _ready():
	# Enable input processing for mouse clicks
	set_process_input(true)
	GLOBAL.MECH = self  # Set the global mech variable
	
	# If no projectile scene is assigned, try to load it
	if not projectile_scene:
		projectile_scene = preload("res://assets/scenes/BasicProjectile.tscn")

func _spawn_projectile():
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		
		# Set spawn position (relative to mech position)
		var spawn_position = global_position + spawn_point_offset
		projectile.global_position = spawn_position
		
		# Add to the scene tree (add to parent so projectiles persist if mech is destroyed)
		get_parent().add_child(projectile)
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
