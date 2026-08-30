extends CharacterBody3D
## Simple sidewalk ped — walks a lane, turns at ends (BETA street_peds feel).

@export var walk_speed: float = 1.6
@export var lane_half: float = 20.0

var _dir: float = 1.0
var _origin: Vector3

func _ready() -> void:
	add_to_group("ped")
	_origin = global_position
	if randf() > 0.5:
		_dir = -1.0
	# Slight color variation
	var mesh := get_node_or_null("Mesh") as MeshInstance3D
	if mesh:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(randf_range(0.2, 0.8), randf_range(0.15, 0.5), randf_range(0.15, 0.5))
		mesh.material_override = mat

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	else:
		velocity.y = 0.0

	# Walk along local +Z axis of spawn orientation
	var forward := global_transform.basis.z * _dir
	velocity.x = forward.x * walk_speed
	velocity.z = forward.z * walk_speed
	move_and_slide()

	var along := global_position - _origin
	if along.length() > lane_half:
		_dir *= -1.0
		_origin = global_position
