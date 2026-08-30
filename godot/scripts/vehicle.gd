extends RigidBody3D
## Arcade vehicle inspired by BETA vehicle_phys.zig (Phase 5).
## Godot physics instead of pure raycast integrate — same controls & feel goals.

enum VehicleType { SEDAN, TAXI, TRUCK, MOTORCYCLE }

@export var vehicle_type: VehicleType = VehicleType.SEDAN
@export var max_steer: float = 0.55
@export var engine_force_mult: float = 1.0
@export var health: int = 100

var occupied: bool = false
var _steer: float = 0.0
var _throttle: float = 0.0
var _handbrake: bool = false

@onready var _seat: Marker3D = $Seat
@onready var _exit: Marker3D = $ExitPoint

func _ready() -> void:
	_apply_tuning()
	freeze = true  # parked until entered

func _apply_tuning() -> void:
	# Mass/power proxies from PhysTuning
	match vehicle_type:
		VehicleType.SEDAN:
			mass = 1200
			engine_force_mult = 1.0
			max_steer = 0.55
		VehicleType.TAXI:
			mass = 1250
			engine_force_mult = 0.95
			max_steer = 0.52
		VehicleType.TRUCK:
			mass = 2800
			engine_force_mult = 0.7
			max_steer = 0.42
		VehicleType.MOTORCYCLE:
			mass = 220
			engine_force_mult = 1.3
			max_steer = 0.7

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

func _physics_process(delta: float) -> void:
	if not occupied:
		return
	_throttle = Input.get_axis("move_back", "move_forward")
	_steer = Input.get_axis("move_right", "move_left") * max_steer
	_handbrake = Input.is_action_pressed("handbrake")

	var forward := -global_transform.basis.z
	var speed := linear_velocity.length()
	var force := _throttle * 9000.0 * engine_force_mult
	if _handbrake:
		force *= 0.3
	apply_central_force(forward * force * delta * 60.0)

	# Steering yaw
	var steer_power := _steer * (1.0 + speed * 0.08)
	if _handbrake:
		steer_power *= 1.4  # oversteer bias
	apply_torque(Vector3.UP * steer_power * 4000.0 * delta)

	# Drag
	apply_central_force(-linear_velocity * (0.4 if not _handbrake else 1.2))

	# Keep camera-ish upright lightly
	if absf(rotation.x) > 0.3 or absf(rotation.z) > 0.3:
		angular_velocity *= 0.9
