extends CharacterBody2D

@export var speed: float = 200.0
@onready var sprite = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	# 1. Get input vector (get_vector is cleaner than get_axis twice)
	var direction = Input.get_vector("move_left", "move_right", "move_top", "move_bottom")
	
	# 2. Apply movement
	if direction != Vector2.ZERO:
		velocity = direction * speed
		play_animation(direction)
	else:
		velocity = Vector2.ZERO
		sprite.play("idle") # Call idle directly here when stopped

	move_and_slide()

func play_animation(dir: Vector2):
	# Prioritize horizontal animations if moving diagonally
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.play("walk_right")
		else:
			sprite.play("walk_left")
	# Prioritize vertical animations
	else:
		if dir.y > 0:
			sprite.play("walk_bottom")
		else:
			sprite.play("walk_top")
