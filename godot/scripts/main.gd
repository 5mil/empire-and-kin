extends Node3D
## Main world — systems from BETA; art still temporary until OSM district.

func _ready() -> void:
	GameState.current_district_id = "hells_kitchen"
	print("[Empire & Kin] Godot 4 | era=%s | district=%s" % [
		GameState.era_name(),
		Districts.display_name(GameState.current_district_id),
	])
	print("[Empire & Kin] Zig freeze: branch BETA | map anchors: real NYC")
	GameState.feed_line.emit("Hell's Kitchen — watch the heat")
