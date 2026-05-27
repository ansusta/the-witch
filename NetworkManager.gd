extends Node

# ── NetworkManager.gd ─────────────────────────────────────────────────────
# Autoload. Add to project.godot:
#   NetworkManager="*res://NetworkManager.gd"
#
# Handles the WebSocket connection to the Herm server.
# All other scripts talk to this — they never touch the socket directly.
# ─────────────────────────────────────────────────────────────────────────

# Change this to your Render URL once deployed
const SERVER_URL := "ws://localhost:3000"

# Set this before connecting — "herm_1" or "herm_2"
var player_id: String = ""

# ── Signals — other scripts connect to these ─────────────────────────────
signal connected()
signal disconnected()
signal auth_ok(snapshot: Dictionary)           # first successful auth
signal peace_updated(state: Dictionary)        # {local_score, global_score, town_id}
signal zone_blocked(data: Dictionary)          # other player is in that zone
signal zone_entered(zone_id: String)           # server confirmed our entry
signal player_zone_changed(pid: String, zone_id)  # other player moved
signal wall_messages_received(town_id, messages: Array)
signal wall_new_message(town_id, message: Dictionary)
signal world_state_snapshot(town_id, objects: Array)
signal world_state_changed(record: Dictionary)
signal server_error(code: String, message: String)

# ── Internal ──────────────────────────────────────────────────────────────
var _socket := WebSocketPeer.new()
var _state := WebSocketPeer.STATE_CLOSED
var _retry_timer: float = 0.0
var _retry_delay: float = 3.0
var _authed: bool = false

# ─────────────────────────────────────────────────────────────────────────
func connect_to_server(pid: String) -> void:
	player_id = pid
	_do_connect()

func _do_connect() -> void:
	_authed = false
	var err = _socket.connect_to_url(SERVER_URL)
	if err != OK:
		push_error("[NetworkManager] connect_to_url failed: %d" % err)

func _process(delta: float) -> void:
	_socket.poll()
	var new_state = _socket.get_ready_state()

	if new_state != _state:
		_on_state_changed(new_state)
		_state = new_state

	# Drain all incoming packets
	while _socket.get_available_packet_count() > 0:
		var raw = _socket.get_packet().get_string_from_utf8()
		_handle_packet(raw)

	# Auto-reconnect if disconnected
	if _state == WebSocketPeer.STATE_CLOSED and player_id != "":
		_retry_timer -= delta
		if _retry_timer <= 0.0:
			_retry_timer = _retry_delay
			print("[NetworkManager] retrying connection…")
			_do_connect()

func _on_state_changed(new_state: int) -> void:
	match new_state:
		WebSocketPeer.STATE_OPEN:
			print("[NetworkManager] connected")
			emit_signal("connected")
			_send({ "type": "auth", "player_id": player_id })

		WebSocketPeer.STATE_CLOSED:
			print("[NetworkManager] disconnected")
			_authed = false
			emit_signal("disconnected")

# ── Packet handler ────────────────────────────────────────────────────────
func _handle_packet(raw: String) -> void:
	var json = JSON.new()
	if json.parse(raw) != OK:
		push_error("[NetworkManager] bad JSON: " + raw)
		return

	var msg: Dictionary = json.get_data()
	var t: String = msg.get("type", "")

	match t:
		"auth_ok":
			_authed = true
			print("[NetworkManager] auth ok as %s" % player_id)
			emit_signal("auth_ok", msg)

		"peace_state":
			emit_signal("peace_updated", msg)

		"zone_blocked":
			emit_signal("zone_blocked", msg)

		"zone_entered":
			emit_signal("zone_entered", msg.get("zone_id", ""))

		"player_zone_update":
			emit_signal("player_zone_changed", msg.get("player_id", ""), msg.get("zone_id"))

		"wall_messages":
			emit_signal("wall_messages_received", msg.get("town_id"), msg.get("messages", []))

		"wall_new_message":
			emit_signal("wall_new_message", msg.get("town_id"), msg.get("message", {}))

		"wall_post_ok":
			pass  # optional: confirm UI

		"world_state_snapshot":
			emit_signal("world_state_snapshot", msg.get("town_id"), msg.get("objects", []))

		"world_state_update", "world_state_ok":
			emit_signal("world_state_changed", msg)

		"error":
			push_error("[NetworkManager] server error %s: %s" % [msg.get("code"), msg.get("message")])
			emit_signal("server_error", msg.get("code", ""), msg.get("message", ""))

		_:
			print("[NetworkManager] unhandled type: %s" % t)

# ── Public send helpers ───────────────────────────────────────────────────

func request_zone_enter(zone_id: String) -> void:
	_send({ "type": "zone_enter", "zone_id": zone_id })

func request_zone_leave() -> void:
	_send({ "type": "zone_leave" })

func request_peace(town_id: int) -> void:
	_send({ "type": "peace_request", "town_id": town_id })

func send_peace_delta(town_id: int, delta: int, description: String = "") -> void:
	_send({
		"type": "peace_delta",
		"town_id": town_id,
		"delta": delta,
		"description": description
	})

func post_wall_message(town_id: int, content: String, pos: Vector2) -> void:
	_send({
		"type": "wall_post",
		"town_id": town_id,
		"content": content,
		"pos_x": pos.x,
		"pos_y": pos.y
	})

func fetch_wall_messages(town_id: int) -> void:
	_send({ "type": "wall_fetch", "town_id": town_id })

func set_world_object_state(object_id: String, town_id: int, object_type: String, state: String) -> void:
	_send({
		"type": "world_state_set",
		"object_id": object_id,
		"town_id": town_id,
		"object_type": object_type,
		"state": state
	})

func fetch_world_state(town_id: int) -> void:
	_send({ "type": "world_state_fetch", "town_id": town_id })

func is_connected_and_authed() -> bool:
	return _authed and _state == WebSocketPeer.STATE_OPEN

# ── Internal send ─────────────────────────────────────────────────────────
func _send(payload: Dictionary) -> void:
	if _state != WebSocketPeer.STATE_OPEN:
		push_warning("[NetworkManager] tried to send while not connected")
		return
	var text = JSON.stringify(payload)
	_socket.send_text(text)
