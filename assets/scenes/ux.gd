extends Control

enum BUTTONTYPE {
	UPGRADE = 0,
	PRESTIGE = 1,
	STATS = 2,

}

func _ready() -> void:
	%upgrades.connect("button_up",menu_button_pressed.bind(BUTTONTYPE.UPGRADE))
	%prestige.connect("button_up",menu_button_pressed.bind(BUTTONTYPE.PRESTIGE))
	%stats.connect("button_up",menu_button_pressed.bind(BUTTONTYPE.STATS))
	
	%close_upgrade_menu.connect("button_up",close_menu_pressed.bind(BUTTONTYPE.UPGRADE))
	# Add more close buttons as needed

	%purchase_button.connect("button_up", purchse_button_pressed)


func menu_button_pressed(button_type: int) -> void:

	%basemenu.hide()

	match button_type:
		BUTTONTYPE.UPGRADE:
			%upgrademenu.show()
		BUTTONTYPE.PRESTIGE:
			print("Prestige button pressed")
			%basemenu.show() # Just to show the base menu, you can replace this with the actual prestige menu if you have one
		BUTTONTYPE.STATS:
			print("Stats button pressed")
			%basemenu.show() # Just to show the base menu, you can replace this with the actual stats menu if you have one

func close_menu_pressed(button_type: int) -> void:

	%basemenu.show()

	match button_type:
		BUTTONTYPE.UPGRADE:
			%upgrademenu.hide()
		BUTTONTYPE.PRESTIGE:
			print("Prestige menu closed")
			# Handle prestige menu close logic here
		BUTTONTYPE.STATS:
			print("Stats menu closed")
			# Handle stats menu close logic here

func purchse_button_pressed() -> void:
	print("Purchase button pressed")
