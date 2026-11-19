extends Node2D

signal day_passed

const MONTH_NAMES := ["января", "февраля", "марта", "апреля", "мая", "июня",
	"июля", "августа", "сентября", "октября", "ноября", "декабря"]
const DAYS_IN_MONTH := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
const SECONDS_PER_DAY := [1.0, 0.4, 0.1]   # для скоростей 1, 2, 3

var provinces := {
	"a": {
		"name": "Северная марка",
		"color": Color("6a9955"),
		"points": PackedVector2Array([Vector2(100, 100), Vector2(300, 100), Vector2(300, 250), Vector2(100, 250)]),
	},
	"b": {
		"name": "Восточные земли",
		"color": Color("c586c0"),
		"points": PackedVector2Array([Vector2(300, 100), Vector2(520, 120), Vector2(500, 260), Vector2(300, 250)]),
	},
	"c": {
		"name": "Западный берег",
		"color": Color("4ec9b0"),
		"points": PackedVector2Array([Vector2(100, 250), Vector2(300, 250), Vector2(320, 400), Vector2(120, 380)]),
	},
	"d": {
		"name": "Южные степи",
		"color": Color("dcdcaa"),
		"points": PackedVector2Array([Vector2(300, 250), Vector2(500, 260), Vector2(520, 400), Vector2(320, 400)]),
	},
}

var polys := {}      # id -> Polygon2D (только отображение)
var selected := ""   # id выбранной провинции

var year := 1444
var month := 11   # 1-12
var day := 11
var speed := 1    # 1-3
var paused := true
var day_timer := 0.0


@onready var label: Label = $ProvinceNameLabel
@onready var date_label: Label = $DateLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for id in provinces:
		var poly := Polygon2D.new()
		poly.polygon = provinces[id]["points"]
		poly.color = provinces[id]["color"]
		add_child(poly)
		polys[id] = poly
		
		var outline := Line2D.new()
		outline.points = provinces[id]["points"]
		outline.closed = true
		outline.width = 2
		outline.default_color = Color.BLACK
		poly.add_child(outline)
		
	_update_date_label()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select(_province_at(get_global_mouse_position()))
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				paused = not paused
			KEY_1:
				speed = 1
			KEY_2:
				speed = 2
			KEY_3:
				speed = 3
		_update_date_label()


func _province_at(pos: Vector2) -> String:
	for id in provinces:
		if Geometry2D.is_point_in_polygon(pos, provinces[id]["points"]):
			return id
	return ""


func _select(id: String) -> void:
	if selected != "":
		polys[selected].color = provinces[selected]["color"]
	selected = id
	if id == "":
		label.text = ""
		return
	polys[id].color = provinces[id]["color"].lightened(0.4)
	label.text = provinces[id]["name"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if paused:
		return
	day_timer += delta
	var step: float = SECONDS_PER_DAY[speed - 1]
	while day_timer >= step:
		day_timer -= step
		_advance_day()

func _advance_day() -> void:
	day += 1
	if day > DAYS_IN_MONTH[month - 1]:
		day = 1
		month += 1
		if month > 12:
			month = 1
			year += 1
	_update_date_label()
	day_passed.emit()

func _update_date_label() -> void:
	var state := "Пауза" if paused else "x%d" % speed
	date_label.text = "%d %s %d  |  %s" % [day, MONTH_NAMES[month - 1], year, state]
