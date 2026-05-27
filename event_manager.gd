extends CanvasLayer
## event_manager.gd — Autoload
## Scripted events with narration + choices. Bottom-anchored RPG style.
## Choice steps get extra height to fit the option buttons.

signal event_finished

const FONT_PATH := "res://font.png"
const DBOX_PATH := "res://assets/dialogue_box.png"
const FONT_SIZE := 16
const COL_NAME  := Color("a8c8ff")
const COL_TEXT  := Color("1a1008")
const COL_SPKR  := Color("3a2000")

var _panel             : PanelContainer
var _speaker_label     : Label
var _text_label        : Label
var _buttons_container : HBoxContainer
var _current_event     : Dictionary
var _current_step      : int = 0
var _font              : Font = null

# ─────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	layer = 20
	_load_font()
	_build_ui()

func _load_font() -> void:
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH)

func _apply_font(node: Control, size: int = FONT_SIZE, colour: Color = COL_TEXT) -> void:
	if _font:
		node.add_theme_font_override("font", _font)
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", colour)

# ── Build UI ──────────────────────────────────────────────────────────────
func _build_ui() -> void:
	_panel = PanelContainer.new()

	# Full-width bottom bar — same position as DialogueManager
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_top    = -168   # slightly taller than dialogue to fit buttons
	_panel.offset_bottom = -8
	_panel.offset_left   = 8
	_panel.offset_right  = -8

	_panel.add_theme_stylebox_override("panel", _make_panel_style())
	add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   16)
	margin.add_theme_constant_override("margin_right",  16)
	margin.add_theme_constant_override("margin_top",    10)
	margin.add_theme_constant_override("margin_bottom", 10)
	_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	# Speaker name row
	_speaker_label = Label.new()
	_apply_font(_speaker_label, FONT_SIZE - 2, COL_NAME)
	vbox.add_child(_speaker_label)

	# Body text
	_text_label = Label.new()
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_apply_font(_text_label, FONT_SIZE, COL_TEXT)
	_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_text_label)

	# Button row — wraps for many choices
	_buttons_container = HBoxContainer.new()
	_buttons_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_buttons_container.add_theme_constant_override("separation", 8)
	vbox.add_child(_buttons_container)

	_panel.visible = false

# ── Public API ────────────────────────────────────────────────────────────
func play_event(event: Dictionary) -> void:
	_current_event = event
	_current_step  = 0
	_process_step()

func is_open() -> bool:
	return _panel.visible

# ── Step processor ────────────────────────────────────────────────────────
func _process_step() -> void:
	if _current_step >= _current_event.steps.size():
		_close()
		return

	var step: Dictionary = _current_event.steps[_current_step]

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
		"close":
			_close()
		_:
			var speaker: String = str(step.get("type", "")).replace("_", " ").capitalize()
			_show_narration(speaker, step.text)

func _show_narration(speaker: String, text: String) -> void:
	_clear_buttons()
	_speaker_label.text = speaker.to_upper() if speaker != "" else ""
	_speaker_label.visible = speaker != ""
	_text_label.text = text
	var btn := _make_button("▶  continue")
	btn.pressed.connect(_on_continue)
	_buttons_container.add_child(btn)
	_panel.visible = true

func _show_choice(text: String, options: Array) -> void:
	_clear_buttons()
	_speaker_label.visible = false
	_text_label.text = text
	for option in options:
		var btn := _make_button(option.label)
		btn.pressed.connect(_on_choice.bind(option))
		_buttons_container.add_child(btn)
	_panel.visible = true

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
	event_finished.emit()

# ── Styles ────────────────────────────────────────────────────────────────
func _make_button(label_text: String) -> Button:
	var btn := Button.new()
	btn.text = label_text
	_apply_font(btn, FONT_SIZE - 2, COL_SPKR)
	btn.add_theme_stylebox_override("normal",  _make_btn_style())
	btn.add_theme_stylebox_override("hover",   _make_btn_style(true))
	btn.add_theme_stylebox_override("pressed", _make_btn_style(true))
	return btn

func _make_panel_style() -> StyleBox:
	if ResourceLoader.exists(DBOX_PATH):
		var tex : Texture2D = load(DBOX_PATH)
		var s := StyleBoxTexture.new()
		s.texture = tex
		s.texture_margin_left   = 8.0
		s.texture_margin_right  = 8.0
		s.texture_margin_top    = 8.0
		s.texture_margin_bottom = 28.0
		s.content_margin_left   = 12.0
		s.content_margin_right  = 12.0
		s.content_margin_top    = 8.0
		s.content_margin_bottom = 8.0
		return s
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.88, 0.88, 0.86)
	s.border_color = Color(0.1, 0.05, 0.0)
	s.set_border_width_all(2)
	s.set_corner_radius_all(4)
	s.set_content_margin_all(12)
	return s

func _make_btn_style(hover: bool = false) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.75, 0.72, 0.68) if not hover else Color(0.60, 0.57, 0.53)
	s.set_border_width_all(1)
	s.border_color = Color(0.1, 0.05, 0.0)
	s.set_corner_radius_all(2)
	s.content_margin_left   = 8.0
	s.content_margin_right  = 8.0
	s.content_margin_top    = 4.0
	s.content_margin_bottom = 4.0
	return s
