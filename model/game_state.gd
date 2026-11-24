class_name GameState
extends RefCounted

signal changed

const BATTLE_DAMAGE := 0.1

var player := "nor"
var countries := {}   # id -> Country
var provinces := {}   # id -> Province
var armies := {}      # id -> Army


func _init() -> void:
	_add_country(Country.new("nor", "Северное королевство", Color("6a9955")))
	_add_country(Country.new("eas", "Восточный союз", Color("c586c0")))
	_add_country(Country.new("wes", "Западная республика", Color("4ec9b0")))
	_add_country(Country.new("sou", "Южные земли", Color("d7ba7d")))

	_add_province(Province.new("a", "Северная марка", "nor", 1.5, PackedVector2Array([
		Vector2(100, 100), Vector2(300, 100), Vector2(300, 250), Vector2(100, 250)])))
	_add_province(Province.new("b", "Восточные земли", "eas", 2.0, PackedVector2Array([
		Vector2(300, 100), Vector2(520, 120), Vector2(500, 260), Vector2(300, 250)])))
	_add_province(Province.new("c", "Западный берег", "wes", 1.0, PackedVector2Array([
		Vector2(100, 250), Vector2(300, 250), Vector2(320, 400), Vector2(120, 380)])))
	_add_province(Province.new("d", "Южные степи", "sou", 0.5, PackedVector2Array([
		Vector2(300, 250), Vector2(500, 260), Vector2(520, 400), Vector2(320, 400)])))
	_compute_neighbors()

	_add_army(Army.new("army_nor", "nor", "a", 1000))
	_add_army(Army.new("army_eas", "eas", "b", 800))


# --- Доступ с типами (чтобы редактор подсказывал поля) ---
func get_country(id: String) -> Country:
	return countries[id]


func get_province(id: String) -> Province:
	return provinces[id]


func get_army(id: String) -> Army:
	return armies[id]


# --- Правила ---
func tick_day() -> void:
	for id in provinces:
		var p := get_province(id)
		get_country(p.owner_id).treasury += p.income
	for id in armies:
		get_army(id).advance_day()
	_resolve_battles()
	_update_ownership()
	changed.emit()


func order_move(army_id: String, province_id: String) -> bool:
	if not armies.has(army_id):   # армия могла погибнуть
		return false
	var a := get_army(army_id)
	var origin := get_province(a.province_id)
	if a.owner_id != player or a.is_moving() or not origin.neighbors.has(province_id):
		return false
	a.order_move(province_id)
	changed.emit()
	return true


func country_income(country_id: String) -> float:
	var total := 0.0
	for id in provinces:
		var p := get_province(id)
		if p.owner_id == country_id:
			total += p.income
	return total


func province_color(id: String) -> Color:
	return get_country(get_province(id).owner_id).color


func army_position(a: Army) -> Vector2:
	var from_pos := get_province(a.province_id).center()
	if not a.is_moving():
		return from_pos
	return from_pos.lerp(get_province(a.target_id).center(), a.progress())


# --- Внутреннее ---
func _add_country(c: Country) -> void:
	countries[c.id] = c


func _add_province(p: Province) -> void:
	provinces[p.id] = p


func _add_army(a: Army) -> void:
	armies[a.id] = a


func _standing_armies_in(province_id: String) -> Array[Army]:
	var result: Array[Army] = []
	for id in armies:
		var a := get_army(id)
		if a.province_id == province_id and not a.is_moving():
			result.append(a)
	return result


func _resolve_battles() -> void:
	for pid in provinces:
		var here := _standing_armies_in(pid)
		if here.size() < 2:
			continue
		# сначала считаем урон для всех, потом применяем: бой одновременный
		var damage := {}
		for a in here:
			var enemy_total := 0
			for other in here:
				if other.owner_id != a.owner_id:
					enemy_total += other.size
			damage[a.id] = int(ceil(enemy_total * BATTLE_DAMAGE))
		for a in here:
			a.size -= int(damage[a.id])
			if a.size <= 0:
				armies.erase(a.id)


func _update_ownership() -> void:
	for pid in provinces:
		var here := _standing_armies_in(pid)
		if here.is_empty():
			continue
		var p := get_province(pid)
		var owners := {}
		for a in here:
			owners[a.owner_id] = true
		if owners.size() == 1 and not owners.has(p.owner_id):
			p.owner_id = here[0].owner_id

# Соседи: провинции, у которых минимум две общие вершины
func _compute_neighbors() -> void:
	var ids := provinces.keys()
	for i in ids.size():
		for j in range(i + 1, ids.size()):
			var a := get_province(ids[i])
			var b := get_province(ids[j])
			if _shared_points(a, b) >= 2:
				a.neighbors.append(b.id)
				b.neighbors.append(a.id)


func _shared_points(a: Province, b: Province) -> int:
	var count := 0
	for p in a.points:
		if b.points.has(p):
			count += 1
	return count
