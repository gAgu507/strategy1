extends Node2D

var state := GameState.new()

@onready var clock: GameClock = $GameClock
@onready var map: MapView = $MapView
@onready var ui: InfoPanel = $UI


func _ready() -> void:
	clock.day_passed.connect(state.tick_day)
	map.province_selected.connect(ui.show_province)
	map.army_selected.connect(ui.show_army)
	map.move_requested.connect(state.order_move)
	map.setup(state)
	ui.setup(state, clock)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				clock.toggle_pause()
			KEY_1:
				clock.set_speed(1)
			KEY_2:
				clock.set_speed(2)
			KEY_3:
				clock.set_speed(3)
