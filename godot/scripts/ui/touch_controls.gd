extends CanvasLayer
## Virtual controls for Godot mobile editor / touch devices.
## Left half: move stick. Right half: look drag. Buttons: E, sprint.

signal interact_pressed
signal sprint_changed(pressed: bool)

var move_vector: Vector2 = Vector2.ZERO
var look_delta: Vector2 = Vector2.ZERO

var _move_touch: int = -1
var _look_touch: int = -1
var _move_origin: Vector2 = Vector2.ZERO
var _look_last: Vector2 = Vector2.ZERO
var _sprint: bool = false

@onready var _root: Control = $Root
@onready var _stick_bg: Panel = $Root/StickBg
@onready var _stick_knob: Panel = $Root/StickBg/Knob
@onready var _btn_e: Button = $Root/BtnE
@onready var _btn_sprint: Button = $Root/BtnSprint

func _ready() -> void:
	layer = 20
	var touch := DisplayServer.is_touchscreen_available()
	var mobile := OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")
	_root.visible = touch or mobile
	if not _root.visible:
		return
	# Don't capture mouse on phone
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_btn_e.pressed.connect(func(): interact_pressed.emit())
	_btn_sprint.button_down.connect(func():
		_sprint = true
		sprint_changed.emit(true)
	)
	_btn_sprint.button_up.connect(func():
		_sprint = false
		sprint_changed.emit(false)
	)

func is_sprint() -> bool:
	return _sprint

func consume_look_delta() -> Vector2:
	var d := look_delta
	look_delta = Vector2.ZERO
	return d

func _input(event: InputEvent) -> void:
	if not _root.visible:
		return
	var vp := get_viewport().get_visible_rect().size
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			if st.position.x < vp.x * 0.45 and _move_touch < 0:
				_move_touch = st.index
				_move_origin = st.position
				_update_stick(Vector2.ZERO)
			elif st.position.x > vp.x * 0.55 and _look_touch < 0:
				_look_touch = st.index
				_look_last = st.position
		else:
			if st.index == _move_touch:
				_move_touch = -1
				move_vector = Vector2.ZERO
				_update_stick(Vector2.ZERO)
			if st.index == _look_touch:
				_look_touch = -1
	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		if sd.index == _move_touch:
			var raw: Vector2 = sd.position - _move_origin
			var max_r := 72.0
			if raw.length() > max_r:
				raw = raw.normalized() * max_r
			move_vector = raw / max_r
			# Godot move: y forward is negative in get_vector convention for our player
			move_vector = Vector2(move_vector.x, move_vector.y)
			_update_stick(raw)
		elif sd.index == _look_touch:
			look_delta += sd.position - _look_last
			_look_last = sd.position

func _update_stick(offset: Vector2) -> void:
	if _stick_knob:
		_stick_knob.position = Vector2(36, 36) + offset - Vector2(20, 20)
