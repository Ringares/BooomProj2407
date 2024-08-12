extends Entity
class_name Charactor

@export var move_component:GridMoveComponent
@export var attack_compoent:AttackComponent
@export var health_component:HealthComponent
@export var resource_component:ResourceComponent
	

func set_direction(dir:Vector2):
	if move_component:
		move_component.direction = dir

func get_direction():
	if move_component:
		return move_component.direction
	else:
		return null


func play_hit_anim():
	pass


func pre_move_execute(entity:Entity)->bool:
	if entity == null:
		return true
	
	if entity.type == Constants.ENTITY_TYPE.ENERMY_A or entity.type == Constants.ENTITY_TYPE.ENERMY_B:
		print('Constants.ENTITY_TYPE.ENERMY...')
		
		# 战斗逻辑
		var is_char_dead = health_component.take_damage((entity as Enermy).attack_component.temp_attack)
		var is_enermy_dead = (entity as Enermy).health_component.take_damage(attack_compoent.temp_attack)
		play_hit_anim()
		entity.play_hit_anim()
		if is_char_dead:
			SfxManager.play_fail()
			get_tree().create_timer(1.0).timeout.connect(func():AutoLoadEvent.signal_level_fail.emit())
			return false
			
		if is_enermy_dead:
			entity.dead()
			resource_component.add_resource((entity as Enermy).loot_energy)
			return true
		else:
			return false
		
	return true
	
	
func post_move_execute(entity:Entity):
	SfxManager.play_walk()
	if entity == null:
		return
	
	match entity.type: 
		Constants.ENTITY_TYPE.UNKNOW:
			pass
		Constants.ENTITY_TYPE.TRAIL:
			print('ENTITY_TYPE.TRAIL')
			set_direction(entity.direction)
			
		Constants.ENTITY_TYPE.HEALTH_TEMP_UP:
			print('ENTITY_TYPE.HEALTH_TEMP_UP')
			health_component.heal_hp((entity as PropertyItem).points)
			entity.signal_entity_used.emit(entity)
			SfxManager.play_upgrade()
			
		Constants.ENTITY_TYPE.HEALTH_UP:
			print('ENTITY_TYPE.HEALTH_UP')
			health_component.increase_max_hp((entity as PropertyItem).points)
			entity.signal_entity_used.emit(entity)
			SfxManager.play_upgrade()
			
		Constants.ENTITY_TYPE.STRENGTH_TEMP_UP:
			print('ENTITY_TYPE.STRENGTH_TEMP_UP')
			attack_compoent.increase_temp_attack((entity as PropertyItem).points)
			entity.signal_entity_used.emit(entity)
			SfxManager.play_upgrade()
		
		Constants.ENTITY_TYPE.STRENGTH_UP:
			print('ENTITY_TYPE.STRENGTH_UP')
			attack_compoent.increase_base_attack((entity as PropertyItem).points)
			entity.signal_entity_used.emit(entity)
			SfxManager.play_upgrade()
			
		Constants.ENTITY_TYPE.EXIT:
			print('ENTITY_TYPE.EXIT')
			SfxManager.play_win()
			await get_tree().create_timer(1.0).timeout
			AutoLoadEvent.signal_level_won.emit()
			
		Constants.ENTITY_TYPE.RECYCLING:
			pass
			
		Constants.ENTITY_TYPE.ENERGY_UP:
			print('ENTITY_TYPE.ENERGY_UP')
			resource_component.add_resource((entity as PropertyItem).points)
			entity.signal_entity_used.emit(entity)
			
		Constants.ENTITY_TYPE.ENERGY_ROOM_UP:
			print('ENTITY_TYPE.ENERGY_ROOM_UP')
			resource_component.increase_resource_capacity((entity as PropertyItem).points)
			entity.signal_entity_used.emit(entity)
			
		Constants.ENTITY_TYPE.INVENTORY_ROOM_UP:
			print('ENTITY_TYPE.INVENTORY_ROOM_UP')
			AutoLoadEvent.signal_inventory_capacity_increase.emit()
			entity.signal_entity_used.emit(entity)
			
		Constants.ENTITY_TYPE.CHEST:
			print('ENTITY_TYPE.CHEST')
			if entity.has_signal('signal_chest_pickup'):
				entity.signal_chest_pickup.emit(entity)
			
		Constants.ENTITY_TYPE.SWITCHER:
			pass
		
