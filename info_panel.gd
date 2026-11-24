class_name InfoPanel
extends CanvasLayer

@onready var info_label: Label = $InfoLabel
@onready var date_label: Label = $DateLabel

var state: GameState
var clock: GameClock
var _selected := ""
var _selected_army := ""


func setup(game_state: GameState, game_clock: GameClock) -> void:
	state = game_state
	clock = game_clock
	state.changed.connect(refresh)
	clock.changed.connect(refresh)
	refresh()


func show_province(id: String) -> void:
	_selected = id
	refresh()


func show_army(id: String) -> void:
	_selected_army = id
	refresh()


func refresh() -> void:
	date_label.text = clock.date_text()

	var lines: PackedStringArray = []
	for id in state.countries:
		var c := state.get_country(id)
		var mark := "> " if id == state.player else "    "
		lines.append("%s%s: %.1f (+%.1f)" % [mark, c.name, c.treasury, state.country_income(id)])

	if _selected_army != "" and not state.armies.has(_selected_army):
		_selected_army = ""

	if _selected != "":
		var p := state.get_province(_selected)
		lines.append("")
		lines.append(p.name)
		lines.append("Владелец: %s" % state.get_country(p.owner_id).name)
		lines.append("Доход: %.1f в день" % p.income)

	if _selected_army != "":
		var a := state.get_army(_selected_army)
		lines.append("")
		lines.append("Армия: %s" % state.get_country(a.owner_id).name)
		lines.append("Численность: %d" % a.size)
		if a.is_moving():
			lines.append("Идёт в: %s (дней: %d)" % [state.get_province(a.target_id).name, a.days_left])
		else:
			lines.append("Стоит в: %s" % state.get_province(a.province_id).name)
			if a.owner_id == state.player:
				lines.append("ПКМ по соседней провинции: отправить")

	info_label.text = "\n".join(lines)
