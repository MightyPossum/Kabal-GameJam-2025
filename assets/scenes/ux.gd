extends Control

@export var energy_label : Label
@export var wave_progress : TextureProgressBar 
@export var wave_label : Label
@export var EPS_label : Label
@export var Harvest_label : Label
@export var breach_label : Label

var previous_wave_number : int = -1
var current_wave_time : float = 0.0
var previous_locked_state : bool = false

enum BUTTONTYPE {
	UPGRADE = 0,
	PRESTIGE = 1,
	STATS = 2,

}

func _ready() -> void:

	GLOBAL.UX = self

	breach_label = %containmentBreachCounter
	
	# Initialize the locked state tracking
	previous_locked_state = GLOBAL.LOCKED

	%upgrades.connect("button_up",menu_button_pressed.bind(BUTTONTYPE.UPGRADE))
	%prestige.connect("button_up",menu_button_pressed.bind(BUTTONTYPE.PRESTIGE))
	%stats.connect("button_up",menu_button_pressed.bind(BUTTONTYPE.STATS))
	
	%close_upgrade_menu.connect("button_up",close_menu_pressed.bind(BUTTONTYPE.UPGRADE))
	# Add more close buttons as needed

	%purchase_button.connect("button_up", purchase_button_pressed)


func _process(delta: float) -> void:
	if GLOBAL.ENERGY:
		energy_label.text = GLOBAL.ENERGY_STRING
	else:
		energy_label.text = "0"
		
	if GLOBAL.ENERGY_PER_SECOND:
		EPS_label.text = "%s Energy Per Second" % [GLOBAL.ENERGY_PER_SECOND.toAA()]
	else:
		EPS_label.text = "0 Energy Per Second"
	
	if GLOBAL.ENERGY_PER_CELL:
		Harvest_label.text = "%s Energy Per Cell" % [GLOBAL.ENERGY_PER_CELL.toAA()]
	else:
		Harvest_label.text = "0 Energy Per Cell"

	# Check if wave number has changed (new wave started)
	if GLOBAL.WAVE_NUMBER != previous_wave_number:
		previous_wave_number = GLOBAL.WAVE_NUMBER
		current_wave_time = GLOBAL.WAVE_TIME
		wave_progress.max_value = GLOBAL.WAVE_TIME
		wave_progress.value = GLOBAL.WAVE_TIME

	# Check if GLOBAL.LOCKED has changed from true to false (containment breach)
	if previous_locked_state == true and GLOBAL.LOCKED == false:
		GLOBAL.BREACH_COUNT += 1
		print("Containment breached! Total breaches: ", GLOBAL.BREACH_COUNT)
	
	# Update previous locked state
	previous_locked_state = GLOBAL.LOCKED

	current_wave_time -= delta
	wave_progress.value = current_wave_time
	wave_label.text = "Next containment box in %d seconds" % current_wave_time
	breach_label.text = "Containment Breached %d Times" % GLOBAL.BREACH_COUNT

func menu_button_pressed(button_type: int) -> void:

	%basemenu.hide()

	match button_type:
		BUTTONTYPE.UPGRADE:
			print_upgrade_icons()
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

func purchase_button_pressed() -> void:
	var stat : Stat
	if not has_meta("selected_stat"):
		print("No stat selected for purchase")
		return
	else:
		stat = get_meta("selected_stat")

	if GLOBAL.ENERGY.isGreaterThanOrEqualTo(stat.cost):
		GLOBAL.ENERGY = GLOBAL.ENERGY.minus(stat.cost)
		stat.upgrade_level()
		print("Purchased stat: %s, new level: %d" % [GLOBAL.STAT_TYPE_NAMES[stat.type], stat.level])
		print_upgrade_icons() # Refresh the icons after purchase
		set_upgrade_description(stat)
	else:
		print("Not enough energy to purchase stat: %s, cost: %s" % [GLOBAL.STAT_TYPE_NAMES[stat.type], stat.cost.toAA()])



func print_upgrade_icons() -> void:
	print("Total Clicks: %s" % [GLOBAL.get_total_clicks().toAA()])
	for child in %IconContainer.get_children():
		child.queue_free() # Clear previous icons
	for stat_type in GLOBAL.STATS.stats:
		for stat_tier in GLOBAL.STATS.stats[stat_type]:
			var stat = GLOBAL.STATS.stats[stat_type][stat_tier]

			if stat.is_unlocked and not stat.is_maxed_out():
				var icon : Control = load("uid://v8ap3ght2h0m").instantiate()
				icon.image_string = "res://assets/art/ux/upgrade_icons/%s_%s.png" % [GLOBAL.STAT_TYPE_NAMES[stat.type], stat.tier] 
				icon.stat = stat
				if stat.cost.isGreaterThan(GLOBAL.ENERGY):
					icon.modulate = Color(0.2, 0.2, 0.2, 1) # Red if not affordable

				icon.ux = self
				%IconContainer.add_child(icon)

