extends Node2D


@export var move_speed: float = 200

var target_position: Vector2
var rotation_angle: float = 0.0
var collided : bool = false

var wall_group : WallGroup

func set_rotation_meta(vertical: bool, angle: float = 90.0, flipped: bool = false):
	rotation_angle = 0.0
	if vertical:
		rotation_angle = angle
	if flipped:
		rotation_angle += 180.0
	$Sprite2D.rotation = deg_to_rad(rotation_angle)
	$Area2D.rotation = deg_to_rad(rotation_angle)

func apply_meta():
	var vertical = false
	var angle = 90.0
	var flipped = false
	if has_meta("vertical"):
		vertical = get_meta("vertical")
	if has_meta("vertical_angle"):
		angle = get_meta("vertical_angle")
	if has_meta("flipped"):
		flipped = get_meta("flipped")
	set_rotation_meta(vertical, angle, flipped)

func _ready() -> void:
	apply_meta()
	#await get_tree().create_timer(10.0).timeout
	#queue_free()

func _process(delta: float) -> void:
	if target_position == null:
		return
	if collided:
		return
	var dir = (target_position - position)
	position += dir.normalized() * move_speed * delta

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("wall"):
		collided = true
	if area.is_in_group("mech"):
		collided = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("wall"):
		collided = false


func got_hit() -> void:
	# Handle the wall being hit by a projectile
	print("Wall got hit!")
	wall_group.got_hit(Big.new(1)) 
