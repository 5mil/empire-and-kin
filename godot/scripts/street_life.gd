extends Node3D
## Spawns sidewalk peds and avenue traffic for Hell's Kitchen density.

@export var ped_count: int = 12
@export var traffic_count: int = 6

func _ready() -> void:
	call_deferred("_spawn")

func _spawn() -> void:
	var ped_script: Script = load("res://scripts/ped.gd")
	var traffic_script: Script = load("res://scripts/traffic_car.gd")
	var rng := RandomNumberGenerator.new()
	rng.seed = 9101

	# Peds on sidewalks near center avenues
	for i in range(ped_count):
		var p := CharacterBody3D.new()
		p.set_script(ped_script)
		var x: float = rng.randf_range(-50.0, 50.0)
		var z: float = rng.randf_range(-60.0, 60.0)
		# Snap toward sidewalk bands (near avenue x = -55,0,55)
		var avenues := [-55.0, 0.0, 55.0]
		var ax: float = avenues[i % 3]
		x = ax + (7.0 if i % 2 == 0 else -7.0)
		p.position = Vector3(x, 1.0, z)
		p.rotation.y = PI * 0.5 if i % 2 == 0 else -PI * 0.5

		var mesh := MeshInstance3D.new()
		mesh.name = "Mesh"
		var cap := CapsuleMesh.new()
		cap.radius = 0.28
		cap.height = 1.6
		mesh.mesh = cap
		mesh.position.y = 0.8
		p.add_child(mesh)

		var col := CollisionShape3D.new()
		var shape := CapsuleShape3D.new()
		shape.radius = 0.28
		shape.height = 1.6
		col.shape = shape
		col.position.y = 0.8
		p.add_child(col)
		p.collision_layer = 8
		p.collision_mask = 1
		add_child(p)

	# Traffic on center of avenues, facing N/S
	for i in range(traffic_count):
		var c := Node3D.new()
		c.set_script(traffic_script)
		var ax2: float = [-55.0, 0.0, 55.0][i % 3]
		var z2: float = rng.randf_range(-40.0, 40.0)
		c.position = Vector3(ax2 + rng.randf_range(-2.0, 2.0), 0.5, z2)
		if i % 2 == 0:
			c.rotation.y = 0.0
		else:
			c.rotation.y = PI

		var mesh2 := MeshInstance3D.new()
		mesh2.name = "Mesh"
		var box := BoxMesh.new()
		box.size = Vector3(1.7, 0.8, 3.8)
		mesh2.mesh = box
		c.add_child(mesh2)
		add_child(c)
