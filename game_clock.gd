class_name GameClock
extends Node

signal day_passed
signal changed

const MONTH_NAMES := ["января", "февраля", "марта", "апреля", "мая", "июня",
	"июля", "августа", "сентября", "октября", "ноября", "декабря"]
const DAYS_IN_MONTH := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
const SECONDS_PER_DAY := [1.0, 0.4, 0.1]   # для скоростей 1, 2, 3

var year := 1444
var month := 11
var day := 11
var speed := 1
var paused := true
var _day_timer := 0.0


func _process(delta: float) -> void:
	if paused:
		return
	_day_timer += delta
	var step: float = SECONDS_PER_DAY[speed - 1]
	while _day_timer >= step:
		_day_timer -= step
		_advance_day()


func toggle_pause() -> void:
	paused = not paused
	changed.emit()


func set_speed(value: int) -> void:
	speed = clampi(value, 1, 3)
	changed.emit()


func date_text() -> String:
	var mode := "Пауза" if paused else "x%d" % speed
	return "%d %s %d  |  %s" % [day, MONTH_NAMES[month - 1], year, mode]


func _advance_day() -> void:
	day += 1
	if day > DAYS_IN_MONTH[month - 1]:
		day = 1
		month += 1
		if month > 12:
			month = 1
			year += 1
	day_passed.emit()
	changed.emit()
