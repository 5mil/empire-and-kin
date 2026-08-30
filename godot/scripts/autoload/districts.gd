extends Node
## Port of src/game/city.zig + real-world map anchors for authored scenes.

## Approximate real bounds (WGS84) for OSM / future import — not in-game meters.
const REAL_BOUNDS := {
	"little_italy": {
		"name": "Little Italy",
		"center": Vector2(40.7191, -73.9973),
		"note": "Mulberry / Grand historic core",
	},
	"hells_kitchen": {
		"name": "Hell's Kitchen",
		"center": Vector2(40.7638, -73.9918),
		"note": "Midtown West ~34th–59th, 8th–12th Ave",
	},
	"brooklyn_waterfront": {
		"name": "Brooklyn Waterfront",
		"center": Vector2(40.6782, -74.0042),
		"note": "Red Hook / Columbia Street waterfront",
	},
	"lower_east_side": {
		"name": "Lower East Side",
		"center": Vector2(40.7150, -73.9843),
		"note": "LES south of Houston",
	},
	"harlem": {
		"name": "Harlem",
		"center": Vector2(40.8116, -73.9465),
		"note": "Central Harlem",
	},
	"midtown": {
		"name": "Midtown",
		"center": Vector2(40.7549, -73.9840),
		"note": "Midtown Manhattan core",
	},
}

func create_all() -> Dictionary:
	# Stats from BETA city.createDistrict
	return {
		"lower_east_side": _d("Lower East Side", 35, 20, 180, 4200),
		"little_italy": _d("Little Italy", 55, 15, 220, 2800),
		"hells_kitchen": _d("Hell's Kitchen", 40, 35, 260, 5100),
		"harlem": _d("Harlem", 25, 25, 190, 6800),
		"brooklyn_waterfront": _d("Brooklyn Waterfront", 30, 40, 310, 3500),
		"midtown": _d("Midtown", 10, 60, 450, 9200),
	}

func _d(name: String, control: int, heat: int, racket_income: int, population: int) -> Dictionary:
	return {
		"name": name,
		"control": control,
		"heat": heat,
		"racket_income": racket_income,
		"population": population,
	}

func display_name(id: String) -> String:
	if REAL_BOUNDS.has(id):
		return REAL_BOUNDS[id]["name"]
	if GameState.districts.has(id):
		return str(GameState.districts[id]["name"])
	return id

func real_center(id: String) -> Vector2:
	if REAL_BOUNDS.has(id):
		return REAL_BOUNDS[id]["center"]
	return Vector2.ZERO
