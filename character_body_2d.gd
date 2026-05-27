extends CharacterBody2D

@export var speed: float = 200.0
@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	# Block movement while any UI is open
	if DialogueManager.is_open() or EventManager.is_open() or HUD.is_map_open():
		velocity = Vector2.ZERO
		sprite.play("idle")
		move_and_slide()
		return

	var direction := Input.get_vector("move_left", "move_right", "move_top", "move_bottom")

	if direction != Vector2.ZERO:
		velocity = direction * speed
		play_animation(direction)
	else:
		velocity = Vector2.ZERO
		sprite.play("idle")

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for npc in get_tree().get_nodes_in_group("npcs"):
			if npc.player_nearby:
				npc.start_dialogue()
				break

	if event.is_action_pressed("open_map"):
		HUD.toggle_map()

func play_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		sprite.play("walk_right" if dir.x > 0 else "walk_left")
	else:
		sprite.play("walk_bottom" if dir.y > 0 else "walk_top")
