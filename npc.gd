extends CharacterBody2D

@export var npc_name: String = "NPC"
@export var town_id: String = "town_01"
@export var dialogue_high: Array[String] = ["Good to see you, traveler!"]
@export var dialogue_neutral: Array[String] = ["Hello."]
@export var dialogue_hostile: Array[String] = ["..."]

@export var speed: float = 50.0
@export var interaction_radius: float = 150.0

@onready var sprite = $AnimatedSprite2D
@onready var interaction_label = $InteractionLabel

var movement_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0
var player_nearby: bool = false
var player_ref: Node = null

func _ready() -> void:
	add_to_group("npcs")
	interaction_label.visible = false

func _physics_process(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0:
		choose_new_direction()

	velocity = movement_direction * speed
	move_and_slide()

	if velocity != Vector2.ZERO:
		play_animation(movement_direction)
	else:
		sprite.play("idle_down")

	# Check distance to player each frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var dist = global_position.distance_to(players[0].global_position)
		player_nearby = dist < interaction_radius
		player_ref = players[0]
		interaction_label.visible = player_nearby
	else:
		player_nearby = false
		interaction_label.visible = false

func get_dialogue() -> Array[String]:
	# PeaceManager doesn't exist yet — we'll wire this up in step 2 of the next phase
	# For now always return neutral
	return dialogue_neutral

func start_dialogue() -> void:
	if not player_nearby:
		return
	var lines = get_dialogue()
	DialogueManager.start(npc_name, lines)

func choose_new_direction() -> void:
	var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2.ZERO]
	movement_direction = directions.pick_random()
	wander_timer = randf_range(1.0, 3.0)

func play_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		sprite.play("walk_right" if dir.x > 0 else "walk_left")
	else:
		sprite.play("walk_bottom" if dir.y > 0 else "walk_top")