func set_upgrade_description(stat: Stat) -> void:
	var desctiption : String = "%s (%s) - %s \n%s \n\n%s" % [GLOBAL.to_init_cap(GLOBAL.STAT_TYPE_NAMES[stat.type]), GLOBAL.to_init_cap(GLOBAL.STAT_TIER_NAMES[stat.tier]), stat.level, stat.cost.toAA(), get_stat_description(stat)]
	%description_label.text = desctiption

func get_stat_description(stat : Stat) -> String:
	var description : String

	match stat.type:
		GLOBAL.STAT_TYPE.ENERGY_CONVERTER:
			description = "Increases the energy you automatically generate from your surroundings by %s Energy Per Second (EPS)" % [stat.value_increase_per_level]
		GLOBAL.STAT_TYPE.ENERGY_COLLECTOR:
			description = "Increases the energy you harvest from Energy Cells by %s (EPC)" % [stat.value_increase_per_level]
		GLOBAL.STAT_TYPE.ENERGY_VAULT:
			description = "Increase energy  from all sources by %s" % [stat.value_increase_per_level]
		GLOBAL.STAT_TYPE.POWER_CELL:
			description = "Increase the damage delt by your main cannon by %s" % [stat.value_increase_per_level]
		GLOBAL.STAT_TYPE.TESSERACT_ENERGY_MATRIX:
			if stat.level == 0:
				description = "Multiply the number of Energy Per Second by %s." % [stat.base_value]
			else:
				description = "Increase Energy Per Second multiplication by %s." % [stat.value_increase_per_level]
		GLOBAL.STAT_TYPE.ECHO_OF_THE_COLLAPSING_CORE:
			if stat.level == 0:
				description = "Multiply the number of Energy Per Second by %s." % [stat.base_value]
			else:
				description = "Increase Energy Per Second multiplication by %s." % [stat.value_increase_per_level]
		GLOBAL.STAT_TYPE.FRAGMENT_OF_THE_FIRST_SPARK:
			if stat.level == 0:
				description = "Multiply the number of Energy Per Second by %s." % [stat.base_value]
			else:
				description = "Increase Energy Per Second multiplication by %s." % [stat.value_increase_per_level]
		GLOBAL.STAT_TYPE.OMNICORE_COLLECTION_ENGINE:
			if stat.level == 0:
				description = "Multiply the number of Energy you harvest by clicking by %s." % [stat.base_value]
			else:
				description = "Increase Energy you harvest by clicking by %s." % [stat.value_increase_per_level]
		GLOBAL.STAT_TYPE.SINGULARITY_INTAKE:
			if stat.level == 0:
				description = "Multiply the number of Energy you harvest by clicking by %s." % [stat.base_value]
			else:
				description = "Increase Energy you harvest by clicking by %s." % [stat.value_increase_per_level]
		GLOBAL.STAT_TYPE.PULSE_OF_THE_UNIVERSE:
			if stat.level == 0:
				description = "Multiply the number of Energy you harvest by clicking by %s." % [stat.base_value]
			else:
				description = "Increase Energy you harvest by clicking by %s." % [stat.value_increase_per_level]
		GLOBAL.STAT_TYPE.ENERGY_AMPLIFIER:
			description = "Increase energy per second by %s%%" % [stat.value_increase_per_level]
		GLOBAL.STAT_TYPE.ENERGY_CORE:
			description = "Increase energy per second by %s%%" % [stat.value_increase_per_level]
		GLOBAL.STAT_TYPE.HOLLOW_DRIVE:
			description = "Increase energy per second by %s%%" % [stat.value_increase_per_level]
		GLOBAL.STAT_TYPE.HARVESTER:
			if stat.level == 0:
				description = "Whenever the mech is not locked by boxes it will automatically absorb energy cells at a rate of %s per second" % [stat.base_value]
			else:
				description = "Increase the automatic energy cell absorption rate by %s%% per second." % [stat.value_increase_per_level/100]
		GLOBAL.STAT_TYPE.ENERGY_AUTO_CANNON:
			description = "Automatically shoots at a rate of 1 shot per second"
		GLOBAL.STAT_TYPE.PULSE_OVERDRIVE:
			description = "Increase the damage delt by your main cannon by %s%%" % [stat.value_increase_per_level]
		GLOBAL.STAT_TYPE.RIFT_AMPLIFIER:
			if stat.level == 0:
				description = "Multiply the damage dealt by your main cannon by %s" % [stat.base_value]
			else:
				description = "Increase the damage dealt by your main cannon by %s." % [stat.value_increase_per_level]

		GLOBAL.STAT_TYPE.ENERGY_CANNON_BLAST_SPLITTER:
			description = "Projectile increase by %s"	 % [stat.value_increase_per_level]
		GLOBAL.STAT_TYPE.VELOCITY_AMPLIFIER:
			description = "Attack speed increase by %s%%" % stat.value_increase_per_level

	
	return description
