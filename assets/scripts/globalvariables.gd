extends Node

enum STAT_TYPE {
	ENERGY_CONVERTER = 1,
	ENERGY_COLLECTOR = 2,
	ENERGY_VAULT = 3,
	POWER_CELL = 4,
	TESSARACT_ENERGY_MATRIX = 5,
	ECHO_OF_THE_COLLAPSING_CORE = 6,
	FRAGMENT_OF_THE_FIRST_SPARK = 7,
	OMNICORE_COLLECTION_ENGINE = 8,
	SINGULARITY_INTAKE = 9,
	PULSE_OF_THE_UNIVERSE = 10,
	ENERGY_AMPLIFIER = 11,
	ENERGY_CORE = 12,
	HOLLOW_DRIVE = 13,
	HARVESTER = 14,
	ENERGY_AUTO_CANNON = 15,
	PULSE_OVERDRIVE = 16,
	DARKFLOW_OVERDRIVE = 17,
	VOIDSTORM_OVERDRIVE = 18,
	RIFT_AMPLIFIER = 19,
	ENERGY_CANNON_BLAST_SPLITTER = 20,
	VELOCITY_AMPLIFIER = 21,
}

enum STAT_TIER {
	CORE = 1,
	SURGE = 2,
	ALPHA = 3,
	NEXUS = 4,
	STELLAR = 5,
	DARKRUNE = 6,
	SOLARITE = 7,
	DARKFLOW = 8,
	STARCORE = 9,
	BLIGHTSTEEL = 10,
}

enum UNLOCK_METRIC {
	ALWAYS_UNLOCKED = 0,
	TOTAL_TPS = 1,
	TOTAL_CLICKS = 2,
	TOTAL_LIFETIME_COINS_GATHERED = 3,
	ENERGY_INCREASE_T1 = 4,
	MANUAL_SHOTS = 5,
	CURRENT_DAMAGE_CANNON = 6,
}

enum VALUE_TYPE {
	NUMBER = 0,
	PERCENTAGE = 1,
}

enum VALUE_APPLIED_TO {
	ENERGY_PER_SECOND = 1,
	ENERGY_PER_CELL = 2,
	ENERGY_GLOBAL_INCREASE = 3,
	MECH_ABSORPTION = 4,
	CANNON_SHOOT_RATE = 5,
	PROJECTILE_AMOUNT = 6,
	ATTACK_SPEED = 7,
	MAIN_CANNON_DAMAGE = 8,
}

enum VALUE_APPLICATION_TYPE {
	BASE = 0,
	ADDITION = 1,
	MULTIPLICATION = 2,
}

var GAME_SCENE : Node = null
var MECH : Node2D = null

var ENERGY : int = 0
var STATS : Stats

var TOTAL_CLICKS : Big = Big.new(0)
var TOTAL_TPS : Big = Big.new(0)
var TOTAL_LIFETIME_COINS_GATHERED : Big = Big.new(0)
var MANUAL_SHOTS : Big = Big.new(0)
var CURRENT_DAMAGE_CANNON : Big = Big.new(1)

var WAVE_TIME : float = 10.0
var WAVE_NUMBER : int = 1

var ENERGY_PER_SECOND : Big = Big.new(0):
	get:
		return get_current_value(ENERGY_PER_SECOND_DICTIONARY)

var ENERGY_PER_SECOND_DICTIONARY : Dictionary = {
	VALUE_APPLICATION_TYPE.BASE: Big.new(0),
}

var ENERGY_PER_CELL : Big = Big.new(0):
	get:
		return get_current_value(ENERGY_PER_CELL_DICTIONARY)

var ENERGY_PER_CELL_DICTIONARY : Dictionary = {
	VALUE_APPLICATION_TYPE.BASE: Big.new(1),
}

var ENERGY_GLOBAL_INCREASE : Big = Big.new(0):
	get:
		return get_current_value(ENERGY_GLOBAL_INCREASE_DICTIONARY)

var ENERGY_GLOBAL_INCREASE_DICTIONARY : Dictionary = {
	VALUE_APPLICATION_TYPE.BASE: Big.new(1),
}

var MECH_ABSORPTION : Big = Big.new(0):
	get:
		return get_current_value(MECH_ABSORPTION_DICTIONARY)

var MECH_ABSORPTION_DICTIONARY : Dictionary = {
	VALUE_APPLICATION_TYPE.BASE: Big.new(0),
}

var CANNON_SHOOT_RATE : Big = Big.new(0):
	get:
		return get_current_value(CANNON_SHOOT_RATE_DICTIONARY)

var CANNON_SHOOT_RATE_DICTIONARY : Dictionary = {
	VALUE_APPLICATION_TYPE.BASE: Big.new(1),
}

var PROJECTILE_AMOUNT : Big = Big.new(1):
	get:
		return get_current_value(PROJECTILE_AMOUNT_DICTIONARY)

var PROJECTILE_AMOUNT_DICTIONARY : Dictionary = {
	VALUE_APPLICATION_TYPE.BASE: Big.new(1),
}

var ATTACK_SPEED : Big = Big.new(1):
	get:
		return get_current_value(ATTACK_SPEED_DICTIONARY)

var ATTACK_SPEED_DICTIONARY : Dictionary = {
	VALUE_APPLICATION_TYPE.BASE: Big.new(1),
}

func get_total_tps() -> Big:
	return TOTAL_TPS

func get_total_clicks() -> Big:
	return TOTAL_CLICKS

func get_total_lifetime_coins_gathered() -> Big:
	return TOTAL_LIFETIME_COINS_GATHERED

func get_energy_increase_t1() -> Big:
	return Big.new(STATS.get_energy_increase_t1())

func get_manual_shots() -> Big:
	return MANUAL_SHOTS
	
func get_current_damage_cannon() -> Big:
	return CURRENT_DAMAGE_CANNON


func get_current_value(value_dictionary : Dictionary) -> Big:
	var total_value : Big = Big.new(0)
	var addition_value : Big = Big.new(0)
	var multiplication_value : Big = Big.new(1)
	var percentage_value : Big = Big.new(0)
	for stat in value_dictionary:
		if stat == VALUE_APPLICATION_TYPE.BASE:
			total_value = total_value.plus(value_dictionary[stat])
		elif stat.value_application_type == VALUE_APPLICATION_TYPE.ADDITION:
			addition_value = addition_value.plus(stat.value)
		elif stat.value_application_type == VALUE_APPLICATION_TYPE.MULTIPLICATION:
			if stat.value_type == VALUE_TYPE.PERCENTAGE:
				multiplication_value = multiplication_value.plus(Big.new(1).plus(stat.value/100))
			else:
				multiplication_value = multiplication_value.plus(stat.value)

	return total_value.plus(addition_value).multiply(multiplication_value).multiply(Big.new(1).plus(percentage_value))