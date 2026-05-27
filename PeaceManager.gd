extends Node

# ── PeaceManager.gd (networked version) ──────────────────────────────────
# Drop-in replacement for the local PeaceManager.
# Still exposes get_local() / get_global() / apply_action() so all your
# existing EventManager calls keep working unchanged.
#
# How it works:
#  - apply_action()  → sends delta to server → server writes Supabase
#  - Server broadcasts updated state → we cache it here
#  - get_local() / get_global() → read from local cache
# ─────────────────────────────────────────────────────────────────────────

signal peace_changed(town_id, local_score: int, global_score: int)

# Local cache  { "town_01": 60, ... }
var _local: Dictionary = {}
var _global: float = 60.0

func _ready() -> void:
	# Listen for server updates
	NetworkManager.peace_updated.connect(_on_peace_updated)
	NetworkManager.auth_ok.connect(_on_auth_ok)

func _on_auth_ok(snapshot: Dictionary) -> void:
	# Snapshot contains global_score; local scores are fetched on demand
	_global = float(snapshot.get("global_score", 60))

func _on_peace_updated(state: Dictionary) -> void:
	var tid = str(state.get("town_id", ""))
	var ls  = int(state.get("local_score", 60))
	var gs  = float(state.get("global_score", 60))
	_local[tid] = ls
	_global = gs
	print("[PeaceManager] %s: %d | Global: %.0f" % [tid, ls, gs])
	emit_signal("peace_changed", tid, ls, gs)

# ── Public API (same as before) ───────────────────────────────────────────

func get_local(town_id: String) -> int:
	return _local.get(town_id, 60)

func get_global() -> float:
	return _global

## Call this from EventManager exactly as before.
## town_id is the STRING key like "town_01".
## Pass an optional human-readable description for the notable_events log.
func apply_action(delta: int, town_id: String, description: String = "") -> void:
	# Optimistic local update so the game feels instant
	var current = _local.get(town_id, 60)
	_local[town_id] = clampi(current + delta, 0, 100)
	_global = clampf(_global + float(delta) * 0.4, 0.0, 100.0)

	# Then tell the server (which will confirm/correct via peace_updated signal)
	# town_id strings like "town_01" need to map to integer DB ids.
	# Simplest approach: strip the prefix and parse, e.g. "town_01" → 1.
	var db_id = _town_string_to_int(town_id)
	NetworkManager.send_peace_delta(db_id, delta, description)

## Fetch the authoritative server value for a town (call when entering a town).
func fetch_from_server(town_id: String) -> void:
	var db_id = _town_string_to_int(town_id)
	NetworkManager.request_peace(db_id)

# ── Helpers ───────────────────────────────────────────────────────────────

## Convert "town_01" → 1, "town_02" → 2, etc.
## If your towns table uses different ids, adjust this.
func _town_string_to_int(town_id: String) -> int:
	var parts = town_id.split("_")
	if parts.size() >= 2:
		return int(parts[parts.size() - 1])
	return 1
