extends Node
## Central state ported from Zig BETA session (empire / city / player / time).
## Maps use real NYC district anchors — see districts.gd.

signal treasury_changed(value: int)
signal heat_changed(district_id: String, heat: int)
signal wanted_changed(level: int)
signal health_changed(value: int)
signal toast(message: String, duration: float)
signal day_advanced(day: int)
signal feed_line(text: String)

enum Era { NYC_1930S, NYC_1980S }

var era: Era = Era.NYC_1930S
var boss_name: String = "Vinnie \"The Chin\""
var treasury: int = Balance.STARTING_TREASURY
var health: int = 100
var calm: int = 70
var control_need: int = 50
var wanted_level: int = 0
var day: int = 1
var clock_hours: float = 8.0  # 0..24
var elapsed: float = 0.0

## Aspiration (from BETA goals)
var aspiration_tier: int = 1
var aspiration_control_target: int = 60
var aspiration_cash_target: int = 5000

var current_district_id: String = "hells_kitchen"
var districts: Dictionary = {}  # id -> DistrictData

var street_event_cd: float = Balance.STREET_EVENT_INTERVAL
var news_cd: float = 60.0
var heal_accum: float = 0.0

func _ready() -> void:
	districts = Districts.create_all()
	feed_line.emit("Welcome to %s" % Districts.display_name(current_district_id))

func _process(delta: float) -> void:
	elapsed += delta
	clock_hours += delta * Balance.TIME_SCALE_DEMO / 3600.0 * 60.0
	if clock_hours >= 24.0:
		clock_hours -= 24.0
		day += 1
		day_advanced.emit(day)
		_on_new_day()

	_tick_heat_decay(delta)
	_tick_heal(delta)
	_tick_street_events(delta)

func era_name() -> String:
	match era:
		Era.NYC_1930S:
			return "1930s New York"
		Era.NYC_1980S:
			return "1980s New York"
	return ""

func clock_string() -> String:
	var h := int(clock_hours) % 24
	var m := int((clock_hours - float(h)) * 60.0)
	return "%02d:%02d" % [h, m]

func add_cash(amount: int) -> void:
	treasury = maxi(0, treasury + amount)
	treasury_changed.emit(treasury)

func set_wanted(level: int) -> void:
	wanted_level = clampi(level, 0, 5)
	wanted_changed.emit(wanted_level)

func damage(amount: int) -> void:
	health = clampi(health - amount, 0, 100)
	health_changed.emit(health)

func heal(amount: int) -> void:
	health = clampi(health + amount, 0, 100)
	health_changed.emit(health)

func raise_district_heat(id: String, amount: int) -> void:
	if not districts.has(id):
		return
	var d: Dictionary = districts[id]
	d["heat"] = clampi(int(d["heat"]) + amount, 0, 100)
	districts[id] = d
	heat_changed.emit(id, d["heat"])

func current_heat() -> int:
	if districts.has(current_district_id):
		return int(districts[current_district_id]["heat"])
	return 0

func current_control() -> int:
	if districts.has(current_district_id):
		return int(districts[current_district_id]["control"])
	return 0

func daily_income(id: String) -> int:
	if not districts.has(id):
		return 0
	var d: Dictionary = districts[id]
	var control_factor: int = int(d["control"])
	var heat_penalty: int = int(d["heat"]) / 5
	if control_factor <= heat_penalty:
		return 0
	return int(d["racket_income"]) * (control_factor - heat_penalty) / 100

func _on_new_day() -> void:
	var income := 0
	for id in districts.keys():
		income += daily_income(id)
	if income > 0:
		add_cash(income)
		toast.emit("Collections +$%d" % income, 2.5)
	feed_line.emit("A new day")

func _tick_heat_decay(delta: float) -> void:
	if wanted_level > 0:
		return
	for id in districts.keys():
		var d: Dictionary = districts[id]
		var h: int = int(d["heat"])
		if h > 0 and randf() < delta * 0.02:
			d["heat"] = h - 1
			districts[id] = d
			if id == current_district_id:
				heat_changed.emit(id, d["heat"])

func _tick_heal(delta: float) -> void:
	if current_heat() >= Balance.HEAL_MAX_HEAT:
		return
	if health >= 100:
		return
	heal_accum += Balance.HEAL_PER_SEC * delta
	if heal_accum >= 1.0:
		var amt: int = mini(int(heal_accum), 5)
		heal(amt)
		heal_accum -= float(amt)

func _tick_street_events(delta: float) -> void:
	street_event_cd -= delta
	if street_event_cd > 0.0:
		return
	street_event_cd = Balance.STREET_EVENT_INTERVAL
	var roll := randi() % 5
	match roll:
		0:
			raise_district_heat(current_district_id, 8)
			toast.emit("HEAT SPIKE!", 2.5)
			feed_line.emit("Police heat spike")
		1:
			toast.emit("Rival crew spotted", 2.0)
			feed_line.emit("Rival pressure")
		2:
			feed_line.emit("Street talk: cops circling the avenue")
		3:
			add_cash(50)
			toast.emit("Small protection take +$50", 2.0)
		_:
			feed_line.emit("Quiet on the block")

func bribe_cops() -> bool:
	if treasury < Balance.BRIBE_COST or wanted_level <= 0:
		return false
	add_cash(-Balance.BRIBE_COST)
	set_wanted(0)
	toast.emit("Bribed cops", 2.5)
	feed_line.emit("Bribe paid")
	return true

func to_save_dict() -> Dictionary:
	return {
		"era": era,
		"boss_name": boss_name,
		"treasury": treasury,
		"health": health,
		"wanted_level": wanted_level,
		"day": day,
		"clock_hours": clock_hours,
		"current_district_id": current_district_id,
		"districts": districts.duplicate(true),
		"aspiration_tier": aspiration_tier,
		"calm": calm,
	}

func from_save_dict(data: Dictionary) -> void:
	era = data.get("era", Era.NYC_1930S)
	boss_name = data.get("boss_name", boss_name)
	treasury = data.get("treasury", Balance.STARTING_TREASURY)
	health = data.get("health", 100)
	wanted_level = data.get("wanted_level", 0)
	day = data.get("day", 1)
	clock_hours = data.get("clock_hours", 8.0)
	current_district_id = data.get("current_district_id", "hells_kitchen")
	if data.has("districts"):
		districts = data["districts"]
	aspiration_tier = data.get("aspiration_tier", 1)
	calm = data.get("calm", 70)
	treasury_changed.emit(treasury)
	wanted_changed.emit(wanted_level)
	health_changed.emit(health)
