extends Node3D
## Hell's Kitchen playable slice — geometry from real NYC street rules.
## Avenues N–S, streets E–W. Reference ~40.7638, -73.9918.

@export var avenue_count: int = 3
@export var street_count: int = 4
@export var avenue_spacing: float = 55.0
@export var street_spacing: float = 45.0
@export var road_width: float = 12.0
@export var sidewalk_width: float = 3.5
@export var building_depth: float = 14.0
@export var building_min_h: float = 8.0
@export var building_max_h: float = 28.0

func _ready() -> void:
	_build_grid()
	GameState.current_district_id = "hells_kitchen"

func _build_grid() -> void:
	var mat_road := StandardMaterial3D.new()
	mat_road.albedo_color = Color(0.14, 0.14, 0.16)
	mat_road.roughness = 0.95

	var mat_walk := StandardMaterial3D.new()
	mat_walk.albedo_color = Color(0.38, 0.37, 0.35)
	mat_walk.roughness = 0.9

	var mat_brick := StandardMaterial3D.new()
	mat_brick.albedo_color = Color(0.42, 0.26, 0.20)
	mat_brick.roughness = 0.88

	var mat_brick2 := StandardMaterial3D.new()
	mat_brick2.albedo_color = Color(0.32, 0.30, 0.28)
	mat_brick2.roughness = 0.85

	var mat_line := StandardMaterial3D.new()
	mat_line.albedo_color = Color(0.75, 0.72, 0.55)
	mat_line.roughness = 0.7

	var mat_pole := StandardMaterial3D.new()
	mat_pole.albedo_color = Color(0.15, 0.15, 0.15)

	var origin := Vector3(
		-(avenue_count - 1) * avenue_spacing * 0.5,
		0.0,
		-(street_count - 1) * street_spacing * 0.5
	)

	for ai in range(avenue_count):
		var x: float = origin.x + ai * avenue_spacing
		var length: float = (street_count - 1) * street_spacing + road_width + 20.0
		var zc: float = origin.z + (street_count - 1) * street_spacing * 0.5
		_add_static_box(Vector3(x, 0.05, zc), Vector3(road_width, 0.1, length), mat_road, true)
		# Center line
		_add_static_box(Vector3(x, 0.11, zc), Vector3(0.25, 0.02, length * 0.9), mat_line, false)
		for side in [-1.0, 1.0]:
			var sx: float = x + side * (road_width * 0.5 + sidewalk_width * 0.5)
			_add_static_box(Vector3(sx, 0.08, zc), Vector3(sidewalk_width, 0.12, length), mat_walk, false)
			# Lamps along sidewalk
			for li in range(street_count):
				var lz: float = origin.z + li * street_spacing
				_add_lamp(Vector3(sx, 0.0, lz), mat_pole)

	for si in range(street_count):
		var z: float = origin.z + si * street_spacing
		var length: float = (avenue_count - 1) * avenue_spacing + road_width + 20.0
		var xc: float = origin.x + (avenue_count - 1) * avenue_spacing * 0.5
		_add_static_box(Vector3(xc, 0.05, z), Vector3(length, 0.1, road_width), mat_road, true)
		_add_static_box(Vector3(xc, 0.11, z), Vector3(length * 0.9, 0.02, 0.25), mat_line, false)

	var rng := RandomNumberGenerator.new()
	rng.seed = 1948
	for ai in range(avenue_count - 1):
		for si in range(street_count - 1):
			var cx: float = origin.x + (ai + 0.5) * avenue_spacing
			var cz: float = origin.z + (si + 0.5) * street_spacing
			var lot_w: float = avenue_spacing - road_width - sidewalk_width * 2.0 - 4.0
			var lot_d: float = street_spacing - road_width - sidewalk_width * 2.0 - 4.0
			for row in range(2):
				var h: float = rng.randf_range(building_min_h, building_max_h)
				var bw: float = lot_w * 0.42
				var bd: float = minf(building_depth, lot_d * 0.4)
				var ox: float = cx + (row - 0.5) * (lot_w * 0.5)
				var mat: Material = mat_brick if (ai + si + row) % 2 == 0 else mat_brick2
				_add_static_box(Vector3(ox, h * 0.5, cz - lot_d * 0.25), Vector3(bw, h, bd), mat, true)
				_add_static_box(Vector3(ox, h * 0.45, cz + lot_d * 0.25), Vector3(bw * 0.95, h * 0.9, bd), mat, true)

func _add_lamp(pos: Vector3, mat_pole: Material) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	var pole := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.08
	cyl.bottom_radius = 0.12
	cyl.height = 5.5
	pole.mesh = cyl
	pole.position.y = 2.75
	pole.material_override = mat_pole
	body.add_child(pole)
	var light := OmniLight3D.new()
	light.position = Vector3(0, 5.4, 0)
	light.light_energy = 1.4
	light.light_color = Color(1.0, 0.92, 0.75)
	light.omni_range = 14.0
	light.shadow_enabled = false
	body.add_child(light)
	var bulb := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.2
	bulb.mesh = sphere
	bulb.position.y = 5.4
	var mat_b := StandardMaterial3D.new()
	mat_b.albedo_color = Color(1.0, 0.95, 0.8)
	mat_b.emission_enabled = true
	mat_b.emission = Color(1.0, 0.9, 0.6)
	mat_b.emission_energy_multiplier = 2.0
	bulb.material_override = mat_b
	body.add_child(bulb)
	add_child(body)

func _add_static_box(pos: Vector3, size: Vector3, mat: Material, collide: bool) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	var mesh_i := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_i.mesh = box
	mesh_i.material_override = mat
	body.add_child(mesh_i)
	if collide:
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		col.shape = shape
		body.add_child(col)
	add_child(body)
