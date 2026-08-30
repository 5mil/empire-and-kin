extends Node3D
## Hell's Kitchen playable slice — geometry from real NYC street rules.
##
## Real pattern (Midtown West):
##   Avenues run N–S (game −Z = north-ish for playability)
##   Cross streets run E–W (game X)
## Scale: ~1 unit ≈ 1 meter. One block ≈ 60–80 m avenue spacing (compressed for play).
##
## Reference center: ~40.7638, -73.9918 (9th/10th Ave corridor).
## Not a full OSM mesh dump — authored simplification until OSM import lands.

@export var avenue_count: int = 3
@export var street_count: int = 4
@export var avenue_spacing: float = 55.0
@export var street_spacing: float = 45.0
@export var road_width: float = 12.0
@export var sidewalk_width: float = 3.5
@export var building_depth: float = 14.0
@export var building_min_h: float = 8.0
@export var building_max_h: float = 28.0

const AVE_NAMES := ["10th Ave", "9th Ave", "8th Ave"]
const ST_NAMES := ["W 48th", "W 47th", "W 46th", "W 45th"]

func _ready() -> void:
	_build_grid()
	GameState.current_district_id = "hells_kitchen"

func _build_grid() -> void:
	var mat_road := StandardMaterial3D.new()
	mat_road.albedo_color = Color(0.14, 0.14, 0.16)
	mat_road.roughness = 0.95

	var mat_walk := StandardMaterial3D.new()
	mat_walk.albedo_color = Color(0.35, 0.34, 0.32)
	mat_walk.roughness = 0.9

	var mat_brick := StandardMaterial3D.new()
	mat_brick.albedo_color = Color(0.42, 0.26, 0.20)
	mat_brick.roughness = 0.88

	var mat_brick2 := StandardMaterial3D.new()
	mat_brick2.albedo_color = Color(0.32, 0.30, 0.28)
	mat_brick2.roughness = 0.85

	var origin := Vector3(
		-(avenue_count - 1) * avenue_spacing * 0.5,
		0.0,
		-(street_count - 1) * street_spacing * 0.5
	)

	# Avenues (N–S strips along Z)
	for ai in range(avenue_count):
		var x: float = origin.x + ai * avenue_spacing
		var length: float = (street_count - 1) * street_spacing + road_width + 20.0
		_add_road_strip(
			Vector3(x, 0.05, origin.z + (street_count - 1) * street_spacing * 0.5),
			Vector3(road_width, 0.1, length),
			mat_road,
			"Ave_%d" % ai
		)
		# Sidewalks either side of avenue
		for side in [-1.0, 1.0]:
			var sx: float = x + side * (road_width * 0.5 + sidewalk_width * 0.5)
			_add_static_box(
				Vector3(sx, 0.08, origin.z + (street_count - 1) * street_spacing * 0.5),
				Vector3(sidewalk_width, 0.12, length),
				mat_walk,
				false
			)

	# Cross streets (E–W)
	for si in range(street_count):
		var z: float = origin.z + si * street_spacing
		var length: float = (avenue_count - 1) * avenue_spacing + road_width + 20.0
		_add_road_strip(
			Vector3(origin.x + (avenue_count - 1) * avenue_spacing * 0.5, 0.05, z),
			Vector3(length, 0.1, road_width),
			mat_road,
			"St_%d" % si
		)

	# Building lots on block interiors (between avenues and streets)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1948  # stable layout
	for ai in range(avenue_count - 1):
		for si in range(street_count - 1):
			var cx: float = origin.x + (ai + 0.5) * avenue_spacing
			var cz: float = origin.z + (si + 0.5) * street_spacing
			var lot_w: float = avenue_spacing - road_width - sidewalk_width * 2.0 - 4.0
			var lot_d: float = street_spacing - road_width - sidewalk_width * 2.0 - 4.0
			# Two buildings per lot face (simplified tenement row)
			for row in range(2):
				var h: float = rng.randf_range(building_min_h, building_max_h)
				var bw: float = lot_w * 0.42
				var bd: float = minf(building_depth, lot_d * 0.4)
				var ox: float = cx + (row - 0.5) * (lot_w * 0.5)
				var oz: float = cz - lot_d * 0.25
				var mat: Material = mat_brick if (ai + si + row) % 2 == 0 else mat_brick2
				_add_static_box(
					Vector3(ox, h * 0.5, oz),
					Vector3(bw, h, bd),
					mat,
					true
				)
				# Opposite face
				_add_static_box(
					Vector3(ox, h * 0.5 * 0.9, cz + lot_d * 0.25),
					Vector3(bw * 0.95, h * 0.9, bd),
					mat,
					true
				)

func _add_road_strip(pos: Vector3, size: Vector3, mat: Material, _name: String) -> void:
	_add_static_box(pos, size, mat, true)

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
