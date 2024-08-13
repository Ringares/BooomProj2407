extends Node
class_name LevelControl


@export var base_tile:TileMap
@export var entity_tile:TileMap
@export var inventory:Inventory
@export var step_timer:Timer

@export_category("level setting")
@export var level_name:String = "default level name"
@export var is_auto_run:bool = false
@export var step_duration:float = 0.3
@export_enum("right", "down", "left", "up") var init_direction_str = "right"
@export var init_energy = 0
@export var chest_contains:Array[ChestData]:
	set(value):
		chest_contains = value
		chest_contains_dict = {}
		for i in chest_contains:
			chest_contains_dict[i.cell_idx] = i
		
var chest_contains_dict = {}

const dir_map = {
	"right":Vector2.RIGHT,
	"down":Vector2.DOWN,
	"left":Vector2.LEFT,
	"up":Vector2.UP,
}

@onready var entity_container = %EntityContainer

var charactor:Charactor

var running_step:int = 0
var tile_rect:Rect2i
var cell_data = []


# Called when the node enters the scene tree for the first time.
func _ready():
	tile_rect = base_tile.get_used_rect()
	step_timer.timeout.connect(_on_step_timer)
	
	AutoLoadEvent.signal_pickitem_drop.connect(_on_signal_pickitem_drop)
	init_level()
	call_deferred('_on_load')
	
	# 计算 tile 居中位置
	print(%TileContainer.global_position)
	print(tile_rect.size * 128)
	print(get_viewport().size)
	var viewport_size = get_viewport().size as Vector2i
	print(viewport_size / 2 ,tile_rect.size * 128 / 2)
	%TileContainer.global_position = viewport_size / 2 - tile_rect.size * 128 / 2
	# TODO check space
	%TileContainer.global_position -= Vector2(0,(1080 - tile_rect.size.x * 128)/2 - 128)
	
	await get_tree().create_timer(1).timeout
	if is_auto_run:
		step_timer.start()
	AutoLoadEvent.signal_step_update.emit(0)

func _on_load():
	charactor.attack_compoent.init_data(GameLevelLog.get_charactor_strength())
	charactor.health_component.init_data(GameLevelLog.get_charactor_maxhp())
	charactor.resource_component.init_data(init_energy, GameLevelLog.get_player_energy_capacity())

	
	if inventory:
		inventory.init_data(GameLevelLog.get_inventory_data())

func _on_save():
	GameLevelLog.set_charactor_maxhp(charactor.health_component.max_hp)
	GameLevelLog.set_charactor_strength(charactor.attack_compoent.base_attack)
	GameLevelLog.set_player_energy_capacity(charactor.resource_component.max_count)
	
	if inventory:
		GameLevelLog.set_inventory_data(inventory.inven_data)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		switch_running_state()
			
	if Input.is_action_just_pressed("run_step"):
		step_timer.stop()
		take_step()


func _on_step_timer():
	take_step()

func is_running():
	print("is_running", not step_timer.is_stopped())
	return not step_timer.is_stopped()
	
func switch_running_state():
	if step_timer.is_stopped():
			step_timer.start()
	else:
		step_timer.stop()
	AutoLoadEvent.signal_level_timer_stopped.emit(step_timer.is_stopped())
	


func init_level():
	# 用 tile map 来编辑关卡
	# 初始化时添加实际场景 node
	# fill cell_data
	
	for i in range(tile_rect.size.x):
		var l = []
		for j in range(tile_rect.size.y):
			l.append(null)
		cell_data.append(l)
	
	for key in Constants.EntityMap:
		print(key)
		var res_path = Constants.EntityMap[key]
		if res_path == null:
			continue
		var item_res = ResourceLoader.load(res_path) as ItemRes
		var packed_scene = item_res.block_scene
		var atlas_coord = item_res.tile_cell
		
	#for mapping in entity_mapping:
		#var packed_scene = mapping[0]
		#var atlas_coord = mapping[1]
		
		for cell_id in entity_tile.get_used_cells_by_id(0, 0, atlas_coord):
			var cell_scene 
			#var cell_scene = packed_scene.instantiate() as Entity
			#entity_container.add_child(cell_scene)
			#cell_scene.position = entity_tile.map_to_local(cell_id)
			#update_cell_pos(cell_scene, cell_id)
			#cell_scene.signal_entity_used.connect(_on_signal_entity_used)
			
			if item_res.entity_type == Constants.ENTITY_TYPE.CHARACTOR:
				cell_scene = await place_charactor_instance(packed_scene, cell_id, false)
				charactor = cell_scene
			else:
				cell_scene = place_entity_instance(packed_scene, cell_id)
			
			if item_res.entity_type == Constants.ENTITY_TYPE.TRAIL:
				var alternate_id = entity_tile.get_cell_alternative_tile(0, cell_id)
				var is_flip_h = alternate_id&TileSetAtlasSource.TRANSFORM_FLIP_H > 0
				var is_flip_v = alternate_id&TileSetAtlasSource.TRANSFORM_FLIP_V > 0
				var is_transpose = alternate_id&TileSetAtlasSource.TRANSFORM_TRANSPOSE > 0
				
				var direction_info = TileUtils.get_rotation(is_flip_h, is_flip_v, is_transpose)
				cell_scene.safe_set_direction_info(direction_info)
				
			if item_res.entity_type == Constants.ENTITY_TYPE.CHEST:
				cell_scene.signal_chest_pickup.connect(_on_signal_chest_pickup)
				#print(cell_id)
				#print(Vector2i(cell_id))
				#print(chest_contains_dict[cell_id])
				#print(cell_id in chest_contains_dict)
				if cell_id in chest_contains_dict:
					(cell_scene as FuncChestItem).set_contained(chest_contains_dict[cell_id])
				else:
					push_error("unfound chest data for %v" % cell_id)
					
				
				
			entity_tile.set_cell(0, cell_id)
	
	if charactor == null:
		push_error('charactor not in level')
	charactor.set_direction(dir_map[init_direction_str])
	pass
	

