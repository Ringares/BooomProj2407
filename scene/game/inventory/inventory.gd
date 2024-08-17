extends Control
class_name Inventory


@export var max_iven_capacity = 9
var inven_data = [null] # [IvenItem]
@onready var grid_container = %GridContainer
const ITEM_CONTAINER = preload("res://scene/game/inventory/item_container.tscn")
const ITEM_PREVIEW = preload("res://scene/game/inventory/item_preview.tscn")
const ROTATE_ITEM_PREVIEW = preload("res://scene/game/inventory/rotate_item_preview.tscn")
const ITEM_SWITCH_PREVIEW = preload("res://scene/game/inventory/item_switch_preview.tscn")
var hover_slot:ItemSlot = null
var curr_preview:ItemPreview = null
var is_stackable = false


func _ready():
	update_ui()
	AutoLoadEvent.signal_pickitem_cancel.connect(_on_signal_pickitem_cancel)
	AutoLoadEvent.signal_pickitem_drop_update_inventory.connect(_on_signal_pickitem_drop_update_inventory)
	AutoLoadEvent.signal_inventory_capacity_increase.connect(_on_signal_inventory_capacity_increase)

	
func _physics_process(delta):
	if Input.is_action_just_pressed("left_clk"):
		if hover_slot != null and not hover_slot.is_empty() and curr_preview == null:
			
			if hover_slot.iven_item.item_res.entity_type == Constants.ENTITY_TYPE.TRAIL:
				curr_preview = ROTATE_ITEM_PREVIEW.instantiate()
			elif hover_slot.iven_item.item_res.entity_type == Constants.ENTITY_TYPE.SWITCHER:
				curr_preview = ITEM_SWITCH_PREVIEW.instantiate()
			else:
				curr_preview = ITEM_PREVIEW.instantiate()
			
			curr_preview.set_data(hover_slot.iven_item, hover_slot.idx)
			get_tree().get_first_node_in_group('group_inventory').add_child(curr_preview)
			AutoLoadEvent.signal_pickitem_pickup.emit(hover_slot.iven_item.item_res.entity_type, false)
			return
		
		if hover_slot != null and curr_preview != null:
			var origin_idx = curr_preview.origin_slot_idx
			var tar_idx = hover_slot.idx
			
			inven_data[origin_idx] = hover_slot.iven_item
			inven_data[tar_idx] = curr_preview.inven_item
			
			curr_preview.queue_free()
			curr_preview = null
			update_ui()
			AutoLoadEvent.signal_pickitem_cancel.emit(null)
			return
	
	
func init_data(_init_data:Array):
	inven_data = _init_data.duplicate()
	update_ui()
	print('inven_data', inven_data)
	
func init_debug_data(_init_data:Array):
	inven_data = []
	for entity_type in _init_data:
		if entity_type == null or entity_type == Constants.ENTITY_TYPE.EMPTY:
			inven_data.append(null)
		else:
			inven_data.append(IvenItem.instantiate(entity_type, 1))
	update_ui()
	print('inven_data', inven_data)
	

func update_ui():
	var slots = get_tree().get_nodes_in_group("item_slot") as Array[ItemSlot]
	for s in slots:
		s.queue_free()
		
	var inven_size = inven_data.size()
	for i in range(inven_size):
		var data = inven_data[i]
		var item_container = ITEM_CONTAINER.instantiate() as ItemSlot
		item_container.idx = i
		
		item_container.signal_mouse_entered.connect(_on_signal_mouse_entered_slot)
		item_container.signal_mouse_exited.connect(_on_signal_mouse_exited_slot)
		grid_container.add_child(item_container)
		item_container.set_data(data)
			
	grid_container.columns = inven_size


#func add_pickup(contain_type:Constants.ENTITY_TYPE, count:int=1)->bool:
	#"""
	#return true if has room
	#"""
	#var first_null_idx = null
	#for i in range(inven_data.size()):
		#if inven_data[i] != null:
			#var data = inven_data[i] as IvenItem
			#if data.item_res.entity_type == contain_type:
				## TODO add anim
				#data.count += count
				#update_ui()
				#return true
		#else:
			#if first_null_idx == null:
				#first_null_idx = i
				#
	#if first_null_idx != null:
		#var new_item = IvenItem.new()
		#inven_data[first_null_idx] = IvenItem.instantiate(contain_type, count)
		#update_ui()
		#print('inven_data', inven_data)
		#return true
	#else:
		#return false

func add_pickup(contain_type:Constants.ENTITY_TYPE, count:int=1)->bool:
	var return_flag = false
	
	for i in range(count):
		var valid_slot_idx = get_valid_slot_idx(contain_type)
		if valid_slot_idx != null:
			return_flag = true
			if inven_data[valid_slot_idx] != null:
				(inven_data[valid_slot_idx] as IvenItem).count += 1
			else:
				inven_data[valid_slot_idx] = IvenItem.instantiate(contain_type, 1)
			update_ui()
			
	return return_flag
		

func get_valid_slot_idx(contain_type:Constants.ENTITY_TYPE):
	var first_null_idx = null
	for i in range(inven_data.size()):
		if inven_data[i] != null:
			var data = inven_data[i] as IvenItem
			if is_stackable and data.item_res.entity_type == contain_type:
				return i
			else:
				continue
		else:
			if first_null_idx == null:
				first_null_idx = i
				
	if first_null_idx != null:
		return first_null_idx
	else:
		return null
			


func _on_signal_inventory_capacity_increase():
	if inven_data.size() >= max_iven_capacity:
		return
	else:
		inven_data.append(null)
		update_ui()
	

func _on_signal_mouse_entered_slot(_slot:ItemSlot):
	hover_slot = _slot

func _on_signal_mouse_exited_slot(_slot:ItemSlot):
	hover_slot = null
	
func _on_signal_pickitem_cancel(trans_data:Dictionary):
	curr_preview.queue_free()
	curr_preview = null

func _on_signal_pickitem_drop_update_inventory(slot_id):
	curr_preview.queue_free()
	curr_preview = null
	
	var iven_item = inven_data[slot_id] as IvenItem
	iven_item.count -= 1
	if iven_item.count == 0:
		inven_data[slot_id] = null
	update_ui()
