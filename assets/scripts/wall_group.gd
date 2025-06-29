class_name WallGroup

var walls: Array = []
var walls_health : Big = Big.new(4)

func add_wall(wall: Node) -> void:
	walls.append(wall)

func destroy_walls() -> void:
	if walls.size() > 0:
		var energy_count = randi_range(1, 2)
		var selected_walls = []
		
		for i in range(energy_count):
			var available_walls = []
			for wall in walls:
				if not selected_walls.has(wall):
					available_walls.append(wall)
			
			if available_walls.size() > 0:
				var random_wall = available_walls[randi() % available_walls.size()]
				selected_walls.append(random_wall)
				random_wall.spawn_energy()
	
	for wall in walls:
		print("Destroying wall: %s" % wall.name)
		wall.queue_free()

func got_hit(damage : Big) -> void:

	walls_health = walls_health.minus(damage)
	if walls_health.isLessThanOrEqualTo(0):
		destroy_walls()
