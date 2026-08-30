extends Node
## Simplified port of src/game/empire.zig rackets / respect.

enum RacketKind { SPEAKEASY, PROTECTION, SMUGGLING, NUMBERS, DOCKS }

var rackets: Array[Dictionary] = []
var street_respect: int = 10

func _ready() -> void:
	# BETA starter: speakeasy Little Italy, protection Hell's Kitchen
	add_racket(RacketKind.SPEAKEASY, "little_italy")
	add_racket(RacketKind.PROTECTION, "hells_kitchen")

func add_racket(kind: RacketKind, district_id: String) -> void:
	rackets.append({
		"kind": kind,
		"district_id": district_id,
		"level": 1,
		"crew_assigned": 1,
	})

func kind_name(kind: RacketKind) -> String:
	match kind:
		RacketKind.SPEAKEASY:
			return "Speakeasy"
		RacketKind.PROTECTION:
			return "Protection"
		RacketKind.SMUGGLING:
			return "Smuggling"
		RacketKind.NUMBERS:
			return "Numbers"
		RacketKind.DOCKS:
			return "Docks"
	return "?"

func collect_all() -> int:
	var total := 0
	for r in rackets:
		var base: int = Balance.COLLECT_BASE * int(r["level"])
		total += base * int(r["crew_assigned"])
	if total > 0:
		GameState.add_cash(total)
		GameState.toast.emit("Collected $%d" % total, 2.5)
	return total

earn_street_respect(1) -> void:  # syntax error - fix
	pass
