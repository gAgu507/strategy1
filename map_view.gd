class_name MapView
extends Node2D

signal province_selected(id: String)
signal army_selected(id: String)
signal move_requested(army_id: String, province_id: String)

var state: GameState
var _polys := {}
var _selected := ""
var _armies: ArmyView


func setup(game_state: GameState) -> void:
	state = game_state
	for id in state.provinces:
		var p := state.get_province(id)
		var poly := Polygon2D.new()
		poly.polygon = p.points
		add_child(poly)
		_polys[id] = poly

		var outline := Line2D.new()
		outline.points = p.points
		outline.closed = true
		outline.width = 2
		outline.default_color = Color.BLACK
		poly.add_child(outline)

	# армии добавляются последними, чтобы рисоваться поверх провинций
	_armies = ArmyView.new()
	add_child(_armies)
	_armies.setup(state)

	state.changed.connect(refresh)
	refresh()


func refresh() -> void:
	for id in _polys:
		var c := state.province_color(id)
		_polys[id].color = c.lightened(0.4) if id == _selected else c


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	var pos := get_local_mouse_position()
	if event.button_index == MOUSE_BUTTON_LEFT:
		var army_id := _armies.army_at(pos)
		_armies.select(army_id)
		army_selected.emit(army_id)
		_selected = _province_at(pos)
		refresh()
		province_selected.emit(_selected)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		var target := _province_at(pos)
		print("RMB: selected=", _armies.selected, " target=", target)
		if _armies.selected != "" and target != "":
			move_requested.emit(_armies.selected, target)


func _province_at(pos: Vector2) -> String:
	for id in state.provinces:
		if Geometry2D.is_point_in_polygon(pos, state.get_province(id).points):
			return id
	return ""
