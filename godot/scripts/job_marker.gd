extends Area3D
## Street job marker — bootlegging / protection / smuggling (BETA jobs).

enum JobKind { BOOTLEGGING, PROTECTION, SMUGGLING, HIT }

@export var job_kind: JobKind = JobKind.BOOTLEGGING
@export var payout: int = 400

var _active: bool = false
var _time_left: float = 0.0
var _player_near: bool = false

func _ready() -> void:
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

func _process(delta: float) -> void:
	if _active:
		_time_left -= delta
		if _time_left <= 0.0:
			_complete()
		return
	if _player_near and Input.is_action_just_pressed("interact"):
		_start()

func _start() -> void:
	_active = true
	match job_kind:
		JobKind.BOOTLEGGING:
			_time_left = Balance.BOOTLEG_DURATION
		JobKind.PROTECTION:
			_time_left = Balance.PROTECTION_DURATION
		JobKind.SMUGGLING:
			_time_left = Balance.SMUGGLING_DURATION
		JobKind.HIT:
			_time_left = 5.0
	GameState.toast.emit("Job started", 1.5)
	GameState.feed_line.emit("Job started")

func _complete() -> void:
	_active = false
	GameState.add_cash(payout)
	GameState.raise_district_heat(GameState.current_district_id, Balance.HEAT_JOB_MULT * 3)
	Empire.earn_street_respect(1)
	GameState.toast.emit("Job finished +$%d" % payout, Balance.TOAST_JOB_SEC)
	GameState.feed_line.emit("Job finished")
	if GameState.wanted_level < 5 and GameState.current_heat() > 40:
		GameState.set_wanted(mini(5, GameState.wanted_level + 1))

func _on_enter(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_near = true

func _on_exit(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_near = false

func prompt() -> String:
	if _active:
		return "Job… %.0fs" % _time_left
	if _player_near:
		return "[E] %s" % kind_label()
	return ""

func kind_label() -> String:
	match job_kind:
		JobKind.BOOTLEGGING:
			return "Bootlegging"
		JobKind.PROTECTION:
			return "Protection"
		JobKind.SMUGGLING:
			return "Smuggling"
		JobKind.HIT:
			return "Hit"
	return "Job"
