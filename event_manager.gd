extends CanvasLayer

signal event_finished
signal quest_started(quest_id: String)

var _panel: PanelContainer
var _speaker_label: Label
var _text_label: Label
var _buttons_container: HBoxContainer
var _toast: Label
var _current_event: Dictionary
var _current_step: int = 0

func _ready() -> void:
	layer = 20

	# --- Main dialogue panel — anchored to BOTTOM ---
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(0, 150)
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_top = -180
	_panel.offset_bottom = -10
	_panel.offset_left = 20
	_panel.offset_right = -20
	add_child(_panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_panel.add_child(vbox)

	# Speaker name (blue, hidden for plain narration)
	_speaker_label = Label.new()
	_speaker_label.add_theme_font_size_override("font_size", 12)
	_speaker_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	vbox.add_child(_speaker_label)

	_text_label = Label.new()
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.add_theme_font_size_override("font_size", 13)
	_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_text_label)

	_buttons_container = HBoxContainer.new()
	_buttons_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_buttons_container.add_theme_constant_override("separation", 10)
	vbox.add_child(_buttons_container)

	_panel.visible = false

	# --- Quest toast — top center ---
	_toast = Label.new()
	_toast.add_theme_font_size_override("font_size", 13)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_toast.offset_top = 16
	_toast.offset_bottom = 46
	_toast.modulate.a = 0.0
	add_child(_toast)

func play_event(event: Dictionary) -> Signal:
	_current_event = event
	_current_step = 0
	_process_step()
	return event_finished

func _process_step() -> void:
	if _current_step >= _current_event.steps.size():
		_close()
		return

	var step = _current_event.steps[_current_step]

	match step.type:
		"narration":
			_show_narration("", step.text)
		"choice":
			_show_choice(step.text, step.options)
		"peace_effect":
			PeaceManager.apply_action(step.delta, step.get("town_id", "town_01"))
			if step.has("go_to"):
				_current_step = step.go_to
			else:
				_current_step += 1
			_process_step()
		"quest_trigger":
			_trigger_quest(step.quest_id)
			_current_step += 1
			_process_step()
		"close":
			_close()
		_:
			# Any other type = speaker line (villager_a, villager_b, you...)
			var speaker = step.type.replace("_", " ").capitalize()
			_show_narration(speaker, step.text)

func _show_narration(speaker: String, text: String) -> void:
	_clear_buttons()
	_speaker_label.text = speaker
	_speaker_label.visible = speaker != ""
	_text_label.text = text
	var btn = Button.new()
	btn.text = "Continue  ▶"
	btn.pressed.connect(_on_continue)
	_buttons_container.add_child(btn)
	_panel.visible = true

func _show_choice(text: String, options: Array) -> void:
	_clear_buttons()
	_speaker_label.visible = false
	_text_label.text = text
	for option in options:
		var btn = Button.new()
		btn.text = option.label
		btn.pressed.connect(_on_choice.bind(option))
		_buttons_container.add_child(btn)
	_panel.visible = true

func _trigger_quest(quest_id: String) -> void:
	emit_signal("quest_started", quest_id)
	_show_toast("✦  New quest: " + quest_id.replace("_", " ").capitalize())
	print("[QuestManager] Quest started: ", quest_id)

func _show_toast(text: String) -> void:
	_toast.text = text
	var tween = create_tween()
	tween.tween_property(_toast, "modulate:a", 1.0, 0.3)
	tween.tween_interval(2.5)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.5)

func _on_continue() -> void:
	_current_step += 1
	_process_step()

func _on_choice(option: Dictionary) -> void:
	_current_step = option.go_to
	_process_step()

func _clear_buttons() -> void:
	for child in _buttons_container.get_children():
		child.queue_free()

func _close() -> void:
	_panel.visible = false
	emit_signal("event_finished")

func is_open() -> bool:
	return _panel.visible
