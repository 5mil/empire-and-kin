extends Node3D
## Pursuit units scale with wanted level + light-bar blink.

var _cops: Array[CharacterBody3D] = []

func _ready() -> void:
	GameState.wanted_changed.connect(_on_wanted)
	_on_wanted(GameState.wanted_level)

func _on_wanted(level: int) -> void:
	var want_count := mini(level, 3)
	while _cops.size() > want_count:
		var c: CharacterBody3D = _cops.pop_back()
		if is_instance_valid(c):
			c.queue_free()
	if want_count > 0 and _cops.is_empty():
		GameState.toast.emit("Police in pursuit!", 2.5)
		GameState.feed_line.emit("Wanted — lose the heat")
	while _cops.size() < want_count:
		_spawn_one(_cops.size())
	if level <= 0 and want_count == 0:
		GameState.toast.emit("Lost the cops", 2.0)

func _spawn_one(index: int) -> void:
	var cop := CharacterBody3D.new()
	cop.add_to_group("cop")
	cop.collision_layer = 8
	cop.collision_mask = 1
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.9, 1.0, 4.4)
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.05, 0.1, 0.35)
	mesh.material_override = mat
	mesh.position.y = 0.5
	cop.add_child(mesh)
	# Light bar
	var bar := OmniLight3D.new()
	bar.name = "LightBar"
	bar.position = Vector3(0, 1.2, 0)
	bar.omni_range = 10.0
	bar.light_energy = 2.5
	bar.light_color = Color(0.2, 0.4, 1.0)
	cop.add_child(bar)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.9, 1.0, 4.4)
	col.shape = shape
	col.position.y = 0.5
	cop.add_child(col)
	var player := get_tree().get_first_node_in_group("player") as Node3D
	var ang := float(index) * 2.1
	var offset := Vector3(cos(ang), 0, sin(ang)) * (16.0 + index * 6.0)
	if player:
		cop.global_position = player.global_position + offset + Vector3(0, 0.5, 0)
	else:
		cop.position = offset
	add_child(cop)
	_cops.append(cop)

func _physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	var blink := fmod(Time.get_ticks_msec() / 1000.0, 0.6) < 0.3
	for i in range(_cops.size()):
		var cop := _cops[i]
		if not is_instance_valid(cop):
			continue
		var bar := cop.get_node_or_null("LightBar") as OmniLight3D
		if bar:
			bar.light_color = Color(1.0, 0.15, 0.1) if blink else Color(0.15, 0.35, 1.0)
			bar.light_energy = 3.0 if blink else 2.2
		var to := player.global_position - cop.global_position
		to.y = 0.0
		var dist := to.length()
		if dist < 0.1:
			continue
		var dir := to.normalized()
		var speed := 13.0 + float(GameState.wanted_level) * 2.2 + float(i) * 0.5
		cop.velocity = dir * speed
		cop.move_and_slide()
		if dist > 1.0:
			cop.look_at(player.global_position, Vector3.UP)
		if dist < 3.5:
			GameState.damage(5)
			GameState.raise_district_heat(GameState.current_district_id, 3)
		elif dist > 60.0 and GameState.wanted_level > 0 and randf() < delta * 0.12:
			GameState.set_wanted(GameState.wanted_level - 1)
