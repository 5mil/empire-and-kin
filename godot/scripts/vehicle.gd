extends RigidBody3D
## Arcade vehicle — BETA Phase 5 controls + heat on heavy crashes.

enum VehicleType { SEDAN, TAXI, TRUCK, MOTORCYCLE }

@export var vehicle_type: VehicleType = VehicleType.SEDAN
@export var max_speed: float = 28.0
@export var health: int = 100

var occupied: bool = false
var _steer: float = 0.0
var _throttle: float = 0.0
var _handbrake: bool = false
var max_steer: float = 0.55
var engine_force_mult: float = 1.0
var _crash_cd: float = 0.0

@onready var _exit: Marker3D = $ExitPoint

func _ready() -> void:
	add_to_group("vehicle")
	_apply_tuning()
	freeze = true
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)

func _apply_tuning() -> void:
	match vehicle_type:
		VehicleType.SEDAN:
			mass = 1200
			engine_force_mult = 1.0
			max_steer = 0.55
			max_speed = 28.0
		VehicleType.TAXI:
			mass = 1250
			engine_force_mult = 0.95
			max_steer = 0.52
			max_speed = 26.0
		VehicleType.TRUCK:
			mass = 2800
			engine_force_mult = 0.7
			max_steer = 0.42
			max_speed = 20.0
		VehicleType.MOTORCYCLE:
			mass = 220
			engine_force_mult = 1.35
			max_steer = 0.7
			max_speed = 32.0

func enter(player: Node3D) -> void:
	if occupied:
		return
	occupied = true
	freeze = false
	player.visible = false
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	if player.has_method("set_in_vehicle"):
		player.set_in_vehicle(self)

func exit(player: Node3D) -> void:
	if not occupied:
		return
	occupied = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = true
	player.global_position = _exit.global_position
	player.visible = true
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
	if player.has_method("clear_vehicle"):
		player.clear_vehicle()
	GameState.toast.emit("Left vehicle", 1.2)

func _physics_process(delta: float) -> void:
	if _crash_cd > 0.0:
		_crash_cd -= delta
	if not occupied:
		return
	_throttle = Input.get_axis("move_back", "move_forward")
	_steer = Input.get_axis("move_right", "move_left")
	_handbrake = Input.is_action_pressed("handbrake")

	var forward := -global_transform.basis.z
	var right := global_transform.basis.x
	var speed := Vector3(linear_velocity.x, 0.0, linear_velocity.z).length()

	var power := 12000.0 * engine_force_mult
	if _handbrake:
		power *= 0.25
	apply_central_force(forward * _throttle * power * delta)

	var steer_input := _steer * max_steer
	if _handbrake:
		steer_input *= 1.5
	var yaw_torque := steer_input * clampf(speed, 0.5, 18.0) * 900.0
	apply_torque(Vector3.UP * yaw_torque * delta)

	var lat := linear_velocity.dot(right)
	var grip := 8.0 if not _handbrake else 2.0
	apply_central_force(-right * lat * mass * grip * delta)

	var drag := 0.35 if not _handbrake else 1.1
	apply_central_force(-linear_velocity * drag * mass * 0.15)

	if speed > max_speed:
		var hz := Vector3(linear_velocity.x, 0.0, linear_velocity.z)
		hz = hz.normalized() * max_speed
		linear_velocity.x = hz.x
		linear_velocity.z = hz.z

	if absf(rotation.x) > 0.2 or absf(rotation.z) > 0.2:
		angular_velocity *= 0.85

func _on_body_entered(body: Node) -> void:
	if not occupied or _crash_cd > 0.0:
		return
	if body is StaticBody3D or body.is_in_group("ped"):
		var impact := linear_velocity.length()
		if impact > 8.0:
			_crash_cd = 1.0
			health = maxi(0, health - int(impact * 0.4))
			linear_velocity *= -0.2
			angular_velocity *= 0.5
			GameState.raise_district_heat(GameState.current_district_id, 3)
			if impact > 12.0:
				GameState.toast.emit("Crashed", 1.5)
				if GameState.wanted_level < 5:
					GameState.set_wanted(GameState.wanted_level + 1)
