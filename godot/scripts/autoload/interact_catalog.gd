extends Node
## ~40 world interact definitions from Zig interact.zig + shop modules.

func catalog() -> Array:
	return [
		_s("fence", "[E] Fence — cool heat $200", Vector3(8, 1, 18), Color(0.47, 0.35, 0.16)),
		_s("stash", "[E] Stash $250", Vector3(-6, 1, 16), Color(0.24, 0.2, 0.16)),
		_s("doc", "[E] Doc $300", Vector3(18, 1, 6), Color(0.78, 0.78, 0.82)),
		_s("numbers", "[E] Numbers $100", Vector3(-12, 1, 8), Color(0.35, 0.27, 0.43)),
		_s("bar", "[E] Drink $50", Vector3(4, 1, -8), Color(0.39, 0.24, 0.16)),
		_s("vendor", "[E] Medkit $200", Vector3(-4, 1, -12), Color(0.7, 0.55, 0.24)),
		_s("phone", "[E] Phone tip $25", Vector3(10, 1, 2), Color(0.16, 0.2, 0.31)),
		_s("paper", "[E] Paper $5", Vector3(-2, 1, 4), Color(0.59, 0.39, 0.2)),
		_s("church", "[E] Confess", Vector3(22, 1, -18), Color(0.7, 0.68, 0.63)),
		_s("dock", "[E] Dock collect", Vector3(28, 1, 22), Color(0.35, 0.27, 0.2)),
		_s("blackjack", "[E] Gamble $100", Vector3(-16, 1, -6), Color(0.31, 0.16, 0.24)),
		_s("informant", "[E] Informant $250", Vector3(14, 1, 20), Color(0.27, 0.27, 0.2)),
		_s("warehouse", "[E] Warehouse $500", Vector3(-22, 1, 18), Color(0.39, 0.37, 0.33)),
		_s("arcade", "[E] Arcade $10", Vector3(6, 1, 24), Color(0.78, 0.2, 0.31)),
		_s("taxi", "[E] Taxi home $40", Vector3(0, 1, 28), Color(0.86, 0.7, 0.16)),
		_s("bakery", "[E] Bakery $15", Vector3(-10, 1, -16), Color(0.82, 0.7, 0.47)),
		_s("barber", "[E] Barber $20", Vector3(16, 1, -6), Color(0.63, 0.63, 0.67)),
		_s("laundry", "[E] Laundry $30", Vector3(-18, 1, 4), Color(0.55, 0.63, 0.7)),
		_s("perfume", "[E] Perfume $75", Vector3(20, 1, 12), Color(0.78, 0.47, 0.63)),
		_s("cigar", "[E] Cigar $40", Vector3(-8, 1, 22), Color(0.35, 0.24, 0.16)),
		_s("post", "[E] Mail", Vector3(12, 1, -20), Color(0.7, 0.2, 0.16)),
		_s("recruit", "[E] Recruit $600", Vector3(15, 1, 20), Color(0.39, 0.31, 0.24)),
		_s("alley", "[E] Alley deal", Vector3(-14, 1, 12), Color(0.2, 0.22, 0.18)),
		_s("hospital", "[E] Hospital $400", Vector3(24, 1, 8), Color(0.85, 0.85, 0.9)),
		_s("intimidate", "[E] Lean on the block", Vector3(-20, 1, -10), Color(0.4, 0.15, 0.15)),
		_s("lookout", "[E] Post lookout", Vector3(2, 1, 14), Color(0.3, 0.35, 0.2)),
		_s("numbers2", "[E] Policy bank $100", Vector3(8, 1, -16), Color(0.32, 0.22, 0.4)),
		_s("speak", "[E] Speakeasy back room", Vector3(-24, 1, -4), Color(0.28, 0.18, 0.12)),
		_s("garage", "[E] Garage — tune ride", Vector3(26, 1, -8), Color(0.25, 0.25, 0.28)),
		_s("pawn", "[E] Pawn $150", Vector3(-26, 1, 8), Color(0.45, 0.4, 0.2)),
		_s("bookie", "[E] Bookie $80", Vector3(18, 1, 26), Color(0.2, 0.35, 0.25)),
		_s("florist", "[E] Flowers $20", Vector3(-5, 1, -22), Color(0.5, 0.7, 0.4)),
		_s("butcher", "[E] Butcher drop", Vector3(11, 1, 10), Color(0.55, 0.2, 0.2)),
		_s("tailor", "[E] Tailor $60", Vector3(-11, 1, 26), Color(0.2, 0.25, 0.45)),
		_s("union", "[E] Union hall", Vector3(30, 1, 4), Color(0.35, 0.3, 0.25)),
		_s("newsstand2", "[E] Racing form $8", Vector3(-28, 1, -14), Color(0.5, 0.35, 0.15)),
		_s("fireescape", "[E] Climb fire escape", Vector3(7, 1, -24), Color(0.4, 0.4, 0.42)),
		_s("piers", "[E] Night pier", Vector3(32, 1, 16), Color(0.15, 0.2, 0.3)),
		_s("club", "[E] After-hours club", Vector3(-30, 1, 16), Color(0.45, 0.1, 0.35)),
		_s("safe_stash", "[F via E] Empty safe stash", Vector3(-20, 1, -12), Color(0.2, 0.4, 0.25)),
	]

