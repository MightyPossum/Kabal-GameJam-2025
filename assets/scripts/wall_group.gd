class_name WallGroup

var walls: Array = []
var walls_health : int = 4

func add_wall(wall: Node) -> void:
  walls.append(wall)

func destroy_walls() -> void:
  for wall in walls:
    print("Destroying wall: %s" % wall.name)
    wall.queue_free()

func got_hit(damage : int) -> void:
  walls_health -= damage
  if walls_health <= 0:
    destroy_walls()