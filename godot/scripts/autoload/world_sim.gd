extends Node
## Heat decay, rival pressure, payday, wanted tick — port of Zig living/heat/rival/payday.

var rival_pressure: int = 20
var loan_due: int = 0
var stash_cash: int = 0
var payday_days: int = 0
var ambush_cd: float = Balance.AMBUSH_CHECK_INTERVAL
var rival_cd: float = Balance.RIVAL_INTERVAL
var news_cd: float = 75.0

const NAMES := ["Vito", "Nicky", "Paulie", "Angelo", "Frankie", "Sonny", "Rocco", "Mikey"]

func _ready() -> void:
	GameState.day_advanced.connect(_on_day)

func _process(delta: float) -> void:
	_tick_wanted(delta)
	_tick_rival(delta)
	_tick_ambush(delta)
	_tick_news(delta)

func _on_day(day: int) -> void:
	payday_days += 1
	if payday_days % 7 == 0:
		Empire.payday()
	if loan_due > 0:
		var interest := loan_due / 10
		loan_due += interest
		GameState.feed_line.emit("Loan still due $%d" % loan_due)
	rival_pressure = mini(100, rival_pressure + 3)
	if rival_pressure > 60:
		GameState.raise_district_heat(GameState.current_district_id, 6)
		GameState.feed_line.emit("Rival pressure — control slips")

func _tick_wanted(delta: float) -> void:
	var heat := GameState.current_heat()
	if heat >= 70 and GameState.wanted_level < 3 and randf() < delta * 0.04:
		GameState.set_wanted(GameState.wanted_level + 1)
		GameState.toast.emit("Wanted rose", 1.8)
	elif heat < 20 and GameState.wanted_level > 0 and randf() < delta * 0.015:
		GameState.set_wanted(GameState.wanted_level - 1)

func _tick_rival(delta: float) -> void:
	rival_cd -= delta
	if rival_cd > 0.0:
		return
	rival_cd = Balance.RIVAL_INTERVAL
	if rival_pressure > 40 and randf() < 0.35:
		GameState.raise_district_heat(GameState.current_district_id, 5)
		GameState.feed_line.emit("Rival crew working your block")

func _tick_ambush(delta: float) -> void:
	ambush_cd -= delta
	if ambush_cd > 0.0:
		return
	ambush_cd = Balance.AMBUSH_CHECK_INTERVAL
	var chance := 0.08 + float(GameState.current_heat()) * 0.002 + float(GameState.wanted_level) * 0.04
	if randf() < chance:
		GameState.damage(12 + randi() % 10)
		GameState.raise_district_heat(GameState.current_district_id, 8)
		GameState.toast.emit("AMBUSH!", 2.5)
		GameState.feed_line.emit("Ambushed")

func _tick_news(delta: float) -> void:
	news_cd -= delta
	if news_cd > 0.0:
		return
	news_cd = 80.0
	var lines := [
		"Paper: raids on the waterfront",
		"Paper: new captain in the 1-0",
		"Radio: keep your head down tonight",
		"Word is Dutch's boys are restless",
	]
	GameState.feed_line.emit(lines[randi() % lines.size()])

func ease_rival(amount: int) -> void:
	rival_pressure = maxi(0, rival_pressure - amount)

func deposit_stash(amount: int) -> bool:
	if GameState.treasury < amount:
		return false
	GameState.add_cash(-amount)
	stash_cash += amount
	return true

func withdraw_stash(amount: int) -> int:
	var take := mini(amount, stash_cash)
	stash_cash -= take
	GameState.add_cash(take)
	return take

func withdraw_all_stash() -> int:
	return withdraw_stash(stash_cash)

func borrow(amount: int) -> bool:
	if loan_due > 0:
		return repay()
	if amount > Balance.LOAN_MAX:
		amount = Balance.LOAN_MAX
	loan_due = amount + amount / 5
	GameState.add_cash(amount)
	GameState.toast.emit("Borrowed $%d" % amount, 2.0)
	return true

func repay() -> bool:
	if loan_due <= 0 or GameState.treasury < loan_due:
		return false
	GameState.add_cash(-loan_due)
	loan_due = 0
	GameState.toast.emit("Loan repaid", 2.0)
	return true

func random_crew_name() -> String:
	return NAMES[randi() % NAMES.size()]

func to_save_dict() -> Dictionary:
	return {
		"rival_pressure": rival_pressure,
		"loan_due": loan_due,
		"stash_cash": stash_cash,
		"payday_days": payday_days,
	}

func from_save_dict(data: Dictionary) -> void:
	rival_pressure = data.get("rival_pressure", 20)
	loan_due = data.get("loan_due", 0)
	stash_cash = data.get("stash_cash", 0)
	payday_days = data.get("payday_days", 0)
