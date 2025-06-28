extends Node2D

# Preload wall scene
const WALL_SCENE := preload("res://assets/scenes/wall.tscn")

# Distance from center to spawn walls
const WALL_DISTANCE := 400

var walls : Dictionary = {}
var mech

var wall_health_base : Big = Big.new(6)
var wall_health : Big = wall_health_base
var wave_number : int = 1

# Directions: (name, offset, vertical, vertical_angle, flipped)
var directions = [
	{"name": "North", "offset": Vector2(0, -1), "vertical": true, "vertical_angle": 90.0, "flipped": false},
	{"name": "South", "offset": Vector2(0, 1), "vertical": true, "vertical_angle": -90.0, "flipped": false},
	{"name": "West", "offset": Vector2(-1, 0), "vertical": false, "flipped": false},
	{"name": "East", "offset": Vector2(1, 0), "vertical": false, "flipped": true}
]

func are_walls_visible() -> bool:
	var viewport_rect = get_viewport().get_visible_rect()
	for child in get_children():
		if child.is_in_group("wall"):
			if viewport_rect.has_point(child.global_position):
				return true
	return false

func _ready():
	AudioManager.play_sound(preload("res://assets/gym.wav"), 0.2)
	GLOBAL.GAME_SCENE = self # Set the global game scene variable
	mech = $Mech
	mech.position = get_viewport_rect().size / 2
	await spawn_waves()

func get_wall_health_for_wave(wave: int) -> Big:
	# Example idle game scaling: base * (1.15 ^ (wave-1))
	return Big.times(wall_health_base, Big.new(pow(1.15, wave-1)))

func spawn_walls():
	var wall_group : WallGroup = WallGroup.new()
	wall_group.walls_health = get_wall_health_for_wave(wave_number)
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
		wave_number += 1
		await get_tree().create_timer(20.0).timeout
