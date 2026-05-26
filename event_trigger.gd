extends Area2D

@export var event_id: String = "town01_entrance_fight"
var _triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _triggered:
		return
	if not body.is_in_group("player"):
		return
	_triggered = true

	match event_id:
		"town01_entrance_fight":
			EventManager.play_event(Town01Events.entrance_fight())
