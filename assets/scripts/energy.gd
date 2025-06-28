extends Node2D
@export var particle_scene: PackedScene
func _ready() -> void:
	# Make sure the energy can receive input events
	set_process_input(true)

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
			var energy_rect = Rect2(global_position - Vector2(16, 16), Vector2(32, 32))  # Adjust size as needed
			if energy_rect.has_point(mouse_pos):
				var particles = particle_scene.instantiate()
				particles.global_position = global_position
				particles.emitting = true
				get_tree().get_root().add_child(particles)
				GLOBAL.ENERGY += 1
				print("ENERGY: " + str(GLOBAL.ENERGY))
				queue_free()
