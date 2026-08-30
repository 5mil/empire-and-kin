extends Node3D
## Main world — BETA systems ported: empire, 40 spots, heat/rival/payday.

func _ready() -> void:
	GameState.current_district_id = "hells_kitchen"
	var player := get_node_or_null("Player")
	if player:
		player.add_to_group("player")
	print("[Empire & Kin] Godot 4 | era=%s | district=%s | spots=%d" % [
		GameState.era_name(),
		Districts.display_name(GameState.current_district_id),
		InteractCatalog.catalog().size(),
	])
	GameState.feed_line.emit("Hell's Kitchen — watch the heat")
	_spawn_extra_jobs()
	_spawn_safehouse()
	InteractCatalog.spawn_all(self)
	GameState.feed_line.emit("%d street spots live — walk and press E" % InteractCatalog.catalog().size())

func _spawn_extra_jobs() -> void:
	add_child(_make_job(Vector3(12, 1, -10), 1, 350))
	add_child(_make_job(Vector3(-15, 1, 20), 2, 500))

func _spawn_safehouse() -> void:
	var area := Area3D.new()
	area.position = Vector3(-20, 1, -15)
	var script: Script = load("res://scripts/safehouse.gd")
	area.set_script(script)
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(8, 4, 8)
	col.shape = box
	area.add_child(col)
	var mesh_i := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = Vector3(8, 0.2, 8)
	mesh_i.mesh = m
	mesh_i.position.y = -0.8
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.55, 0.35)
	mat.emission_enabled = true
	mat.emission = Color(0.1, 0.4, 0.2)
	mesh_i.material_override = mat
	area.add_child(mesh_i)
	var shell := MeshInstance3D.new()
	var sm := BoxMesh.new()
	sm.size = Vector3(7, 6, 7)
	shell.mesh = sm
	shell.position.y = 2.5
	var smat := StandardMaterial3D.new()
	smat.albedo_color = Color(0.25, 0.28, 0.22)
	shell.material_override = smat
	area.add_child(shell)
	add_child(area)
	GameState.feed_line.emit("Safehouse marked (green pad west)")

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
