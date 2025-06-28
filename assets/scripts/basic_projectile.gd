extends Node2D

@export var speed: float = 200.0
@export var lifetime: float = 5.0

var direction: Vector2
var velocity: Vector2

func _ready():
	# Set a random direction (up, down, left, or right)
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	direction = directions[randi() % directions.size()]
	velocity = direction * speed
	
	# Auto-destroy the projectile after its lifetime
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_lifetime_expired)
	add_child(timer)
	timer.start()

func _physics_process(delta):
	# Move the projectile
	position += velocity * delta

func _on_lifetime_expired():
	queue_free()

func _on_area_2d_area_entered(area:Area2D) -> void:
	if area.is_in_group("wall"):
		area.get_parent().got_hit()
		queue_free() # Remove the projectile when it enters an area
