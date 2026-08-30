extends Area3D
## District travel — port of district_travel.zig

var _in := false

func _ready() -> void:
	body_entered.connect(func(b):
		if b.is_in_group("player"):
			_in = true)
	body_exited.connect(func(b):
		if b.is_in_group("player"):
			_in = false)

func _unhandled_input(event: InputEvent) -> void:
	if not _in:
		return
	if event.is_action_pressed("interact"):
		var dest := str(get_meta("dest", ""))
		if dest == "":
			return
		GameState.current_district_id = dest
		GameState.feed_line.emit("Arrived: %s" % Districts.display_name(dest))
		GameState.toast.emit(Districts.display_name(dest), 2.0)
		var hud := get_tree().root.find_child("HUD", true, false)
		if hud and hud.has_method("_refresh_all"):
			hud._refresh_all()
		get_viewport().set_input_as_handled()
