class_name ArmyView
extends Node2D

const HALF := 10.0

var state: GameState
var selected := ""


func setup(game_state: GameState) -> void:
	state = game_state
	state.changed.connect(queue_redraw)


func select(id: String) -> void:
	selected = id
	queue_redraw()


func army_at(pos: Vector2) -> String:
	for id in state.armies:
		if _rect(state.get_army(id)).has_point(pos):
			return id
	return ""


func _rect(a: Army) -> Rect2:
	var p := state.army_position(a)
	return Rect2(p - Vector2(HALF, HALF), Vector2(HALF * 2, HALF * 2))


func _draw() -> void:
	for id in state.armies:
		var a := state.get_army(id)
		var rect := _rect(a)
		var fill := state.get_country(a.owner_id).color.darkened(0.45)
		draw_rect(rect, fill)
		var chosen: bool = id == selected
		draw_rect(rect, Color.WHITE if chosen else Color.BLACK, false, 3.0 if chosen else 2.0)
		if a.is_moving():
			draw_line(state.army_position(a), state.get_province(a.target_id).center(), Color(1, 1, 1, 0.7), 2.0)
