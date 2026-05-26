extends CanvasLayer

signal dialogue_finished

var _panel: PanelContainer
var _name_label: Label
var _text_label: Label
var _next_btn: Button

var _lines: Array[String] = []
var _index: int = 0

func _ready() -> void:
	# Build the UI in code so you don't need a separate scene
	layer = 10

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(500, 120)
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_top = -140
	_panel.offset_bottom = -20
	_panel.offset_left = 80
	_panel.offset_right = -80
	add_child(_panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_panel.add_child(vbox)

	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(_name_label)

	_text_label = Label.new()
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(_text_label)

	_next_btn = Button.new()
	_next_btn.text = "Next  ▶"
	_next_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	_next_btn.pressed.connect(_on_next)
	vbox.add_child(_next_btn)

	_panel.visible = false

func start(npc_name: String, lines: Array[String]) -> void:
	_lines = lines
	_index = 0
	_name_label.text = npc_name
	_panel.visible = true
	_show_line()

func _show_line() -> void:
	if _index < _lines.size():
		_text_label.text = _lines[_index]
	else:
		_close()

func _on_next() -> void:
	_index += 1
	_show_line()

func _close() -> void:
	_panel.visible = false
	emit_signal("dialogue_finished")

func is_open() -> bool:
	return _panel.visible
