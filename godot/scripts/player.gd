extends CharacterBody3D
## Street-level third-person controller + optional phone touch.

@export var walk_speed: float = 4.5
@export var sprint_speed: float = 7.5
@export var mouse_sensitivity: float = 0.0025
@export var touch_look_sensitivity: float = 0.004
@export var camera_distance: float = 5.0
@export var camera_height: float = 1.7
@export var camera_side: float = 0.35
@export var min_pitch: float = -0.55
@export var max_pitch: float = 0.35
@export var interact_range: float = 4.0

var _yaw: float = 0.0
var _pitch: float = -0.12
var _vehicle: Node3D = null
var _touch: Node = null
var _touch_sprint: bool = false

@onready var _pivot: Node3D = $CameraPivot
@onready var _spring: SpringArm3D = $CameraPivot/SpringArm3D
@onready var _camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D

func _ready() -> void:
	add_to_group("player")
	var mobile := OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")
	var touch := DisplayServer.is_touchscreen_available()
	if mobile or touch:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_spring.spring_length = camera_distance
	_spring.position = Vector3(camera_side, camera_height, 0.0)
	call_deferred("_bind_touch")

func _bind_touch() -> void:
	_touch = get_tree().get_first_node_in_group("touch_controls")
	if _touch == null:
		# Scene may instance TouchControls without group yet
		for n in get_tree().get_nodes_in_group("touch_controls"):
			_touch = n
			break
	if _touch and _touch.has_signal("interact_pressed"):
		_touch.interact_pressed.connect(_on_touch_interact)
	if _touch and _touch.has_signal("sprint_changed"):
		_touch.sprint_changed.connect(func(p: bool): _touch_sprint = p)

func set_in_vehicle(v: Node3D) -> void:
	_vehicle = v

func clear_vehicle() -> void:
	_vehicle = null

func _on_touch_interact() -> void:
	if _vehicle != null:
		_vehicle.exit(self)
	else:
		_try_enter_vehicle()

func _unhandled_input(event: InputEvent) -> void:
	if _vehicle != null:
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_yaw -= event.relative.x * mouse_sensitivity
			_pitch = clampf(_pitch - event.relative.y * mouse_sensitivity, min_pitch, max_pitch)
		if event.is_action_pressed("interact"):
			_vehicle.exit(self)
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch = clampf(_pitch - event.relative.y * mouse_sensitivity, min_pitch, max_pitch)
		_pivot.rotation = Vector3(_pitch, _yaw, 0.0)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = (
			Input.MOUSE_MODE_VISIBLE
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED
		)
	if event.is_action_pressed("interact"):
		_try_enter_vehicle()

func _physics_process(delta: float) -> void:
	# Touch look
	if _touch and _touch.has_method("consume_look_delta"):
		var ld: Vector2 = _touch.consume_look_delta()
		if ld != Vector2.ZERO:
			_yaw -= ld.x * touch_look_sensitivity
			_pitch = clampf(_pitch - ld.y * touch_look_sensitivity, min_pitch, max_pitch)
			_pivot.rotation = Vector3(_pitch, _yaw, 0.0)

	if _vehicle != null:
		global_position = _vehicle.global_position
		_pivot.global_position = _vehicle.global_position + Vector3(0, 1.2, 0)
		_pivot.rotation = Vector3(_pitch, _yaw, 0.0)
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if _touch and "move_vector" in _touch:
		var mv: Vector2 = _touch.move_vector
		if mv.length() > 0.05:
			input_dir = Vector2(mv.x, mv.y)

	var basis_yaw := Basis(Vector3.UP, _yaw)
	var direction := (basis_yaw * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	var sprinting := Input.is_action_pressed("sprint") or _touch_sprint
	var speed := sprint_speed if sprinting else walk_speed

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		var target_yaw := atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 1.0 - exp(-12.0 * delta))
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	move_and_slide()

func _try_enter_vehicle() -> void:
	var nearest: Node3D = null
	var best := interact_range
	for v in get_tree().get_nodes_in_group("vehicle"):
		if not v is Node3D:
			continue
		var d: float = global_position.distance_to(v.global_position)
		if d < best and v.has_method("enter") and not v.occupied:
			best = d
			nearest = v
	if nearest:
		nearest.enter(self)
		GameState.toast.emit("Entered vehicle", 1.2)
