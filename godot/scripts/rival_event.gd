extends Node
## Street rival pressure — BETA RIVAL_INTERVAL.

var _cd: float = Balance.RIVAL_INTERVAL

func _process(delta: float) -> void:
	_cd -= delta
	if _cd > 0.0:
		return
	_cd = Balance.RIVAL_INTERVAL + randf_range(-4.0, 8.0)
	_trigger()

func _trigger() -> void:
	var roll := randi() % 3
	match roll:
		0:
			GameState.toast.emit("RIVAL ENFORCER nearby", 2.5)
			GameState.feed_line.emit("Rival crew on the avenue")
			GameState.raise_district_heat(GameState.current_district_id, 4)
			_spawn_enforcer()
		1:
			GameState.toast.emit("Rival shakes a shop", 2.0)
			GameState.feed_line.emit("Protection contested")
			if GameState.treasury > 100:
				GameState.add_cash(-80)
		2:
			GameState.feed_line.emit("Word is the Westies are moving")

func _spawn_enforcer() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	var e := CharacterBody3D.new()
	e.add_to_group("rival")
	e.collision_layer = 8
	e.collision_mask = 1
	var mesh := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.32
	cap.height = 1.7
	mesh.mesh = cap
	mesh.position.y = 0.85
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.1, 0.1)
	mesh.material_override = mat
	e.add_child(mesh)
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.32
	shape.height = 1.7
	col.shape = shape
	col.position.y = 0.85
	e.add_child(col)
	e.global_position = player.global_position + Vector3(randf_range(-12, 12), 0, randf_range(-12, 12))
	add_child(e)
	# Short-lived aggressor
	var life := 25.0
	e.set_meta("life", life)
	e.set_physics_process(true)
	# Use script-free chase via process on this node tracking children

func _physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	for c in get_children():
		if not c is CharacterBody3D:
			continue
		if not c.has_meta("life"):
			continue
		var life: float = c.get_meta("life") - delta
		c.set_meta("life", life)
		if life <= 0.0:
			c.queue_free()
			continue
		var to: Vector3 = player.global_position - c.global_position
		to.y = 0.0
		var dist := to.length()
		if dist > 0.2:
			c.velocity = to.normalized() * 5.5
			c.move_and_slide()
		if dist < 2.2:
			GameState.damage(3)
			if randf() < delta * 2.0:
				GameState.toast.emit("Fight: Rival Enforcer", 1.2)
