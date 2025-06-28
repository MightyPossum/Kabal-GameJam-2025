class_name WallGroup

var walls: Array = []
var walls_health : Big = Big.new(4)

func add_wall(wall: Node) -> void:
	walls.append(wall)

func destroy_walls() -> void:
	if walls.size() > 0:
		var energy_count = randi_range(1, 2)
		for i in range(energy_count):
			var random_wall = walls[randi() % walls.size()]
			random_wall.spawn_energy()
	
	for wall in walls:
		print("Destroying wall: %s" % wall.name)
		wall.queue_free()

func got_hit(damage : Big) -> void:
	print(walls_health.toString() + " got hit with " + damage.toString())
	walls_health = walls_health.minus(damage)
	if walls_health.isLessThan(1):
		destroy_walls()
