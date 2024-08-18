extends Node
class_name LevelControl


@export var base_tile:TileMap
@export var entity_tile:TileMap
@export var inventory:Inventory
@export var step_timer:Timer
@export var tutorial_scene:TutorialScene

@export_category("level setting")
@export var level_name:String = "default level name"
@export var is_auto_run:bool = true
@export var step_duration:float = 0.9
@export_enum("right", "down", "left", "up") var init_direction_str = "right"
@export var init_energy = 0
@export var debug_game_data:DebugGameData
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
var editable_cells:Array[Vector2i]
var is_level_ready = false
var is_running_before_pickup = false
var manual_interval_passed = true
var is_pickdroping = false


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("level_control")
	tile_rect = base_tile.get_used_rect()
	# 获取可放置地块
	editable_cells = base_tile.get_used_cells_by_id(0,0,Vector2(1,0))
	
	step_timer.timeout.connect(_on_step_timer)
	step_timer.wait_time = step_duration
	
	AutoLoadEvent.signal_pickitem_cancel.connect(_on_signal_pickitem_cancel)
	AutoLoadEvent.signal_pickitem_drop.connect(_on_signal_pickitem_drop)
	AutoLoadEvent.signal_change_level_run_state.connect(_on_signal_change_level_run_state)
	AutoLoadEvent.signal_pickitem_pickup.connect(_on_signal_pickitem_pickup)
	if tutorial_scene:
		tutorial_scene.signal_tutorial_dimiss.connect(func():_on_signal_change_level_run_state(is_running_before_pickup))
	init_level()
	call_deferred('_on_load')
	
	# 计算 tile 居中位置
	print(%TileContainer.global_position)
	%TileContainer.global_position = Vector2i(1920,1080) / 2 - tile_rect.size * base_tile.tile_set.tile_size / 2
	# TODO check space
	%TileContainer.global_position.y = clamp(%TileContainer.global_position.y,210,1080)
	%TileContainer.global_position -= Vector2(0,96)
	
	
	# wait for enter level anim
	await get_tree().create_timer(2.0).timeout
	
	# if is_auto_run:
	# 从关卡设定改为用户操作记录
	if GameLevelLog.get_player_autorun_enable():
		step_timer.start()
	
	if tutorial_scene:
		if tutorial_scene.display():
			is_running_before_pickup = is_running()
			_on_signal_change_level_run_state(false)
		
	AutoLoadEvent.signal_level_run_state_changed.emit(is_running())
		
	is_level_ready = true
	AutoLoadEvent.signal_step_update.emit(0)

func _on_load():
	# 单独加载关卡场景，测试用
	if get_tree().get_first_node_in_group('game_ui') == null:
		AutoLoadEvent.signal_level_fail.connect(func(): 
			await get_tree().process_frame
			get_tree().reload_current_scene())
		AutoLoadEvent.signal_level_won.connect(func(): 
			await get_tree().process_frame
			get_tree().reload_current_scene())
		AutoLoadEvent.signal_level_reset.connect(func(): 
			await get_tree().process_frame
			get_tree().reload_current_scene())
			
		if debug_game_data:
			charactor.attack_compoent.init_data(debug_game_data.debug_charactor_strength)
			charactor.health_component.init_data(debug_game_data.debug_charactor_maxhp)
			charactor.resource_component.init_data(init_energy, debug_game_data.debug_player_energy_capacity)
			if debug_game_data.inven_data:
				inventory.init_debug_data(debug_game_data.inven_data)
			else:
				inventory.init_debug_data(GameLevelLog.INIT_INVENTORY_DATA.duplicate())
			return
	
	# 正常加载关卡
	charactor.attack_compoent.init_data(GameLevelLog.get_charactor_strength())
	charactor.health_component.init_data(GameLevelLog.get_charactor_maxhp())
	charactor.resource_component.init_data(init_energy, GameLevelLog.get_player_energy_capacity())
	inventory.init_data(GameLevelLog.get_inventory_data())

func _on_save():
	GameLevelLog.set_charactor_maxhp(charactor.health_component.max_hp)
	GameLevelLog.set_charactor_strength(charactor.attack_compoent.base_attack)
	GameLevelLog.set_player_energy_capacity(charactor.resource_component.max_count)
	
	if inventory:
		GameLevelLog.set_inventory_data(inventory.inven_data)
 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event):
	if is_level_ready and not tutorial_scene.visible:
		if Input.is_action_just_pressed("switch_run_mode"):
			switch_running_state()
		
		if Input.is_action_just_pressed("quick_reset"):
			AutoLoadEvent.signal_level_reset.emit()

