class_name WallGroup

var walls: Array = []
var walls_health : Big = Big.new(4)

func add_wall(wall: Node) -> void:
	walls.append(wall)

func destroy_walls() -> void:
	for wall in walls:
		print("Destroying wall: %s" % wall.name)
		wall.queue_free()

func got_hit(damage : Big) -> void:
	print(walls_health.toString() + " got hit with " + damage.toString())
	walls_health = walls_health.minus(damage)
	if walls_health.isLessThan(1):
		destroy_walls()
