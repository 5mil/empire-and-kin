extends Node
## Quick-save: GameState + Empire + WorldSim.

const SAVE_PATH := "user://empire_save.json"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			save_game()
		elif event.keycode == KEY_F9:
			load_game()

func save_game() -> void:
	var data := GameState.to_save_dict()
	data["empire"] = Empire.to_save_dict()
	data["world_sim"] = WorldSim.to_save_dict()
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		GameState.toast.emit("Save failed", 2.0)
		return
	f.store_string(JSON.stringify(data))
	GameState.toast.emit("Saved.", Balance.TOAST_SAVE_SEC)
	GameState.feed_line.emit("Quick-saved")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		GameState.toast.emit("No save", 2.0)
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		GameState.toast.emit("Save corrupt", 2.0)
		return
	var data: Dictionary = parsed
	GameState.from_save_dict(data)
	if data.has("empire"):
		Empire.from_save_dict(data["empire"])
	if data.has("world_sim"):
		WorldSim.from_save_dict(data["world_sim"])
	GameState.toast.emit("Loaded.", Balance.TOAST_SAVE_SEC)
	GameState.feed_line.emit("Loaded save")
