extends Node3D
## Main world — BETA systems + Hell's Kitchen street slice.

func _ready() -> void:
	GameState.current_district_id = "hells_kitchen"
	print("[Empire & Kin] Godot 4 | era=%s | district=%s" % [
		GameState.era_name(),
		Districts.display_name(GameState.current_district_id),
	])
	GameState.feed_line.emit("Hell's Kitchen — watch the heat")
	_spawn_extra_jobs()

func _spawn_extra_jobs() -> void:
	# Protection job
	var p := _make_job(Vector3(12, 1, -10), 1, 350)
	add_child(p)
	# Smuggling job
	var s := _make_job(Vector3(-15, 1, 20), 2, 500)
	add_child(s)

func _make_job(pos: Vector3, kind: int, payout: int) -> Area3D:
	var area := Area3D.new()
	area.position = pos
	area.collision_layer = 0
	area.collision_mask = 2
	area.monitoring = true
	var script: Script = load("res://scripts/job_marker.gd")
	area.set_script(script)
	area.job_kind = kind
	area.payout = payout
	var col := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 2.5
	col.shape = sphere
	area.add_child(col)
	var mesh_i := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1, 2, 1)
	mesh_i.mesh = box
	var mat := StandardMaterial3D.new()
	match kind:
		1:
			mat.albedo_color = Color(0.3, 0.5, 1.0)
		2:
			mat.albedo_color = Color(1.0, 0.7, 0.2)
		_:
			mat.albedo_color = Color(0.2, 0.9, 0.4)
	mat.emission_enabled = true
	mat.emission = mat.albedo_color * 0.5
	mesh_i.material_override = mat
	area.add_child(mesh_i)
	return area
