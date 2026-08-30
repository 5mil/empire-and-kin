extends CanvasLayer
## Empire menu — collect, upgrade, loan, payday snapshot.

@onready var root: Control = $Root
@onready var body: Label = $Root/Panel/Body

var _open: bool = false

func _ready() -> void:
	root.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and not _open:
			_open = true
			_refresh()
			root.visible = true
		elif _open:
			_open = false
			root.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()
	if _open and event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				Empire.collect_all()
			KEY_2:
				GameState.bribe_cops()
			KEY_3:
				Empire.upgrade_racket(0)
			KEY_4:
				WorldSim.borrow(1000)
			KEY_5:
				Empire.payday()
		_refresh()

func _refresh() -> void:
	var lines: PackedStringArray = []
	lines.append("EMPIRE — %s" % Districts.display_name(GameState.current_district_id))
	lines.append("Treasury $%d | Respect %d | Favor %d" % [
		GameState.treasury, Empire.street_respect, Empire.family_favor
	])
	lines.append("Control %d | Heat %d | Wanted %d/5 | Rival %d" % [
		GameState.current_control(), GameState.current_heat(),
		GameState.wanted_level, WorldSim.rival_pressure
	])
	lines.append("Stash $%d | Loan due $%d | Crew %d" % [
		WorldSim.stash_cash, WorldSim.loan_due, Empire.crew.size()
	])
	lines.append("")
	lines.append("RACKETS")
	for r in Empire.rackets:
		lines.append("  %s @ %s  Lv%d  crew %d" % [
			Empire.kind_name(r["kind"]),
			Districts.display_name(str(r["district_id"])),
			int(r["level"]),
			int(r["crew_assigned"]),
		])
	lines.append("")
	lines.append("CREW")
	for m in Empire.crew:
		lines.append("  %s  muscle %d  morale %d" % [m["name"], int(m["muscle"]), int(m["morale"])])
	lines.append("")
	lines.append("[1] Collect  [2] Bribe  [3] Upgrade racket 0")
	lines.append("[4] Loan $1000  [5] Payday now  [Esc] Close")
	body.text = "\n".join(lines)
