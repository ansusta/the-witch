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
var _walk_target: Vector2 = Vector2.ZERO
var _walking_to: bool = false
var _frozen: bool = false
var _emoting: bool = false
var movement_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0
var player_nearby: bool = false
var player_ref: Node = null

signal walk_finished

func freeze() -> void:
	_frozen = true
	velocity = Vector2.ZERO
	movement_direction = Vector2.ZERO
	sprite.play("idle_down")
	sprite.pause()

func unfreeze() -> void:
	_frozen = false

func walk_to(target: Vector2) -> void:
	_walk_target = target
	_walking_to = true

# Plays animation once
func play_emote(anim_name: String) -> void:
	if not sprite.sprite_frames.has_animation(anim_name):
		return
	_emoting = true
	sprite.play(anim_name)
	var frame_count = sprite.sprite_frames.get_frame_count(anim_name)
	var fps = sprite.sprite_frames.get_animation_speed(anim_name)
	var duration = frame_count / fps
	await get_tree().create_timer(duration).timeout
	_emoting = false

# Plays animation looping until stop_emote() is called
func play_emote_loop(anim_name: String) -> void:
	if not sprite.sprite_frames.has_animation(anim_name):
		return
	_emoting = true
	sprite.set_animation(anim_name)
	sprite.set_frame(0)
	sprite.play(anim_name)

func stop_emote() -> void:
	_emoting = false
	sprite.play("idle_down")

func _ready() -> void:
	add_to_group("npcs")
	interaction_label.visible = false

func _physics_process(delta: float) -> void:
	# Hard frozen (onlookers etc) — do nothing
	if _frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Scripted walk completes uninterrupted
	if _walking_to:
		var dir = (_walk_target - global_position).normalized()
		var dist = global_position.distance_to(_walk_target)
		if dist < 5.0:
			_walking_to = false
			velocity = Vector2.ZERO
			emit_signal("walk_finished")
		else:
			velocity = dir * speed
			play_animation(dir)
		move_and_slide()
		return

	# Playing an emote — stay still but don't interrupt the animation
	if _emoting:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Event/dialogue is open — freeze in place
	if DialogueManager.is_open() or EventManager.is_open():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Normal wander behaviour
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
	return dialogue_neutral

func start_dialogue() -> void:
	if not player_nearby:
		return
	face_player()
	var lines = get_dialogue()
	DialogueManager.start(npc_name, lines)

func face_player() -> void:
	if player_ref == null:
		return
	var dir = (player_ref.global_position - global_position).normalized()
	if abs(dir.x) > abs(dir.y):
		sprite.play("walk_right" if dir.x > 0 else "walk_left")
	else:
		sprite.play("walk_bottom" if dir.y > 0 else "walk_top")
	sprite.frame = 0
	sprite.pause()

func choose_new_direction() -> void:
	var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2.ZERO]
	movement_direction = directions.pick_random()
	wander_timer = randf_range(1.0, 3.0)

func play_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		sprite.play("walk_right" if dir.x > 0 else "walk_left")
	else:
		sprite.play("walk_bottom" if dir.y > 0 else "walk_top")
