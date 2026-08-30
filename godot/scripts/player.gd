extends CharacterBody3D
## Street-level third-person controller (not elevated god-cam).
## Vehicle enter/exit mirrors BETA action.enterVehicle / exitVehicle.

@export var walk_speed: float = 4.5
@export var sprint_speed: float = 7.5
@export var mouse_sensitivity: float = 0.0025
@export var camera_distance: float = 5.0
@export var camera_height: float = 1.7
@export var camera_side: float = 0.35
@export var min_pitch: float = -0.55
@export var max_pitch: float = 0.35
@export var interact_range: float = 4.0

var _yaw: float = 0.0
var _pitch: float = -0.12
var _vehicle: Node3D = null

@onready var _pivot: Node3D = $CameraPivot
@onready var _spring: SpringArm3D = $CameraPivot/SpringArm3D
@onready var _camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D

func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_spring.spring_length = camera_distance
	_spring.position = Vector3(camera_side, camera_height, 0.0)

func set_in_vehicle(v: Node3D) -> void:
	_vehicle = v
	# Reparent camera follow feel: keep pivot world-aligned via process

func clear_vehicle() -> void:
	_vehicle = null

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
	if _vehicle != null:
		global_position = _vehicle.global_position
		_pivot.global_position = _vehicle.global_position + Vector3(0, 1.2, 0)
		_pivot.rotation = Vector3(_pitch, _yaw, 0.0)
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var basis_yaw := Basis(Vector3.UP, _yaw)
	var direction := (basis_yaw * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	var speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed

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