func _physics_process(delta):
	if is_level_ready and not tutorial_scene.visible and not is_pickdroping and Input.is_action_pressed("take_step"):
		#print('action press take_step', manual_interval_passed, is_running())
		if manual_interval_passed and not is_running():
			manual_interval_passed = false
			get_tree().create_timer(step_duration).timeout.connect(func():manual_interval_passed=true)
			take_step()
			print('take_step')

#region gamestate
func is_running():
	return not step_timer.is_stopped()
	
	
func switch_running_state():
	if not is_instance_valid(get_tree()):
		return
		
	if is_running():
		step_timer.stop()
		GameLevelLog.set_player_autorun_enable(false)
	else:
		step_timer.start()
		GameLevelLog.set_player_autorun_enable(true)
		
	await get_tree().process_frame
	AutoLoadEvent.signal_level_run_state_changed.emit(is_running())
	

func _on_step_timer():
	if is_level_ready:
		take_step()
	
func _on_signal_change_level_run_state(is_run:bool):
	if not is_instance_valid(get_tree()):
		return
	if is_run:
		step_timer.start()
		await get_tree().process_frame
		AutoLoadEvent.signal_level_run_state_changed.emit(is_running())
	else:
		step_timer.stop()
		await get_tree().process_frame
		AutoLoadEvent.signal_level_run_state_changed.emit(is_running())

#endregion

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
				if cell_id in chest_contains_dict:
					(cell_scene as FuncChestItem).set_contained(chest_contains_dict[cell_id])
				else:
					push_error("unfound chest data for %v" % cell_id)
			
			if item_res.entity_type == Constants.ENTITY_TYPE.EXIT:
				(cell_scene as Entity).start_highlight(0.75*4)
				
				
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
		
		# init charactor
		#charactor.hide()
		charactor.play_level_enter_anim()

		
	print('move direction')
	print(Vector2(charactor.cell_id).direction_to(Vector2(cell_id)))
	print(charactor.get_direction())
	print(Vector2(charactor.cell_id).direction_to(Vector2(cell_id)).angle_to(charactor.get_direction()))
	var is_cross_edge = absf(Vector2(charactor.cell_id).direction_to(Vector2(cell_id)).angle_to(charactor.get_direction())) > PI/4
	
	if is_cross_edge:
		await charactor.move_to_pos_through_edge(entity_tile.map_to_local(cell_id), need_anim)
	else:
		await charactor.move_to_pos(entity_tile.map_to_local(cell_id), need_anim)
	charactor.cell_id = cell_id
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
		push_warning("try set in not null in cell_data at ", cell_id)
		cell_data[cell_id.x][cell_id.y].queue_free()
	
	cell_data[cell_id.x][cell_id.y] = cell_scene
	cell_scene.cell_id = cell_id
	return cell_scene
	

func switch_entity_instance(entity1:Entity, entity2:Entity):
	print('switch_entity_instance')
	
	var cell_id1 = entity1.cell_id
	var cell_id2 = entity2.cell_id
	
	var pos1 = entity1.position
	var pos2 = entity2.position
	
	entity1.move_to_pos(pos2, true)
	entity2.move_to_pos(pos1, true)
	
	entity1.cell_id = cell_id2
	entity2.cell_id = cell_id1
	
	cell_data[cell_id1.x][cell_id1.y] = entity2
	cell_data[cell_id2.x][cell_id2.y] = entity1
	

func entity_mov_to_cell(entity1:Entity, tar_cell_id:Vector2i):
	var tar_pos = entity_tile.map_to_local(tar_cell_id)
	var cell_id1 = entity1.cell_id
	
	entity1.move_to_pos(tar_pos, true)
	entity1.cell_id = tar_cell_id
	cell_data[tar_cell_id.x][tar_cell_id.y] = entity1
	cell_data[cell_id1.x][cell_id1.y] = null


func take_step():
	print()
	print()
	print("take_step=>> ", running_step)
	print("is_running=>> ", is_running())
	var char_direction = charactor.get_direction()
	entity_container.move_child(charactor, -1)
	if char_direction:
		var tar_cell_id = get_next_cell_id(charactor.cell_id, char_direction)
		var tar_cell = cell_data[tar_cell_id.x][tar_cell_id.y]
		var check_pass = charactor.pre_move_execute(tar_cell)
		if check_pass:
			await place_charactor_instance(null, tar_cell_id, true)
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
	if entity is FuncChestItem:
		if (entity as FuncChestItem).revive_step_gap == -1:
			cell_data[entity.cell_id.x][entity.cell_id.y] = null
	else:
		cell_data[entity.cell_id.x][entity.cell_id.y] = null
	

