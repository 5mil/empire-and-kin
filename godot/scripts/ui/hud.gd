extends CanvasLayer
## Street HUD — cash, needs, wanted, rival, stash, crew.

@onready var district_label: Label = $Root/TopLeft/District
@onready var clock_label: Label = $Root/TopLeft/Clock
@onready var cash_label: Label = $Root/TopLeft/Cash
@onready var needs_label: Label = $Root/TopLeft/Needs
@onready var wanted_label: Label = $Root/TopLeft/Wanted
@onready var aspiration_label: Label = $Root/TopRight/Aspiration
@onready var toast_label: Label = $Root/Toast
@onready var feed_label: Label = $Root/Feed
@onready var prompt_label: Label = $Root/Prompt
@onready var hints_label: Label = $Root/Hints

var street_label: Label
var _toast_time: float = 0.0
var _feed_lines: PackedStringArray = []
var _hud_accum: float = 0.0

func _ready() -> void:
	street_label = get_node_or_null("Root/TopLeft/Street") as Label
	if street_label == null:
		street_label = Label.new()
		street_label.name = "Street"
		$Root/TopLeft.add_child(street_label)
	GameState.treasury_changed.connect(_on_cash)
	GameState.wanted_changed.connect(_on_wanted)
	GameState.health_changed.connect(_on_health)
	GameState.toast.connect(_on_toast)
	GameState.feed_line.connect(_on_feed)
	_refresh_all()
	hints_label.text = "WASD · Mouse · Shift · E interact · Esc empire · F5 save"

func _process(delta: float) -> void:
	clock_label.text = "DAY %d  %s" % [GameState.day, GameState.clock_string()]
	if _toast_time > 0.0:
		_toast_time -= delta
		if _toast_time <= 0.0:
			toast_label.text = ""
	_hud_accum += delta
	if _hud_accum >= 0.4:
		_hud_accum = 0.0
		_refresh_street()
		_on_health(GameState.health)

func _refresh_all() -> void:
	district_label.text = "EMPIRE & KIN\n%s" % Districts.display_name(GameState.current_district_id).to_upper()
	_on_cash(GameState.treasury)
	_on_wanted(GameState.wanted_level)
	_on_health(GameState.health)
	_refresh_street()
	aspiration_label.text = "ASPIRATION\nTIER %d\nCTRL >= %d\nCASH >= $%d" % [
		GameState.aspiration_tier,
		GameState.aspiration_control_target,
		GameState.aspiration_cash_target,
	]

func _refresh_street() -> void:
	if street_label == null:
		return
	street_label.text = "RIVAL %d  STASH $%d  CREW %d  RES %d" % [
		WorldSim.rival_pressure,
		WorldSim.stash_cash,
		Empire.crew.size(),
		Empire.street_respect,
	]

func _on_cash(v: int) -> void:
	cash_label.text = "$%d" % v

func _on_wanted(v: int) -> void:
	wanted_label.text = "WANTED %d/5" % v
	wanted_label.modulate = Color(1, 0.3, 0.3) if v >= 3 else Color.WHITE

func _on_health(_v: int) -> void:
	needs_label.text = "HEA %s\nCALM %s\nCTRL %s\nHEAT %d" % [
		_bar(GameState.health),
		_bar(GameState.calm),
		_bar(GameState.control_need),
		GameState.current_heat(),
	]

func _bar(v: int) -> String:
	var n: int = clampi(v / 10, 0, 10)
	return "#".repeat(n) + "-".repeat(10 - n)

func _on_toast(msg: String, duration: float) -> void:
	toast_label.text = msg
	_toast_time = duration

func _on_feed(text: String) -> void:
	_feed_lines.append(text)
	if _feed_lines.size() > 6:
		_feed_lines = _feed_lines.slice(_feed_lines.size() - 6)
	feed_label.text = "\n".join(_feed_lines)

func set_prompt(text: String) -> void:
	prompt_label.text = text
