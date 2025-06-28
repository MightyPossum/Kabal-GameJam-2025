class_name Stat

var type : int
var tier : int
var base_value : float
var value : Big
var value_increase_per_level : float
var level : int
var max_level : int
var base_cost : Big
var cost_increase : float
var cost : Big
var unlock_metric : int
var unlock_amount : Big
var value_applied_to : int
var value_application_type : int
var value_type : int

var is_unlocked : bool = false

func _init(_type: int, _tier : int,  _base_value: float, _value_increase_per_level : float, _max_level : int, _base_cost: Big, _cost_increase: float, _unlock_metric: int, _unlock_amount: Big, _value_applied_to: int, _value_application_type: int, _value_type : int):
	type = _type
	tier = _tier
	base_value = _base_value
	value_increase_per_level = _value_increase_per_level
	max_level = _max_level
	base_cost = _base_cost
	cost_increase = _cost_increase
	unlock_metric = _unlock_metric
	unlock_amount = _unlock_amount
	value_applied_to = _value_applied_to
	value_application_type = _value_application_type
	value_type = _value_type

	level = 0
	value = Big.new(base_value)
	cost = Big.new(base_cost)

	check_unlock()

func check_unlock():
	if is_unlocked:
		return
	match unlock_metric:
		GLOBAL.UNLOCK_METRIC.ALWAYS_UNLOCKED:
			is_unlocked = true
		GLOBAL.UNLOCK_METRIC.TOTAL_TPS:
			if GLOBAL.get_total_tps().isGreaterThan(unlock_amount):
				is_unlocked = true
		GLOBAL.UNLOCK_METRIC.TOTAL_CLICKS:
			if GLOBAL.get_total_clicks().isGreaterThan(unlock_amount):
				is_unlocked = true
		GLOBAL.UNLOCK_METRIC.TOTAL_LIFETIME_COINS_GATHERED:
			if GLOBAL.get_total_lifetime_coins_gathered().isGreaterThan(unlock_amount):
				is_unlocked = true
		GLOBAL.UNLOCK_METRIC.ENERGY_INCREASE_T1:
			if GLOBAL.get_energy_increase_t1().isGreaterThan(unlock_amount):
				is_unlocked = true
		GLOBAL.UNLOCK_METRIC.MANUAL_SHOTS:
			if GLOBAL.get_manual_shots().isGreaterThan(unlock_amount):
				is_unlocked = true
		GLOBAL.UNLOCK_METRIC.CURRENT_DAMAGE_CANNON:
			if GLOBAL.get_current_damage_cannon().isGreaterThan(unlock_amount):
				is_unlocked = true

func upgrade_level():
	if level >= max_level:
		return
	level += 1

	# Recalculate value and cost based on the new level
	value = Big.times(base_value, Big.times(value_increase_per_level, level))
	cost = Big.times(base_cost, Big.times(1 * cost_increase/100, level))

	apply_bonus()

func apply_bonus():
	# Apply the bonus based on the value_applied_to and value_application_type
	match value_applied_to:
		GLOBAL.VALUE_APPLIED_TO.ENERGY_PER_SECOND:
			GLOBAL.ENERGY_PER_SECOND_DICTIONARY[self] = base_value*level
		GLOBAL.VALUE_APPLIED_TO.ENERGY_PER_CELL:
			GLOBAL.ENERGY_PER_CELL_DICTIONARY[self] = base_value*level
		GLOBAL.VALUE_APPLIED_TO.ENERGY_GLOBAL_INCREASE:
			GLOBAL.ENERGY_GLOBAL_INCREASE_DICTIONARY[self] = base_value*level
		GLOBAL.VALUE_APPLIED_TO.MECH_ABSORPTION:
			GLOBAL.MECH_ABSORPTION_DICTIONARY[self] = base_value*level
		GLOBAL.VALUE_APPLIED_TO.CANNON_SHOOT_RATE:
			GLOBAL.CANNON_SHOOT_RATE_DICTIONARY[self] = base_value*level
		GLOBAL.VALUE_APPLIED_TO.PROJECTILE_AMOUNT:
			GLOBAL.PROJECTILE_AMOUNT_DICTIONARY[self] = base_value*level
		GLOBAL.VALUE_APPLIED_TO.ATTACK_SPEED:
			GLOBAL.ATTACK_SPEED_DICTIONARY[self] = base_value*level
		
