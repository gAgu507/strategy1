class_name Country
extends RefCounted

var id: String
var name: String
var color: Color
var treasury: float


func _init(p_id: String, p_name: String, p_color: Color, p_treasury := 100.0) -> void:
	id = p_id
	name = p_name
	color = p_color
	treasury = p_treasury