extends CanvasLayer
## Lightweight port of empire_ui — collect + district snapshot.

@onready var root: Control = $Root
@onready var body: Label = $Root/Panel/Body

var _open: bool = false

func _ready() -> void:
	root.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# Don't fight mouse release on first Esc from player
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
		if event.keycode == KEY_1:
			Empire.collect_all()
			_refresh()
		elif event.keycode == KEY_2:
			GameState.bribe_cops()
			_refresh()

func _refresh() -> void:
	var lines: PackedStringArray = []
	lines.append("EMPIRE — %s" % Districts.display_name(GameState.current_district_id))
	lines.append("Treasury $%d | Respect %d" % [GameState.treasury, Empire.street_respect])
	lines.append("Control %d | Heat %d | Wanted %d/5" % [
		GameState.current_control(), GameState.current_heat(), GameState.wanted_level
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
	lines.append("[1] Collect   [2] Bribe cops ($%d)   [Esc] Close" % Balance.BRIBE_COST)
	body.text = "\n".join(lines)
