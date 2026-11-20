class_name GameState
extends RefCounted

signal changed

var player := "nor"

var countries := {
	"nor": {"name": "Северное королевство", "color": Color("6a9955"), "treasury": 100.0},
	"eas": {"name": "Восточный союз", "color": Color("c586c0"), "treasury": 100.0},
	"wes": {"name": "Западная республика", "color": Color("4ec9b0"), "treasury": 100.0},
	"sou": {"name": "Южные земли", "color": Color("d7ba7d"), "treasury": 100.0},
}

var provinces := {
	"a": {
		"name": "Северная марка", "owner": "nor", "income": 1.5,
		"points": PackedVector2Array([Vector2(100, 100), Vector2(300, 100), Vector2(300, 250), Vector2(100, 250)]),
	},
	"b": {
		"name": "Восточные земли", "owner": "eas", "income": 2.0,
		"points": PackedVector2Array([Vector2(300, 100), Vector2(520, 120), Vector2(500, 260), Vector2(300, 250)]),
	},
	"c": {
		"name": "Западный берег", "owner": "wes", "income": 1.0,
		"points": PackedVector2Array([Vector2(100, 250), Vector2(300, 250), Vector2(320, 400), Vector2(120, 380)]),
	},
	"d": {
		"name": "Южные степи", "owner": "sou", "income": 0.5,
		"points": PackedVector2Array([Vector2(300, 250), Vector2(500, 260), Vector2(520, 400), Vector2(320, 400)]),
	},
}


func tick_day() -> void:
	for id in provinces:
		var owner_id: String = provinces[id]["owner"]
		countries[owner_id]["treasury"] += provinces[id]["income"]
	changed.emit()


func country_income(country_id: String) -> float:
	var total := 0.0
	for id in provinces:
		if provinces[id]["owner"] == country_id:
			total += provinces[id]["income"]
	return total


func province_color(id: String) -> Color:
	return countries[provinces[id]["owner"]]["color"]


func capture(province_id: String, country_id: String) -> void:
	provinces[province_id]["owner"] = country_id
	changed.emit()
