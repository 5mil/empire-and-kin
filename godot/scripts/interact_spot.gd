extends Area3D
## One world E-key spot — port of Zig interact.tryE branches.

@export var spot_id: String = "fence"
@export var prompt: String = "[E] Interact"
@export var marker_color: Color = Color(0.8, 0.6, 0.3)
@export var marker_size: Vector3 = Vector3(1.2, 1.4, 1.2)

var _player_in := false

func _ready() -> void:
	monitoring = true
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)
	if get_node_or_null("Mesh") == null:
		var visual := AssetContinuum.instantiate("spot." + spot_id, marker_size, marker_color)
		visual.name = "Mesh"
		add_child(visual)

func _on_enter(body: Node) -> void:
	if body.is_in_group("player") or body.name == "Player":
		_player_in = true
		var hud := get_tree().root.find_child("HUD", true, false)
		if hud and hud.has_method("set_prompt"):
			hud.set_prompt(prompt)

func _on_exit(body: Node) -> void:
	if body.is_in_group("player") or body.name == "Player":
		_player_in = false
		var hud := get_tree().root.find_child("HUD", true, false)
		if hud and hud.has_method("set_prompt"):
			hud.set_prompt("")

func _unhandled_input(event: InputEvent) -> void:
	if not _player_in:
		return
	if event.is_action_pressed("interact"):
		InteractCatalog.activate(spot_id)
		get_viewport().set_input_as_handled()
