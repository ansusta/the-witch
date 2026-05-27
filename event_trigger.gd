extends Area2D
@export var event_id: String = "town01_entrance_fight"
@export var villager_a: CharacterBody2D = null
@export var villager_b: CharacterBody2D = null
@export var onlookers: Array[CharacterBody2D] = []
var _triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _triggered or not body.is_in_group("player"):
		return
	_triggered = true
	await _setup_scene()
	EventManager.play_event(Town01Events.entrance_fight())

func _setup_scene() -> void:
	var meeting_point = (villager_a.global_position + villager_b.global_position) / 2.0

	# Freeze onlookers immediately
	for npc in onlookers:
		if npc:
			npc.freeze()

	# Walk villagers to meeting point
	if villager_a:
		villager_a.walk_to(meeting_point + Vector2(-80, 0))
	if villager_b:
		villager_b.walk_to(meeting_point + Vector2(80, 0))

	# Wait until BOTH have actually arrived
	await villager_a.walk_finished
	await villager_b.walk_finished

	# Start both emotes at the same time
	if villager_a:
		villager_a.play_emote_loop("fight")
	if villager_b:
		villager_b.play_emote_loop("fight")

	# Let them fight for a moment before dialogue starts
	await get_tree().create_timer(1.5).timeout