func place_charactor_instance(packed_scene:PackedScene, cell_id:Vector2i, need_anim=false):
	"""
	放置角色位置
	"""
	if charactor == null:
		charactor = packed_scene.instantiate() as Charactor
		entity_container.add_child(charactor)

	charactor.cell_id = cell_id
	await charactor.move_to_pos(entity_tile.map_to_local(cell_id), need_anim)
	AutoLoadEvent.signal_cell_arraived.emit(cell_id)
	
	return charactor


func place_entity_instance(packed_scene:PackedScene, cell_id:Vector2i):
	"""
	放置事件位置
	"""
	var cell_scene = packed_scene.instantiate() as Entity
	entity_container.add_child(cell_scene)
	
	cell_scene.signal_entity_used.connect(_on_signal_entity_used)
	cell_scene.position = entity_tile.map_to_local(cell_id)
	
	if cell_data[cell_id.x][cell_id.y] != null:
		push_error("try set in not null in cell_data at ", cell_id)
	else:
		cell_data[cell_id.x][cell_id.y] = cell_scene
		cell_scene.cell_id = cell_id
	return cell_scene


func take_step():
	print()
	print()
	print()
	print("take_step=>> ", running_step)
	print("is_auto_run=>> ", is_auto_run)
	print("is_running=>> ", is_running())
	var char_direction = charactor.get_direction()
	entity_container.move_child(charactor, -1)
	if char_direction:
		var tar_cell_id = get_next_cell_id(charactor.cell_id, char_direction)
		var tar_cell = cell_data[tar_cell_id.x][tar_cell_id.y]
		var check_pass = charactor.pre_move_execute(tar_cell)
		if check_pass:
			place_charactor_instance(null, tar_cell_id, true)
			charactor.post_move_execute(tar_cell)
	running_step += 1
	AutoLoadEvent.signal_step_update.emit(running_step)
	

func get_next_cell_id(origin_cell_id:Vector2i, direction:Vector2):
	var tar_idx = origin_cell_id + Vector2i(direction)
	if tar_idx.x < 0:
		tar_idx.x = tile_rect.size.x - 1
	elif tar_idx.x >= tile_rect.size.x:
		tar_idx.x = 0
		
	if tar_idx.y < 0:
		tar_idx.y = tile_rect.size.y - 1
	elif tar_idx.y >= tile_rect.size.y:
		tar_idx.y = 0
	return tar_idx 
	

func _on_signal_entity_used(entity:Entity):
	print('_on_signal_entity_used')
	print(entity, entity.cell_id)
	entity.on_used()
	cell_data[entity.cell_id.x][entity.cell_id.y] = null


func _on_signal_chest_pickup(entity:FuncChestItem):
	print('_on_signal_chest_pickup')
	print(entity, entity.cell_id)
	var picked = inventory.add_pickup(entity.contain_type, entity.contain_count)
	if picked:
		entity.signal_entity_used.emit(entity)
	
	
func _on_signal_pickitem_drop(trans_data):
	var item_res = trans_data['item_res'] as ItemRes
	var origin_slot_idx = trans_data['origin_slot_idx'] 
	var release_global_postion = trans_data['release_global_postion']
	var item_preview = trans_data['item_preview']
	
	# 检查是否是可用的位置
	# 1是否在格子范围
	# 2是否可放置
	# 3是否有其它entity
	
	var release_cell_id = entity_tile.local_to_map(entity_container.to_local(release_global_postion))
	print('_on_signal_pickitem_drop ', release_cell_id)
	if not tile_rect.has_point(release_cell_id):
		print('drop_failed as not in tile_rect')
		return
	
	var editable = TileUtils.get_custom_data(base_tile, 0, release_cell_id, "editable", false)
	if not editable:
		print('drop_failed as not 	if not editable:')
		return
	
	var on_cell_entity = cell_data[release_cell_id.x][release_cell_id.y]
	if on_cell_entity != null or charactor.cell_id == release_cell_id:
		print('drop_failed as cell ocuppied')
		return
		
	if charactor.resource_component.curr_count < item_res.energy_cost:
		print('drop_failed as no energy')
		return
	else:
		charactor.resource_component.consume_resource(item_res.energy_cost)
	
	# 处理放置
	# 通知 Inventory 更新数据
	var cell_scene = place_entity_instance(item_res.block_scene, release_cell_id)
	
	if item_res.entity_type == Constants.ENTITY_TYPE.TRAIL:
		cell_scene.set_direction_by_rad(trans_data.get('rotation', 0))
	AutoLoadEvent.signal_pickitem_drop_update_inventory.emit(origin_slot_idx)
	SfxManager.play_open_chest()
	

