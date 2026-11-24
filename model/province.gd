class_name Province
extends RefCounted

var id: String
var name: String
var owner_id: String
var income: float
var points: PackedVector2Array
var neighbors: Array[String] = []   # заполняется автоматически в GameState


func _init(p_id: String, p_name: String, p_owner: String, p_income: float, p_points: PackedVector2Array) -> void:
	id = p_id
	name = p_name
	owner_id = p_owner
	income = p_income
	points = p_points


func center() -> Vector2:
	var sum := Vector2.ZERO
	for p in points:
		sum += p
	return sum / points.size()