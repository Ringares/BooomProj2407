class_name GameLevelLog
extends GameLog
## Extends [GameLog] to log current and max level reached through [Config]. 

const MAX_LEVEL_REACHED = "MaxLevelReached"
const CURRENT_LEVEL = "CurrentLevel"

static func level_reached(level_number : int) -> void:
	var max_level_reached = Config.get_config(GAME_LOG_SECTION, MAX_LEVEL_REACHED, 0)
	max_level_reached = max(level_number, max_level_reached)
	Config.set_config(GAME_LOG_SECTION, CURRENT_LEVEL, level_number)
	Config.set_config(GAME_LOG_SECTION, MAX_LEVEL_REACHED, max_level_reached)

static func get_max_level_reached() -> int:
	return Config.get_config(GAME_LOG_SECTION, MAX_LEVEL_REACHED, 0)

static func get_current_level() -> int:
	return Config.get_config(GAME_LOG_SECTION, CURRENT_LEVEL, 0)

static func set_current_level(level_number : int) -> void:
	Config.set_config(GAME_LOG_SECTION, CURRENT_LEVEL, level_number)

static func reset_game_data() -> void:
	Config.set_config(GAME_LOG_SECTION, CURRENT_LEVEL, 0)
	Config.set_config(GAME_LOG_SECTION, MAX_LEVEL_REACHED, 0)
	
	#
	Config.set_config(GAME_LOG_SECTION, CHARACTOR_MAXHP, INIT_CHARACTOR_MAXHP)
	Config.set_config(GAME_LOG_SECTION, CHARACTOR_STRENGTH, INIT_CHARACTOR_STRENGTH)
	Config.set_config(GAME_LOG_SECTION, PLAYER_ENERGY_CAPACITY, INIT_PLAYER_ENERGY_CAPACITY)
	
	#
	Config.set_config(GAME_LOG_SECTION, INVENTORY_DATA, INIT_INVENTORY_DATA.duplicate())
	
	#
	Config.set_config(GAME_LOG_SECTION, TUTORIAL_FINISHED, 0)
	



### ingame data
const INIT_CHARACTOR_MAXHP = 5
const INIT_CHARACTOR_STRENGTH = 1
const INIT_PLAYER_ENERGY_CAPACITY = 6

const CHARACTOR_MAXHP = "CharactorMAXHP"
const CHARACTOR_STRENGTH = "CharactorSTR"
const PLAYER_ENERGY_CAPACITY = "PlayerEnergyCapacity"

const INIT_INVENTORY_DATA = [null,null,null,null,null]
const INVENTORY_DATA = "InventoryData"


static func set_charactor_maxhp(data):
	Config.set_config(GAME_LOG_SECTION, CHARACTOR_MAXHP, data)

static func get_charactor_maxhp() -> int:
	return Config.get_config(GAME_LOG_SECTION, CHARACTOR_MAXHP, INIT_CHARACTOR_MAXHP)

static func set_charactor_strength(data):
	Config.set_config(GAME_LOG_SECTION, CHARACTOR_STRENGTH, data)

static func get_charactor_strength() -> int:
	return Config.get_config(GAME_LOG_SECTION, CHARACTOR_STRENGTH, INIT_CHARACTOR_STRENGTH)

static func set_player_energy_capacity(data):
	Config.set_config(GAME_LOG_SECTION, PLAYER_ENERGY_CAPACITY, data)

static func get_player_energy_capacity() -> int:
	return Config.get_config(GAME_LOG_SECTION, PLAYER_ENERGY_CAPACITY, INIT_PLAYER_ENERGY_CAPACITY)


static func set_inventory_data(data:Variant):
	Config.set_config(GAME_LOG_SECTION, INVENTORY_DATA, data)
	
static func get_inventory_data():
	return Config.get_config(GAME_LOG_SECTION, INVENTORY_DATA, INIT_INVENTORY_DATA.duplicate())
	


### tutorial data
const TUTORIAL_FINISHED = "TutorialFinished"
static func set_finished_tutorial_id(data:Variant):
	Config.set_config(GAME_LOG_SECTION, TUTORIAL_FINISHED, data)

static func get_finished_tutorial_id():
	return Config.get_config(GAME_LOG_SECTION, TUTORIAL_FINISHED, 0)
