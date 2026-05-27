extends CanvasLayer
## HUD.gd — Autoload
## Local peace bar: always visible, top-left.
## Global peace bar: hidden until show_map() is called (wired up when map is added).
##
## Add to project.godot autoloads:
##   HUD="*res://HUD.gd"
## Make sure it is listed AFTER PeaceManager and NetworkManager.

# ── Tweak these to match your font sheet ─────────────────────────────────
const FONT_PATH   := "res://assets/font.png"   # your bitmap font after import
const FONT_SIZE   := 16                     # base size; scale up as needed

# ── Bar colours ───────────────────────────────────────────────────────────
const COL_HIGH   := Color("5ecb6b")   # green  ≥ 70
const COL_MID    := Color("e8c63a")   # yellow 40–69
const COL_LOW    := Color("d94f4f")   # red    < 40
const COL_BG     := Color("1a1a2e")   # bar track background
const COL_BORDER := Color("c8b89a")   # panel border / text colour

# ── Nodes ─────────────────────────────────────────────────────────────────
var _local_panel : PanelContainer
var _local_bar   : ProgressBar
var _local_label : Label
var _local_value : Label

var _map_panel   : PanelContainer   # shown when map opens
var _global_bar  : ProgressBar
var _global_label: Label
var _global_value: Label

var _font        : Font = null

# ─────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	layer = 5  # above world, below dialogue (10) and event (20)
	_load_font()
	_build_local_bar()
	_build_global_panel()
	_connect_signals()

# ── Font ──────────────────────────────────────────────────────────────────
func _load_font() -> void:
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH)
	# If nil (not yet imported as font) the labels just use Godot's default.
	# See FONT IMPORT INSTRUCTIONS at the bottom of this file.

func _apply_font(label: Label, size: int = FONT_SIZE) -> void:
	if _font:
		label.add_theme_font_override("font", _font)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", COL_BORDER)

# ── Local peace bar (top-left, always visible) ────────────────────────────
func _build_local_bar() -> void:
	_local_panel = PanelContainer.new()
	_local_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_local_panel.position = Vector2(12, 12)
	_local_panel.custom_minimum_size = Vector2(130, 0)
	_style_panel(_local_panel)
	add_child(_local_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	_local_panel.add_child(vbox)

	# Header row
	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 0)
	vbox.add_child(header_row)

	_local_label = Label.new()
	_local_label.text = "TOWN PEACE"
	_local_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_font(_local_label, FONT_SIZE)
	header_row.add_child(_local_label)

	_local_value = Label.new()
	_local_value.text = "60"
	_local_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_apply_font(_local_value, FONT_SIZE)
	header_row.add_child(_local_value)

	_local_bar = _make_bar(60)
	vbox.add_child(_local_bar)

# ── Global peace panel (hidden; shown when map is opened) ─────────────────
func _build_global_panel() -> void:
	_map_panel = PanelContainer.new()
	# Centred — adjust once map scene exists
	_map_panel.set_anchors_preset(Control.PRESET_CENTER)
	_map_panel.offset_left   = -160
	_map_panel.offset_right  =  160
	_map_panel.offset_top    = -120
	_map_panel.offset_bottom =  120
	_style_panel(_map_panel)
	_map_panel.visible = false
	add_child(_map_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_map_panel.add_child(vbox)

	var title := Label.new()
	title.text = "— WORLD MAP —"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_apply_font(title, FONT_SIZE + 2)
	vbox.add_child(title)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	vbox.add_child(row)

	_global_label = Label.new()
	_global_label.text = "WORLD PEACE"
	_global_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_font(_global_label, FONT_SIZE)
	row.add_child(_global_label)

	_global_value = Label.new()
	_global_value.text = "60"
	_global_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_apply_font(_global_value, FONT_SIZE)
	row.add_child(_global_value)

	_global_bar = _make_bar(60)
	_global_bar.custom_minimum_size = Vector2(280, 14)
	vbox.add_child(_global_bar)

	# Placeholder text — replace with actual map art later
	var placeholder := Label.new()
	placeholder.text = "\n[ map art goes here ]"
	placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	placeholder.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5))
	_apply_font(placeholder, FONT_SIZE)
	vbox.add_child(placeholder)

# ── Map toggle (call from player input) ──────────────────────────────────
func show_map() -> void:
	_map_panel.visible = true

func hide_map() -> void:
	_map_panel.visible = false

func toggle_map() -> void:
	_map_panel.visible = !_map_panel.visible

func is_map_open() -> bool:
	return _map_panel.visible

# ── Signal wiring ─────────────────────────────────────────────────────────
func _connect_signals() -> void:
	PeaceManager.peace_changed.connect(_on_peace_changed)
	NetworkManager.auth_ok.connect(_on_auth_ok)

func _on_auth_ok(snapshot: Dictionary) -> void:
	var gs := int(snapshot.get("global_score", 60))
	_set_bar(_global_bar, _global_value, gs)

func _on_peace_changed(town_id: String, local_score: int, global_score: int) -> void:
	_set_bar(_local_bar,  _local_value,  local_score)
	_set_bar(_global_bar, _global_value, global_score)

# ── Update a bar + its value label ────────────────────────────────────────
func _set_bar(bar: ProgressBar, value_label: Label, score: int) -> void:
	bar.value = score
	value_label.text = str(score)

	var colour: Color
	if score >= 70:
		colour = COL_HIGH
	elif score >= 40:
		colour = COL_MID
	else:
		colour = COL_LOW

	var fill := StyleBoxFlat.new()
	fill.bg_color = colour
	fill.corner_radius_top_left     = 2
	fill.corner_radius_top_right    = 2
	fill.corner_radius_bottom_left  = 2
	fill.corner_radius_bottom_right = 2
	bar.add_theme_stylebox_override("fill", fill)

# ── Set local town name when entering a town ──────────────────────────────
func set_town_name(name: String) -> void:
	_local_label.text = name.to_upper() + " PEACE" if name != "" else "TOWN PEACE"

# ── Helper: styled panel ──────────────────────────────────────────────────
func _style_panel(panel: PanelContainer) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.14, 0.88)
	style.border_width_left   = 1
	style.border_width_right  = 1
	style.border_width_top    = 1
	style.border_width_bottom = 1
	style.border_color = COL_BORDER
	style.corner_radius_top_left     = 3
	style.corner_radius_top_right    = 3
	style.corner_radius_bottom_left  = 3
	style.corner_radius_bottom_right = 3
	style.content_margin_left   = 8
	style.content_margin_right  = 8
	style.content_margin_top    = 6
	style.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", style)

# ── Helper: styled progress bar ──────────────────────────────────────────
func _make_bar(initial_value: int) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(110, 10)
	bar.max_value = 100
	bar.value = initial_value
	bar.show_percentage = false

	var bg := StyleBoxFlat.new()
	bg.bg_color = COL_BG
	bg.corner_radius_top_left     = 2
	bg.corner_radius_top_right    = 2
	bg.corner_radius_bottom_left  = 2
	bg.corner_radius_bottom_right = 2
	bar.add_theme_stylebox_override("background", bg)

	_set_bar(bar, Label.new(), initial_value)  # sets initial fill colour
	return bar
