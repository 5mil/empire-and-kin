extends Area3D
## Safehouse — stand inside to bleed heat and heal slowly.

var _player_inside: bool = false

func _ready() -> void:
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)
	monitoring = true
	collision_layer = 0
	collision_mask = 2

func _on_enter(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		GameState.toast.emit("Safehouse", 1.5)
		GameState.feed_line.emit("Safehouse — cooling off")

func _on_exit(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = false

func _process(delta: float) -> void:
	if not _player_inside:
		return
	if randf() < delta * 0.8:
		var h := GameState.current_heat()
		if h > 0:
			GameState.raise_district_heat(GameState.current_district_id, -2)
	if GameState.wanted_level > 0 and randf() < delta * 0.25:
		GameState.set_wanted(GameState.wanted_level - 1)
	if GameState.health < 100 and randf() < delta * 0.5:
		GameState.heal(2)
