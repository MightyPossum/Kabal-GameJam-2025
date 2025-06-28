extends Node2D

# Preload wall scene
const WALL_SCENE := preload("res://assets/scenes/wall.tscn")

# Distance from center to spawn walls
const WALL_DISTANCE := 400

var walls : Dictionary = {}
var mech

# Directions: (name, offset, vertical, vertical_angle, flipped)
var directions = [
	{"name": "North", "offset": Vector2(0, -1), "vertical": true, "vertical_angle": 90.0, "flipped": false},
	{"name": "South", "offset": Vector2(0, 1), "vertical": true, "vertical_angle": -90.0, "flipped": false},
	{"name": "West", "offset": Vector2(-1, 0), "vertical": false, "flipped": false},
	{"name": "East", "offset": Vector2(1, 0), "vertical": false, "flipped": true}
]

func _ready():
	# Find the Mech at center
	mech = $Mech
	mech.position = get_viewport_rect().size / 2

	await spawn_waves()

func spawn_walls():
	var wall_group : WallGroup = WallGroup.new()
	for dir in directions:
		var wall = WALL_SCENE.instantiate()
		wall.name = "Wall_%s" % dir["name"]
		add_child(wall)
		wall.position = mech.position + dir["offset"] * WALL_DISTANCE
		wall.target_position = mech.position
		wall.wall_group = wall_group
		wall.set_meta("vertical", dir["vertical"])
		if dir.has("vertical_angle"):
			wall.set_meta("vertical_angle", dir["vertical_angle"])
		wall.set_meta("flipped", dir["flipped"])
		wall.apply_meta() # Ensure all meta is applied after meta is set
		wall_group.add_wall(wall)

func spawn_waves() -> void:
	for i in range(5000):
		spawn_walls()
		await get_tree().create_timer(20.0).timeout

# No need for _process, as wall movement is now handled by each wall itself.
