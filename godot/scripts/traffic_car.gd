extends Node3D
## NPC car sliding along an avenue (visual traffic density).

@export var speed: float = 11.0
@export var path_half: float = 70.0

var _dir: float = 1.0
var _base: Vector3

func _ready() -> void:
	_base = position
	if randf() > 0.5:
		_dir = -1.0
	var mesh := get_node_or_null("Mesh") as MeshInstance3D
	if mesh:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(randf_range(0.05, 0.4), randf_range(0.05, 0.35), randf_range(0.05, 0.4))
		mesh.material_override = mat

func _process(delta: float) -> void:
	# Move along local -Z (car forward)
	position += -transform.basis.z * speed * _dir * delta
	var d: float = position.distance_to(_base)
	if d > path_half:
		_dir *= -1.0
		rotate_y(PI)
