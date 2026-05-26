extends Node

# Local peace per town: { "town_01": 60, "town_02": 60, ... }
var _local: Dictionary = {}
var _global: float = 60.0

func get_local(town_id: String) -> int:
	return _local.get(town_id, 60)

func get_global() -> float:
	return _global

func apply_action(delta: int, town_id: String) -> void:
	var current = _local.get(town_id, 60)
	_local[town_id] = clampi(current + delta, 0, 100)
	# Global is nudged by 40% of every local change
	_global = clampf(_global + float(delta) * 0.4, 0.0, 100.0)
	print("[PeaceManager] %s: %d | Global: %.0f" % [town_id, _local[town_id], _global])
