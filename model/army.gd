class_name Army
extends RefCounted

const MOVE_DAYS := 3

var id: String
var owner_id: String
var province_id: String   # где стоит (или откуда вышла)
var target_id := ""       # куда идёт, "" если стоит
var days_left := 0
var size: int


func _init(p_id: String, p_owner: String, p_province: String, p_size := 1000) -> void:
	id = p_id
	owner_id = p_owner
	province_id = p_province
	size = p_size


func is_moving() -> bool:
	return target_id != ""


func order_move(target: String) -> void:
	target_id = target
	days_left = MOVE_DAYS


# Возвращает true, если армия в этот день дошла до цели
func advance_day() -> bool:
	if not is_moving():
		return false
	days_left -= 1
	if days_left > 0:
		return false
	province_id = target_id
	target_id = ""
	return true


# Доля пройденного пути от 0 до 1
func progress() -> float:
	if not is_moving():
		return 0.0
	return float(MOVE_DAYS - days_left) / MOVE_DAYS