func _on_signal_entity_recycled(entity:Entity):
	print('_on_signal_entity_recycled')
	print(entity, entity.cell_id)
	entity.on_recycled()
	cell_data[entity.cell_id.x][entity.cell_id.y] = null


func _on_signal_chest_pickup(entity:FuncChestItem):
	print('_on_signal_chest_pickup')
	print(entity, entity.cell_id)
	var picked = inventory.add_pickup(entity.contain_type, entity.contain_count)
	if picked:
		SfxManager.play_open_chest()
		entity.signal_entity_used.emit(entity)
	

















#region useitem

func _on_signal_pickitem_pickup(type:Constants.ENTITY_TYPE, is_switch_second:bool):
	if not is_switch_second:
		is_running_before_pickup = is_running()
	is_pickdroping = true
	_on_signal_change_level_run_state(false)
	var indicate_cells = []
	var cost = (ResourceLoader.load(Constants.EntityMap[type]) as ItemRes).energy_cost
	var valid_flag = 1
	if charactor.resource_component.has_enough(cost):
		valid_flag = 1
	else:
		valid_flag = 3

	match type:
		Constants.ENTITY_TYPE.SWITCHER:
			if not is_switch_second:
				for i in editable_cells:
					if cell_data[i.x][i.y] != null and i != charactor.cell_id:
						indicate_cells.append(i)
			else:
				for i in editable_cells:
					if i != charactor.cell_id:
						indicate_cells.append(i)
				
			
		Constants.ENTITY_TYPE.RECYCLER:
			for i in editable_cells:
				if cell_data[i.x][i.y] != null and i != charactor.cell_id:
					indicate_cells.append(i)
		_:
			for i in editable_cells:
				if i != charactor.cell_id:
					indicate_cells.append(i)
	
	AutoLoadEvent.signal_gird_indicaotr_show.emit(indicate_cells, valid_flag)
	
	
func _on_signal_pickitem_cancel(trans_data):
	is_pickdroping = false
	_on_signal_change_level_run_state(is_running_before_pickup)


func _on_signal_pickitem_drop(trans_data):
	var item_res = trans_data['item_res'] as ItemRes
	var is_done = false
	match item_res.entity_type:
		Constants.ENTITY_TYPE.RECYCLER:
			is_done = drop_recycler_item(item_res, trans_data)
		Constants.ENTITY_TYPE.SWITCHER:
			is_done = drop_switcher_item(item_res, trans_data)
		_:
			is_done = drop_general_item(item_res, trans_data)
	
	if is_done:
		is_pickdroping = false
		_on_signal_change_level_run_state(is_running_before_pickup)


func check_basic_valid_drop(item_res, release_cell_id):
	# 检查是否是可用的位置
	# 0是否在有能量
	# 1是否在格子范围
	# 2是否可放置
	# 3是否有其它entity
	if not charactor.resource_component.has_enough(item_res.energy_cost):
		print('drop_failed as no energy')
		AutoLoadEvent.signal_energy_ui_notify.emit()
		return false
		
	if not tile_rect.has_point(release_cell_id):
		print('drop_failed as not in tile_rect')
		return false
	
	var editable = TileUtils.get_custom_data(base_tile, 0, release_cell_id, "editable", false)
	if not editable:
		print('drop_failed as not if not editable:')
		return false

	return true


func drop_general_item(item_res, trans_data)->bool:
	var origin_slot_idx = trans_data['origin_slot_idx'] 
	var release_global_postion = trans_data['release_global_postion']
	var item_preview = trans_data['item_preview']
	
	var release_cell_id = entity_tile.local_to_map(entity_container.to_local(release_global_postion))
	print('_on_signal_pickitem_drop ', release_cell_id)
	if check_basic_valid_drop(item_res, release_cell_id):
		# 检查普通放置，是否重叠
		var on_cell_entity = cell_data[release_cell_id.x][release_cell_id.y] as Entity
		if charactor.cell_id == release_cell_id:
			print('drop_failed as cell ocuppied')
			return false
	else:
		return false
	
	SfxManager.play_open_chest()
	AutoLoadEvent.signal_pickitem_drop_update_inventory.emit(origin_slot_idx)
	charactor.resource_component.consume_resource(item_res.energy_cost)
	
	# 处理放置
	# 通知 Inventory 更新数据
	var cell_scene = place_entity_instance(item_res.block_scene, release_cell_id)
	if item_res.entity_type == Constants.ENTITY_TYPE.TRAIL:
		cell_scene.set_direction_by_rad(trans_data.get('rotation', 0))
	return true


