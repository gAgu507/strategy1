class_name MapView
extends Node2D

signal province_selected(id: String)

var state: GameState
var _polys := {}
var _selected := ""


func setup(game_state: GameState) -> void:
	state = game_state
	for id in state.provinces:
		var poly := Polygon2D.new()
		poly.polygon = state.provinces[id]["points"]
		add_child(poly)
		_polys[id] = poly

		var outline := Line2D.new()
		outline.points = state.provinces[id]["points"]
		outline.closed = true
		outline.width = 2
		outline.default_color = Color.BLACK
		poly.add_child(outline)

	state.changed.connect(refresh)
	refresh()


func refresh() -> void:
	for id in _polys:
		var c: Color = state.province_color(id)
		_polys[id].color = c.lightened(0.4) if id == _selected else c


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_selected = _province_at(get_local_mouse_position())
		refresh()
		province_selected.emit(_selected)


func _province_at(pos: Vector2) -> String:
	for id in state.provinces:
		if Geometry2D.is_point_in_polygon(pos, state.provinces[id]["points"]):
			return id
	return ""
