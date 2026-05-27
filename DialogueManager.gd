extends CanvasLayer
## DialogueManager.gd — Autoload
## Classic RPG bottom dialogue box using dialogue_box.png as NinePatch.

signal dialogue_finished

const FONT_PATH    := "res://font.png"
const DBOX_PATH    := "res://assets/dialogue_box.png"
const FONT_SIZE    := 16
const COL_NAME     := Color("a8c8ff")
const COL_TEXT     := Color("1a1008")   # dark ink — readable on the light panel

var _panel      : PanelContainer
var _name_label : Label
var _text_label : Label
var _next_btn   : Button

var _lines : Array[String] = []
var _index : int = 0
var _font  : Font = null

# ─────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	layer = 10
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

	# Full-width bottom bar — classic RPG position
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_top    = -148
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
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	# Speaker name
	_name_label = Label.new()
	_apply_font(_name_label, FONT_SIZE - 2, COL_NAME)
	vbox.add_child(_name_label)

	# Dialogue body
	_text_label = Label.new()
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_apply_font(_text_label, FONT_SIZE, COL_TEXT)
	_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_text_label)

	# Continue button — right-aligned
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	vbox.add_child(btn_row)

	_next_btn = Button.new()
	_next_btn.text = "▶  continue"
	_apply_font(_next_btn, FONT_SIZE - 2, COL_TEXT)
	_next_btn.add_theme_stylebox_override("normal",  _make_btn_style())
	_next_btn.add_theme_stylebox_override("hover",   _make_btn_style(true))
	_next_btn.add_theme_stylebox_override("pressed", _make_btn_style(true))
	_next_btn.pressed.connect(_on_next)
	btn_row.add_child(_next_btn)

	_panel.visible = false

# ── Public API ────────────────────────────────────────────────────────────
func start(npc_name: String, lines: Array[String]) -> void:
	_lines = lines
	_index = 0
	_name_label.text = npc_name.to_upper()
	_name_label.visible = npc_name != ""
	_panel.visible = true
	_show_line()

func is_open() -> bool:
	return _panel.visible

# ── Internal ──────────────────────────────────────────────────────────────
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
	dialogue_finished.emit()

# ── Styles ────────────────────────────────────────────────────────────────
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
	# Fallback
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
	s.content_margin_top    = 3.0
	s.content_margin_bottom = 3.0
	return s
