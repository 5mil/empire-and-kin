extends Node3D
## Spawns/despawns a pursuit unit from GameState.wanted_level (BETA chase).

var _cop: CharacterBody3D = null
var _active: bool = false

func _ready() -> void:
	GameState.wanted_changed.connect(_on_wanted)
	_on_wanted(GameState.wanted_level)

func _on_wanted(level: int) -> void:
	if level >= 1 and not _active:
		_spawn_cop()
	elif level <= 0 and _active:
		_despawn_cop()

func _spawn_cop() -> void:
	_active = true
	_cop = CharacterBody3D.new()
	_cop.collision_layer = 8
	_cop.collision_mask = 1
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.9, 1.0, 4.4)
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.05, 0.1, 0.35)
	mat.emission_enabled = true
	mat.emission = Color(0.1, 0.2, 0.8)
	mat.emission_energy_multiplier = 0.6
	mesh.material_override = mat
	mesh.position.y = 0.5
	_cop.add_child(mesh)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.9, 1.0, 4.4)
	col.shape = shape
	col.position.y = 0.5
	_cop.add_child(col)
	# Spawn near player offset
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player:
		_cop.global_position = player.global_position + Vector3(18, 0.5, 12)
	else:
		_cop.position = Vector3(20, 0.5, 20)
	add_child(_cop)
	GameState.toast.emit("Police in pursuit!", 2.5)
	GameState.feed_line.emit("Wanted — lose the heat")

func _despawn_cop() -> void:
	_active = false
	if is_instance_valid(_cop):
		_cop.queue_free()
	_cop = null
	GameState.toast.emit("Lost the cops", 2.0)

func _physics_process(delta: float) -> void:
	if not _active or not is_instance_valid(_cop):
		return
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	var to := player.global_position - _cop.global_position
	to.y = 0.0
	var dist := to.length()
	if dist < 0.1:
		return
	var dir := to.normalized()
	var speed := 14.0 + float(GameState.wanted_level) * 2.0
	_cop.velocity = dir * speed
	_cop.move_and_slide()
	_cop.look_at(player.global_position, Vector3.UP)

	# Catch player
	if dist < 3.5:
		GameState.damage(8)
		GameState.raise_district_heat(GameState.current_district_id, 5)
		GameState.toast.emit("Busted contact!", 1.5)
		# Soft push wanted down if player survives long (escape via distance)
	elif dist > 55.0 and GameState.wanted_level > 0:
		# Slowly decay stars when far
		if randf() < delta * 0.15:
			GameState.set_wanted(GameState.wanted_level - 1)