func _s(id: String, prompt: String, pos: Vector3, col: Color) -> Dictionary:
	return {"id": id, "prompt": prompt, "pos": pos, "color": col}

func spawn_all(parent: Node) -> void:
	for spec in catalog():
		var area := Area3D.new()
		area.name = "Spot_%s" % spec["id"]
		area.position = spec["pos"]
		var script: Script = load("res://scripts/interact_spot.gd")
		area.set_script(script)
		area.spot_id = spec["id"]
		area.prompt = spec["prompt"]
		area.marker_color = spec["color"]
		var col := CollisionShape3D.new()
		var sph := SphereShape3D.new()
		sph.radius = 2.2
		col.shape = sph
		area.add_child(col)
		parent.add_child(area)

func activate(spot_id: String) -> void:
	match spot_id:
		"fence":
			_pay(Balance.FENCE_HEAT_COST, func():
				GameState.raise_district_heat(GameState.current_district_id, -15)
				GameState.toast.emit("Fence: heat down", 2.0))
		"stash":
			if WorldSim.deposit_stash(Balance.STASH_CHUNK):
				GameState.toast.emit("Stashed $250", 1.8)
			elif WorldSim.withdraw_stash(Balance.STASH_CHUNK) > 0:
				GameState.toast.emit("Withdrew $250", 1.8)
			else:
				GameState.toast.emit("Stash empty / no cash", 1.5)
		"doc":
			_pay(300, func():
				GameState.heal(40)
				GameState.toast.emit("Doc patched you", 2.0))
		"numbers", "numbers2":
			_gamble(100, 0.42, 280)
		"bar":
			_pay(50, func():
				GameState.calm = mini(100, GameState.calm + 8)
				GameState.toast.emit("Had a drink", 1.6))
		"vendor":
			_pay(200, func(): GameState.heal(25); GameState.toast.emit("Bought medkit", 1.6))
		"phone":
			_pay(25, func(): GameState.add_cash(55); GameState.toast.emit("Phone tip +$55", 1.8))
		"paper", "newsstand2":
			_pay(5 if spot_id == "paper" else 8, func(): GameState.feed_line.emit("Read the sheet"))
		"church":
			GameState.raise_district_heat(GameState.current_district_id, -8)
			if GameState.wanted_level > 0:
				GameState.set_wanted(GameState.wanted_level - 1)
			GameState.toast.emit("Confessed", 2.0)
		"dock":
			var pay := 120 + GameState.current_control()
			GameState.add_cash(pay)
			GameState.toast.emit("Dock payout $%d" % pay, 2.0)
		"blackjack", "bookie":
			_gamble(100 if spot_id == "blackjack" else 80, 0.45, 220)
		"informant":
			_pay(250, func():
				WorldSim.ease_rival(18)
				GameState.toast.emit("Rival eased", 2.0))
		"warehouse":
			if WorldSim.deposit_stash(500):
				GameState.toast.emit("Warehouse $500", 2.0)
			else:
				GameState.toast.emit("Need $500 cash", 1.5)
		"arcade":
			_pay(10, func(): GameState.calm = mini(100, GameState.calm + 4); GameState.toast.emit("Arcade", 1.4))
		"taxi":
			_pay(40, func():
				var p := get_tree().root.find_child("Player", true, false)
				if p:
					p.global_position = Vector3(-18, 1.1, -12)
				GameState.toast.emit("Taxi home", 1.8))
		"bakery":
			_pay(15, func(): Empire.earn_favor(2); GameState.toast.emit("Cannoli run", 1.6))
		"barber":
			_pay(20, func(): GameState.raise_district_heat(GameState.current_district_id, -4); GameState.toast.emit("Clean cut", 1.6))
		"laundry":
			_pay(30, func(): GameState.raise_district_heat(GameState.current_district_id, -10); GameState.toast.emit("Laundry cools heat", 1.8))
		"perfume":
			_pay(75, func(): Empire.earn_favor(5); GameState.toast.emit("Gift for the family", 1.8))
		"cigar":
			_pay(40, func(): Empire.earn_street_respect(3); GameState.toast.emit("Cigar lounge", 1.6))
		"post":
			if randf() < 0.3:
				GameState.add_cash(40)
				GameState.toast.emit("Letter with cash", 1.8)
			else:
				GameState.toast.emit("Nothing in the box", 1.4)
		"recruit":
			if not Empire.recruit(WorldSim.random_crew_name()):
				GameState.toast.emit("Can't recruit", 1.5)
		"alley":
			_gamble(80, 0.5, 160)
			GameState.raise_district_heat(GameState.current_district_id, 6)
		"hospital":
			_pay(400, func(): GameState.heal(100); GameState.toast.emit("Hospital", 2.0))
		"intimidate":
			if Empire.crew.size() < 2:
				GameState.toast.emit("Need more muscle", 1.5)
			else:
				GameState.raise_district_heat(GameState.current_district_id, 10)
				var d: Dictionary = GameState.districts[GameState.current_district_id]
				d["control"] = mini(100, int(d["control"]) + 6)
				GameState.districts[GameState.current_district_id] = d
				Empire.earn_street_respect(4)
				GameState.toast.emit("Enforcers on the street", 2.0)
		"lookout":
			GameState.raise_district_heat(GameState.current_district_id, -5)
			GameState.toast.emit("Lookout posted", 1.8)
		"speak":
			Empire.collect_all()
		"garage":
			_pay(120, func(): GameState.toast.emit("Ride tuned", 1.6))
		"pawn":
			GameState.add_cash(150)
			GameState.raise_district_heat(GameState.current_district_id, 4)
			GameState.toast.emit("Pawned goods +$150", 1.8)
		"florist":
			_pay(20, func(): Empire.earn_favor(1); GameState.toast.emit("Flowers", 1.4))
		"butcher":
			GameState.add_cash(70)
			GameState.toast.emit("Drop collected", 1.6)
		"tailor":
			_pay(60, func(): Empire.earn_street_respect(2); GameState.toast.emit("New threads", 1.6))
		"union":
			Empire.add_racket(Empire.RacketKind.LABOR_UNION, GameState.current_district_id)
			GameState.toast.emit("Union hall tied in", 2.0)
		"fireescape":
			GameState.toast.emit("Rooftop — heat eases", 1.6)
			GameState.raise_district_heat(GameState.current_district_id, -3)
		"piers":
			GameState.feed_line.emit("Dark water. Quiet night.")
		"club":
			_pay(35, func(): GameState.calm = mini(100, GameState.calm + 10); GameState.toast.emit("After hours", 1.6))
		"safe_stash":
			var amt := WorldSim.withdraw_all_stash()
			GameState.toast.emit("Emptied stash $%d" % amt if amt > 0 else "Stash empty", 1.8)
		_:
			GameState.toast.emit(spot_id, 1.2)

func _pay(cost: int, ok: Callable) -> void:
	if GameState.treasury < cost:
		GameState.toast.emit("Need $%d" % cost, 1.4)
		return
	GameState.add_cash(-cost)
	ok.call()

func _gamble(ante: int, win_p: float, payout: int) -> void:
	if GameState.treasury < ante:
		GameState.toast.emit("Need $%d" % ante, 1.4)
		return
	GameState.add_cash(-ante)
	if randf() < win_p:
		GameState.add_cash(payout)
		GameState.toast.emit("Hit +$%d" % payout, 1.8)
	else:
		GameState.toast.emit("Miss", 1.4)
