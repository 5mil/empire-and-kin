extends Node
## Drives Sun + Environment from GameState.clock_hours.

@onready var sun: DirectionalLight3D = get_node_or_null("../Sun")
@onready var world_env: WorldEnvironment = get_node_or_null("../WorldEnvironment")

func _process(_delta: float) -> void:
	var h := GameState.clock_hours
	# 0–24 → elevation and tint
	var t := h / 24.0
	var elev := sin((h - 6.0) / 24.0 * TAU)  # peak ~ noon
	var energy := clampf(elev * 1.2 + 0.15, 0.08, 1.15)
	var night := elev < 0.05

	if sun:
		var az := (h / 24.0) * TAU
		sun.rotation = Vector3(-elev * 1.2, az, 0.2)
		sun.light_energy = energy
		if night:
			sun.light_color = Color(0.35, 0.4, 0.7)
		elif h < 8.0 or h > 18.0:
			sun.light_color = Color(1.0, 0.7, 0.45)
		else:
			sun.light_color = Color(1.0, 0.95, 0.88)

	if world_env and world_env.environment:
		var env := world_env.environment
		if night:
			env.ambient_light_energy = 0.25
			env.fog_density = 0.0025
		else:
			env.ambient_light_energy = 0.45 + energy * 0.2
			env.fog_density = 0.0012
