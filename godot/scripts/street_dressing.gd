extends Node3D
## Props + travel gates around Hell's Kitchen — T0 boxes, upgrade via AssetContinuum.

func _ready() -> void:
	_props()
	_gates()

func _props() -> void:
	var specs := [
		{"id": "prop.dumpster", "pos": Vector3(-9, 0.6, 9), "sz": Vector3(1.6, 1.2, 0.9), "c": Color(0.18, 0.28, 0.18)},
		{"id": "prop.dumpster", "pos": Vector3(9, 0.6, -7), "sz": Vector3(1.6, 1.2, 0.9), "c": Color(0.16, 0.26, 0.16)},
		{"id": "prop.hydrant", "pos": Vector3(3, 0.4, 6), "sz": Vector3(0.35, 0.8, 0.35), "c": Color(0.7, 0.15, 0.12)},
		{"id": "prop.hydrant", "pos": Vector3(-11, 0.4, -3), "sz": Vector3(0.35, 0.8, 0.35), "c": Color(0.7, 0.15, 0.12)},
		{"id": "prop.newsstand", "pos": Vector3(1, 0.7, -4), "sz": Vector3(1.4, 1.4, 0.8), "c": Color(0.55, 0.25, 0.15)},
		{"id": "prop.crate", "pos": Vector3(17, 0.4, 3), "sz": Vector3(0.8, 0.8, 0.8), "c": Color(0.45, 0.32, 0.18)},
		{"id": "prop.watertower", "pos": Vector3(-22, 9.5, -15), "sz": Vector3(2.2, 2.4, 2.2), "c": Color(0.35, 0.32, 0.28)},
	]
	for s in specs:
		var n: Node3D = AssetContinuum.instantiate(s["id"], s["sz"], s["c"])
		n.position = s["pos"]
		add_child(n)

func _gates() -> void:
	_gate(Vector3(0, 1, 42), "little_italy", "[E] Gate — Little Italy")
	_gate(Vector3(42, 1, 0), "midtown", "[E] Gate — Midtown")
	_gate(Vector3(-42, 1, 0), "lower_east_side", "[E] Gate — Lower East Side")

func _gate(pos: Vector3, dest: String, prompt: String) -> void:
	var area := Area3D.new()
	area.position = pos
	area.monitoring = true
	area.collision_layer = 0
	area.collision_mask = 2
	var col := CollisionShape3D.new()
	var sph := SphereShape3D.new()
	sph.radius = 3.0
	col.shape = sph
	area.add_child(col)
	var vis := AssetContinuum.instantiate("gate." + dest, Vector3(2.2, 3.2, 0.6), Color(0.7, 0.55, 0.2))
	area.add_child(vis)
	area.set_meta("dest", dest)
	area.set_meta("prompt", prompt)
	area.body_entered.connect(func(b):
		if b.is_in_group("player"):
			var hud := get_tree().root.find_child("HUD", true, false)
			if hud and hud.has_method("set_prompt"):
				hud.set_prompt(prompt)
	)
	area.body_exited.connect(func(b):
		if b.is_in_group("player"):
			var hud := get_tree().root.find_child("HUD", true, false)
			if hud and hud.has_method("set_prompt"):
				hud.set_prompt("")
	)
	area.set_script(load("res://scripts/travel_gate.gd"))
	add_child(area)
