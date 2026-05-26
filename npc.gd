extends CharacterBody2D

# Dialogue variables
@export var npc_name: String = "Generic NPC"
@export_multiline var dialogue: Array[String] = ["Hello!"]

# Movement variables
@export var speed: float = 50.0

@onready var sprite = $AnimatedSprite2D

var movement_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0

func _physics_process(delta: float) -> void:
	# 1. Countdown the timer
	wander_timer -= delta
	
	# 2. Pick a new direction when timer hits 0
	if wander_timer <= 0:
		choose_new_direction()
	
	# 3. Apply movement
	velocity = movement_direction * speed
	move_and_slide()
	
	# 4. Handle animations dynamically!
	if velocity != Vector2.ZERO:
		play_animation(movement_direction)
	else:
		# Note: Make sure you have an animation named "idle" in your list!
		sprite.play("idle") 

func choose_new_direction():
	var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2.ZERO]
	movement_direction = directions.pick_random()
	wander_timer = randf_range(1.0, 3.0)

# This is the same logic your main character uses!
func play_animation(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.play("walk_right")
		else:
			sprite.play("walk_left")
	else:
		if dir.y > 0:
			sprite.play("walk_bottom")
		else:
			sprite.play("walk_top")
