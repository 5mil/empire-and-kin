extends Node
## Godot port of Zig recipe/continuum resolver + glTF load.
## T0 procedural box always draws. T2 local .glb upgrades when present.
## Godot replaces Zig GL 3.3 / GLES 3.0 backends (Forward+ desktop, mobile GLES/Vulkan).

signal resolved(recipe_id: String, tier: int)

const RECIPE_DIR := "res://assets/recipes"
const CC0_ROOT := "res://assets/cc0"
const GEN_ROOT := "res://assets/generated"

var _cache: Dictionary = {}  # recipe_id -> PackedScene or Mesh

func instantiate(recipe_id: String, fallback_size: Vector3, fallback_color: Color) -> Node3D:
	var n := Node3D.new()
	n.name = recipe_id.replace(".", "_")
	var glb_path := _find_glb(recipe_id)
	if glb_path != "":
		var inst := _load_gltf(glb_path)
		if inst:
			n.add_child(inst)
			resolved.emit(recipe_id, 2)
			return n
	# T0 fallback primitive
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = fallback_size
	mi.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = fallback_color
	mat.roughness = 0.85
	mi.material_override = mat
	n.add_child(mi)
	resolved.emit(recipe_id, 0)
	return n

func _find_glb(recipe_id: String) -> String:
	var slug := recipe_id.replace(".", "_")
	var candidates := [
		"%s/%s.glb" % [GEN_ROOT, slug],
		"%s/buildings/%s.glb" % [GEN_ROOT, slug],
		"%s/vehicles/%s.glb" % [GEN_ROOT, slug],
		"%s/characters/%s.glb" % [CC0_ROOT, slug],
		"%s/buildings/%s.glb" % [CC0_ROOT, slug],
	]
	for p in candidates:
		if ResourceLoader.exists(p):
			return p
	return ""

func _load_gltf(path: String) -> Node3D:
	if _cache.has(path):
		var packed: PackedScene = _cache[path]
		return packed.instantiate() as Node3D
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var err := doc.append_from_file(path, state)
	if err != OK:
		push_warning("[continuum] glTF fail %s err=%s" % [path, err])
		return null
	var root := doc.generate_scene(state)
	if root == null:
		return null
	var packed := PackedScene.new()
	packed.pack(root)
	_cache[path] = packed
	return packed.instantiate() as Node3D

func skin_bind_pose_note() -> String:
	# Zig skin.zig bind-pose exists on BETA. Godot uses imported Skeleton3D.
	return "Use Godot Skeleton3D + AnimationPlayer on imported Quaternius/KayKit GLB."
