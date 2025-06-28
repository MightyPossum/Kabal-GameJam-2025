class_name Stats

var stats : Dictionary = {}

func get_energy_increase_t1() -> int:
	return stats.get(GLOBAL.STAT_TYPE.ENERGY_VAULT).get(GLOBAL.STAT_TIER.CORE).level

func add_stat(stat):
	if not stats.has(stat.type):
		stats[stat.type] = {}

	stats[stat.type][stat.tier] = stat

func test_stat_unlock():
	for stat_type in stats:
		for tier in stats[stat_type]:
			var stat = stats[stat_type][tier]
			if not stat.is_unlocked:
				stat.check_unlock()
			if stat.is_unlocked:
				print("Stat unlocked: %s, Tier: %d" % [stat_type, tier])
				return
	print("No more stats to unlock")

	await GLOBAL.GAME_SCENE.get_tree().create_timer(1.0).timeout
	test_stat_unlock()
