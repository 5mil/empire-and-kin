extends Node3D
## Hell's Kitchen — roads from real street rules + optional footprint JSON lots.

@export var avenue_count: int = 3
@export var street_count: int = 4
@export var avenue_spacing: float = 55.0
@export var street_spacing: float = 45.0
@export var road_width: float = 12.0
@export var sidewalk_width: float = 3.5
@export var use_footprint_json: bool = true

func _ready() -> void:
	_build_grid()
	GameState.current_district_id = "hells_kitchen"

func _build_grid() -> void:
	var mat_road := _mat(Color(0.14, 0.14, 0.16), 0.95)
	var mat_walk := _mat(Color(0.38, 0.37, 0.35), 0.9)
	var mat_line := _mat(Color(0.75, 0.72, 0.55), 0.7)
	var mat_xwalk := _mat(Color(0.85, 0.85, 0.82), 0.75)
	var mat_pole := _mat(Color(0.15, 0.15, 0.15), 0.6)
	var mat_car := _mat(Color(0.2, 0.22, 0.28), 0.5)
	var mat_car2 := _mat(Color(0.35, 0.12, 0.1), 0.5)

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
		_add_static_box(Vector3(x, 0.11, zc), Vector3(0.25, 0.02, length * 0.9), mat_line, false)
		for side in [-1.0, 1.0]:
			var sx: float = x + side * (road_width * 0.5 + sidewalk_width * 0.5)
			_add_static_box(Vector3(sx, 0.08, zc), Vector3(sidewalk_width, 0.12, length), mat_walk, false)
			for li in range(street_count):
				var lz: float = origin.z + li * street_spacing
				_add_lamp(Vector3(sx, 0.0, lz), mat_pole)
				if li % 2 == 0 and ai == 1:
					var car_x: float = x + side * (road_width * 0.35)
					_add_parked_car(Vector3(car_x, 0.45, lz + 6.0), mat_car if side > 0 else mat_car2)

	for si in range(street_count):
		var z: float = origin.z + si * street_spacing
		var length: float = (avenue_count - 1) * avenue_spacing + road_width + 20.0
		var xc: float = origin.x + (avenue_count - 1) * avenue_spacing * 0.5
		_add_static_box(Vector3(xc, 0.05, z), Vector3(length, 0.1, road_width), mat_road, true)
		_add_static_box(Vector3(xc, 0.11, z), Vector3(length * 0.9, 0.02, 0.25), mat_line, false)

	for ai in range(avenue_count):
		for si in range(street_count):
			var ix: float = origin.x + ai * avenue_spacing
			var iz: float = origin.z + si * street_spacing
			for s in range(5):
				var o: float = (s - 2) * 1.1
				_add_static_box(Vector3(ix + o, 0.12, iz), Vector3(0.6, 0.02, road_width * 0.7), mat_xwalk, false)
				_add_static_box(Vector3(ix, 0.12, iz + o), Vector3(road_width * 0.7, 0.02, 0.6), mat_xwalk, false)

	if use_footprint_json and _load_footprint_buildings():
		return

	# Fallback procedural lots
	var rng := RandomNumberGenerator.new()
	rng.seed = 1948
	for ai in range(avenue_count - 1):
		for si in range(street_count - 1):
			var cx: float = origin.x + (ai + 0.5) * avenue_spacing
			var cz: float = origin.z + (si + 0.5) * street_spacing
			var lot_w: float = avenue_spacing - road_width - sidewalk_width * 2.0 - 4.0
			var lot_d: float = street_spacing - road_width - sidewalk_width * 2.0 - 4.0
			for row in range(2):
				var h: float = rng.randf_range(8.0, 28.0)
				var bw: float = lot_w * 0.42
				var bd: float = minf(14.0, lot_d * 0.4)
				var ox: float = cx + (row - 0.5) * (lot_w * 0.5)
				_add_building(Vector3(ox, h * 0.5, cz - lot_d * 0.25), Vector3(bw, h, bd), ai + si + row)
				_add_building(Vector3(ox, h * 0.45, cz + lot_d * 0.25), Vector3(bw * 0.95, h * 0.9, bd), ai + si + row + 3)

func _load_footprint_buildings() -> bool:
	var path := "res://data/hells_kitchen_footprint.json"
	if not FileAccess.file_exists(path):
		return false
	var f := FileAccess.open(path, FileAccess.READ)
	var data: Variant = JSON.parse_string(f.get_as_text())
	if typeof(data) != TYPE_DICTIONARY or not data.has("buildings"):
		return false
	var i := 0
	for b in data["buildings"]:
		var x: float = float(b.get("x", 0))
		var z: float = float(b.get("z", 0))
		var w: float = float(b.get("w", 10))
		var d: float = float(b.get("d", 10))
		var h: float = float(b.get("h", 12))
		_add_building(Vector3(x, h * 0.5, z), Vector3(w, h, d), i)
		i += 1
	return true

func _add_building(pos: Vector3, size: Vector3, seed_i: int) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	var mesh_i := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_i.mesh = box
	mesh_i.material_override = _facade_material(seed_i, size)
	body.add_child(mesh_i)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	add_child(body)

func _facade_material(seed_i: int, size: Vector3) -> Material:
	# Procedural window grid via spatial shader
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
uniform vec3 brick_color : source_color = vec3(0.42, 0.26, 0.20);
uniform vec3 window_color : source_color = vec3(0.15, 0.2, 0.28);
uniform vec3 lit_window : source_color = vec3(1.0, 0.85, 0.5);
uniform float floors = 6.0;
uniform float bays = 4.0;
uniform float lit_chance = 0.35;
uniform float seed = 1.0;
void fragment() {
	vec2 uv = UV;
	// Use world-ish via UV from default box
	float fy = floor(uv.y * floors);
	float fx = floor(uv.x * bays);
	float frame = step(0.12, fract(uv.x * bays)) * step(fract(uv.x * bays), 0.88)
		* step(0.15, fract(uv.y * floors)) * step(fract(uv.y * floors), 0.85);
	float n = fract(sin(dot(vec2(fx, fy) + seed, vec2(12.9898, 78.233))) * 43758.5453);
	vec3 win = mix(window_color, lit_window, step(1.0 - lit_chance, n));
	vec3 col = mix(brick_color, win, frame);
	ALBEDO = col;
	ROUGHNESS = 0.85;
	EMISSION = win * frame * step(0.5, n) * 0.35;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = sh
	var bricks := [
		Color(0.42, 0.26, 0.20),
		Color(0.32, 0.30, 0.28),
		Color(0.38, 0.22, 0.18),
		Color(0.28, 0.32, 0.35),
	]
	var bc: Color = bricks[seed_i % bricks.size()]
	mat.set_shader_parameter("brick_color", Vector3(bc.r, bc.g, bc.b))
	mat.set_shader_parameter("floors", clampf(size.y / 3.2, 3.0, 12.0))
	mat.set_shader_parameter("bays", clampf(size.x / 3.0, 3.0, 10.0))
	mat.set_shader_parameter("seed", float(seed_i) * 17.0)
	mat.set_shader_parameter("lit_chance", 0.4)
	return mat

func _mat(c: Color, rough: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	return m

func _add_parked_car(pos: Vector3, mat: Material) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	var mesh_i := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.8, 0.85, 4.0)
	mesh_i.mesh = box
	mesh_i.material_override = mat
	body.add_child(mesh_i)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.8, 0.85, 4.0)
	col.shape = shape
	body.add_child(col)
	add_child(body)

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
