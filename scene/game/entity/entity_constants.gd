class_name Constants

enum ENTITY_TYPE {
	
	UNKNOW = -1,
	EMPTY = 0,
	CHARACTOR = 1,
	TRAIL = 2,
	HEALTH_TEMP_UP = 3,
	STRENGTH_TEMP_UP = 4,
	HEALTH_UP = 5,
	STRENGTH_UP = 6,
	EXIT = 7, # 出口
	RECYCLER = 8, # 回收事件，回收能量
	ENERGY_UP = 9,
	ENERGY_ROOM_UP = 10,
	INVENTORY_ROOM_UP = 11,
	CHEST = 12,
	SWITCHER = 13,
	
	ENERMY_A = 20,
	ENERMY_B = 21,
} 



static var EntityMap = {
	ENTITY_TYPE.UNKNOW: null,
	ENTITY_TYPE.EMPTY: null,
	ENTITY_TYPE.CHARACTOR: "res://scene/game/entity/charactor/charactor.tres",
	
	ENTITY_TYPE.TRAIL: "res://scene/game/entity/func_item/item_trail.tres",
	ENTITY_TYPE.HEALTH_TEMP_UP: "res://scene/game/entity/property_item/item_hp_temp.tres",
	ENTITY_TYPE.STRENGTH_TEMP_UP: "res://scene/game/entity/property_item/item_str_temp.tres",
	ENTITY_TYPE.HEALTH_UP: "res://scene/game/entity/property_item/item_hp_up.tres",
	ENTITY_TYPE.STRENGTH_UP: "res://scene/game/entity/property_item/item_str_up.tres",
	ENTITY_TYPE.EXIT: "res://scene/game/entity/func_item/item_exit.tres",
	ENTITY_TYPE.RECYCLER: "res://scene/game/entity/func_item/item_recycler.tres",
	ENTITY_TYPE.ENERGY_UP: "res://scene/game/entity/property_item/item_energy_up.tres",
	ENTITY_TYPE.ENERGY_ROOM_UP: "res://scene/game/entity/property_item/item_energy_capacity.tres",
	ENTITY_TYPE.INVENTORY_ROOM_UP: "res://scene/game/entity/property_item/item_inven_capacity.tres",
	ENTITY_TYPE.CHEST: "res://scene/game/entity/func_item/item_chest.tres",
	ENTITY_TYPE.SWITCHER: "res://scene/game/entity/func_item/item_switcher.tres",
	
	ENTITY_TYPE.ENERMY_A: "res://scene/game/entity/enermy/enermy_a.tres",
	ENTITY_TYPE.ENERMY_B: "res://scene/game/entity/enermy/enermy_b.tres",
}





