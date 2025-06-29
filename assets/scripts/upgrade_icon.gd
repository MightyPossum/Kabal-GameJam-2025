extends Control

var image_string : String
var image_url : String
var icon_texture : Texture2D
var stat : Stat

var ux : Control

func _ready() -> void:
	icon_texture = load(image_string)
	%TextureRect.texture = icon_texture
	%upgrade_icon.connect("button_up",icon_button_pressed)
	set_icon_details()

func icon_button_pressed() -> void:
	ux.set_upgrade_description(stat)
	ux.set_meta("selected_stat", stat)

func set_icon_details() -> void:
	if stat.cost.isGreaterThan(GLOBAL.ENERGY):
		modulate = Color(0.2, 0.2, 0.2, 1)
	else:
		modulate = Color(1, 1, 1, 1)

	await get_tree().create_timer(0.5).timeout
	set_icon_details()