func drop_recycler_item(item_res, trans_data)->bool:
	var origin_slot_idx = trans_data['origin_slot_idx'] 
	var release_global_postion = trans_data['release_global_postion']
	var item_preview = trans_data['item_preview']
	
	var release_cell_id = entity_tile.local_to_map(entity_container.to_local(release_global_postion))
	var on_cell_entity = cell_data[release_cell_id.x][release_cell_id.y] as Entity
	print('_on_signal_pickitem_drop ', release_cell_id)
	if check_basic_valid_drop(item_res, release_cell_id):
		# 检查回收放置，是否存在物品
		if on_cell_entity == null or charactor.cell_id == release_cell_id:
			print('drop_recycler_failed as no on_cell_entity')
			return false
	else:
		return false
		
	SfxManager.play_open_chest()
	AutoLoadEvent.signal_pickitem_drop_update_inventory.emit(origin_slot_idx)
	
	var on_cell_energy = (ResourceLoader.load(Constants.EntityMap[on_cell_entity.type]) as ItemRes).energy_cost
	charactor.resource_component.consume_resource(item_res.energy_cost)
	charactor.resource_component.add_resource(on_cell_energy)
	_on_signal_entity_recycled(on_cell_entity)
	inventory.add_pickup(on_cell_entity.type)
	return true


func drop_switcher_item(item_res, trans_data)->bool:
	var origin_slot_idx = trans_data['origin_slot_idx'] 
	var release_global_postion = trans_data['release_global_postion']
	var click_count = trans_data['click_count']
	var previrew_node = trans_data['item_preview'] as ItemSwitchPreview
	
	if click_count == 1:
		var release_cell_id = entity_tile.local_to_map(entity_container.to_local(release_global_postion))
		print('_on_signal_pickitem_drop ', release_cell_id)
		if check_basic_valid_drop(item_res, release_cell_id):
			# 检查回收放置，是否存在物品
			var on_cell_entity = cell_data[release_cell_id.x][release_cell_id.y] as Entity
			if on_cell_entity == null or charactor.cell_id == release_cell_id:
				print('drop_switch_failed as no on_cell_entity')
				return false
		else:
			return false
		previrew_node.stat_point_accept(release_global_postion)
		return false
			
	elif click_count == 2:
		var switch_start_global_postion = trans_data['switch_start_global_postion']
		var switch_end_global_postion = trans_data['switch_end_global_postion']
		
		var cell_idx1 = entity_tile.local_to_map(entity_tile.to_local(switch_start_global_postion))
		var on_cell_entity1 = cell_data[cell_idx1.x][cell_idx1.y] as Entity
		
		var cell_idx2 = entity_tile.local_to_map(entity_tile.to_local(switch_end_global_postion))
		var on_cell_entity2 = null
		if check_basic_valid_drop(item_res, cell_idx2):
			# 检查交换终点放置，是否存在物品
			on_cell_entity2 = cell_data[cell_idx2.x][cell_idx2.y] as Entity
			
			if cell_idx2 not in editable_cells:
				print('drop_switch_failed as not in editable_cells')
				return false
			
			if charactor.cell_id == cell_idx2 or cell_idx1 == cell_idx2:
				print('drop_switch_failed as no on_cell_entity')
				return false
			
		else:
			return false
		
		SfxManager.play_open_chest()
		AutoLoadEvent.signal_pickitem_drop_update_inventory.emit(origin_slot_idx)
		charactor.resource_component.consume_resource(item_res.energy_cost)
		
		if on_cell_entity2 == null:
			entity_mov_to_cell(on_cell_entity1, cell_idx2)
		else:
			switch_entity_instance(on_cell_entity1, on_cell_entity2)
		
		return true
	else:
		push_error('invalid click_count param')
		return false

#endregion


func _on_tutorial_button_pressed():
	if tutorial_scene:
		if tutorial_scene.display(true):
			is_running_before_pickup = is_running()
			_on_signal_change_level_run_state(false)
