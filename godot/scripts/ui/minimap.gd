extends Control
## Street-level top-down radar — player, jobs, cops.

@export var range_m: float = 60.0
@export var map_size: float = 140.0

func _ready() -> void:
	custom_minimum_size = Vector2(map_size, map_size)
	size = Vector2(map_size, map_size)

func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, map_size * 0.48, Color(0.05, 0.08, 0.1, 0.75))
	draw_arc(center, map_size * 0.48, 0, TAU, 48, Color(0.4, 0.5, 0.55, 0.8), 2.0)

	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	var ppos := player.global_position

	# Jobs
	for n in get_tree().get_nodes_in_group("job"):
		if n is Node3D:
			_dot(center, ppos, n.global_position, Color(0.3, 1.0, 0.4))

	# Cops
	for n in get_tree().get_nodes_in_group("cop"):
		if n is Node3D:
			_dot(center, ppos, n.global_position, Color(0.3, 0.5, 1.0))

	# Player
	draw_circle(center, 4.0, Color(1, 1, 1))

func _dot(center: Vector2, origin: Vector3, world: Vector3, color: Color) -> void:
	var d := world - origin
	var sx := d.x / range_m * (map_size * 0.45)
	var sy := d.z / range_m * (map_size * 0.45)
	if absf(sx) > map_size * 0.45 or absf(sy) > map_size * 0.45:
		return
	draw_circle(center + Vector2(sx, sy), 3.0, color)

func _process(_delta: float) -> void:
	queue_redraw()
