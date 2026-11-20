class_name InfoPanel
extends CanvasLayer

@onready var info_label: Label = $InfoLabel
@onready var date_label: Label = $DateLabel

var state: GameState
var clock: GameClock
var _selected := ""


func setup(game_state: GameState, game_clock: GameClock) -> void:
	state = game_state
	clock = game_clock
	state.changed.connect(refresh)
	clock.changed.connect(refresh)
	refresh()


func show_province(id: String) -> void:
	_selected = id
	refresh()


func refresh() -> void:
	date_label.text = clock.date_text()

	var lines: PackedStringArray = []
	for id in state.countries:
		var c: Dictionary = state.countries[id]
		var mark := "> " if id == state.player else "    "
		lines.append("%s%s: %.1f (+%.1f)" % [mark, c["name"], c["treasury"], state.country_income(id)])

	if _selected != "":
		var p: Dictionary = state.provinces[_selected]
		lines.append("")
		lines.append(p["name"])
		lines.append("Владелец: %s" % state.countries[p["owner"]]["name"])
		lines.append("Доход: %.1f в день" % p["income"])

	info_label.text = "\n".join(lines)
