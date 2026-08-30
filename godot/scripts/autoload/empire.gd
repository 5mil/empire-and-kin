extends Node
## Full port of src/game/empire.zig — rackets, crew slots, collect, upgrade, respect.

signal rackets_changed
signal crew_changed
signal respect_changed(value: int)

enum RacketKind { SPEAKEASY, PROTECTION, SMUGGLING, NUMBERS, DOCKS, LABOR_UNION }

var rackets: Array[Dictionary] = []
var street_respect: int = 10
var family_favor: int = 5
var crew: Array[Dictionary] = []
var collect_cooldown: float = 0.0

func _ready() -> void:
	_seed_starter()

func _process(delta: float) -> void:
	if collect_cooldown > 0.0:
		collect_cooldown -= delta

func _seed_starter() -> void:
	crew.clear()
	crew.append(_member("Vito", 2))
	crew.append(_member("Sal", 1))
	crew.append(_member("Tommy", 1))
	rackets.clear()
	add_racket(RacketKind.SPEAKEASY, "little_italy")
	add_racket(RacketKind.PROTECTION, "hells_kitchen")
	assign_crew(0, 1)
	crew_changed.emit()
	rackets_changed.emit()

func _member(mname: String, muscle: int) -> Dictionary:
	return {"name": mname, "muscle": muscle, "morale": 70, "assigned_racket": -1}

func add_racket(kind: RacketKind, district_id: String) -> int:
	rackets.append({
		"kind": kind,
		"district_id": district_id,
		"level": 1,
		"crew_assigned": 0,
		"heat_on_collect": 4,
	})
	var idx := rackets.size() - 1
	rackets_changed.emit()
	return idx

func kind_name(kind: RacketKind) -> String:
	match kind:
		RacketKind.SPEAKEASY: return "Speakeasy"
		RacketKind.PROTECTION: return "Protection"
		RacketKind.SMUGGLING: return "Smuggling"
		RacketKind.NUMBERS: return "Numbers"
		RacketKind.DOCKS: return "Docks"
		RacketKind.LABOR_UNION: return "Labor union"
	return "?"

func assign_crew(racket_i: int, count: int) -> void:
	if racket_i < 0 or racket_i >= rackets.size():
		return
	rackets[racket_i]["crew_assigned"] = maxi(0, count)
	var left := count
	for i in crew.size():
		if left > 0 and int(crew[i]["assigned_racket"]) < 0:
			crew[i]["assigned_racket"] = racket_i
			left -= 1
	crew_changed.emit()
	rackets_changed.emit()

func upgrade_racket(i: int) -> bool:
	if i < 0 or i >= rackets.size():
		return false
	if GameState.treasury < Balance.RACKET_UPGRADE_COST:
		return false
	GameState.add_cash(-Balance.RACKET_UPGRADE_COST)
	rackets[i]["level"] = int(rackets[i]["level"]) + 1
	GameState.toast.emit("Racket upgraded", 2.0)
	rackets_changed.emit()
	return true

func collect_all() -> int:
	if collect_cooldown > 0.0:
		GameState.toast.emit("Collections cooling off", 1.5)
		return 0
	var total := 0
	for r in rackets:
		var base: int = Balance.COLLECT_BASE * int(r["level"])
		var crew_n: int = maxi(1, int(r["crew_assigned"]))
		total += base * crew_n / 2
		GameState.raise_district_heat(str(r["district_id"]), int(r["heat_on_collect"]))
	if total > 0:
		GameState.add_cash(total)
		GameState.toast.emit("Collected $%d" % total, 2.5)
		collect_cooldown = 20.0
	return total

func recruit(member_name: String) -> bool:
	if GameState.treasury < Balance.RECRUIT_COST:
		return false
	if crew.size() >= 12:
		return false
	GameState.add_cash(-Balance.RECRUIT_COST)
	crew.append(_member(member_name, 1 + (randi() % 3)))
	crew_changed.emit()
	GameState.toast.emit("Recruited %s" % member_name, 2.0)
	return true

func payday() -> int:
	var cost := 0
	for m in crew:
		cost += 80 + int(m["muscle"]) * 40
	if cost <= 0:
		return 0
	GameState.add_cash(-cost)
	for i in crew.size():
		crew[i]["morale"] = mini(100, int(crew[i]["morale"]) + 8)
	GameState.toast.emit("Crew payday -$%d" % cost, 2.5)
	GameState.feed_line.emit("Crew payday")
	crew_changed.emit()
	return cost

func earn_street_respect(amount: int) -> void:
	street_respect = clampi(street_respect + amount, 0, 100)
	respect_changed.emit(street_respect)

func earn_favor(amount: int) -> void:
	family_favor = clampi(family_favor + amount, 0, 100)

func to_save_dict() -> Dictionary:
	return {
		"rackets": rackets.duplicate(true),
		"crew": crew.duplicate(true),
		"street_respect": street_respect,
		"family_favor": family_favor,
	}

func from_save_dict(data: Dictionary) -> void:
	if data.has("rackets"):
		rackets = data["rackets"]
	if data.has("crew"):
		crew = data["crew"]
	street_respect = data.get("street_respect", 10)
	family_favor = data.get("family_favor", 5)
	rackets_changed.emit()
	crew_changed.emit()
	respect_changed.emit(street_respect)
