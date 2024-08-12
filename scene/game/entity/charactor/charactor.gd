extends Entity
class_name Charactor

@export var move_component:GridMoveComponent
@export var attack_compoent:AttackComponent
@export var health_component:HealthComponent
@export var resource_component:ResourceComponent

@onready var anim = %Anim


func set_direction(dir:Vector2):
	if move_component:
		move_component.direction = dir

func get_direction():
	if move_component:
		return move_component.direction
	else:
		return null


func move_to_pos(to_position:Vector2, need_anim:bool):
	if not need_anim:
		self.position = to_position
		return
	
	if tween !=null and tween.is_valid():
		tween.kill()
	
	tween = create_tween()
	if self.position.x == to_position.x:
		tween.tween_property(self, "position", to_position, move_component.move_dutation)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(anim, 'scale', Vector2(1.0,1.2), move_component.move_dutation/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.chain().tween_property(anim, 'scale', Vector2(1.0,1.0), move_component.move_dutation/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	else:
		tween.tween_property(self, "position", to_position, move_component.move_dutation)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(anim, 'scale', Vector2(1.2,1.0), move_component.move_dutation/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.chain().tween_property(anim, 'scale', Vector2(1.0,1.0), move_component.move_dutation/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	


func play_hit_anim():
	start_flash()


func start_flash():
	if sprite_2d.material == null:
		sprite_2d.material = ShaderMaterial.new()
		sprite_2d.material.resource_local_to_scene = true
	
	sprite_2d.material.shader = HIT_FLASH_SHADER
	
	if tween !=null and tween.is_valid():
		tween.kill()
	
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("lerp_percent", 1.0)
	tween = create_tween()
	tween.tween_property(sprite_2d.material, "shader_parameter/lerp_percent", 0., 0.3)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

func pre_move_execute(entity:Entity)->bool:
	if entity == null:
		return true
	
	if entity.type == Constants.ENTITY_TYPE.ENERMY_A or entity.type == Constants.ENTITY_TYPE.ENERMY_B:
		print('Constants.ENTITY_TYPE.ENERMY...')
		if not (entity as Enermy).is_valid:
			return true
		
		# 战斗逻辑
		var is_char_dead = health_component.take_damage((entity as Enermy).attack_component.temp_attack)
		var is_enermy_dead = (entity as Enermy).health_component.take_damage(attack_compoent.temp_attack)
		play_hit_anim()
		entity.play_hit_anim()
		SfxManager.play_attack()
		if is_char_dead:
			SfxManager.play_fail()
			get_tree().create_timer(1.0).timeout.connect(func():AutoLoadEvent.signal_level_fail.emit())
			return false
			
		if is_enermy_dead:
			entity.dead()
			resource_component.add_resource((entity as Enermy).loot_energy)
			return false
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
			SfxManager.play_turn_direction()
			set_direction(entity.direction)
			
		Constants.ENTITY_TYPE.HEALTH_TEMP_UP:
			print('ENTITY_TYPE.HEALTH_TEMP_UP')
			SfxManager.play_heal()
			health_component.heal_hp((entity as PropertyItem).points)
			entity.signal_entity_used.emit(entity)
			
		Constants.ENTITY_TYPE.HEALTH_UP:
			print('ENTITY_TYPE.HEALTH_UP')
			SfxManager.play_upgrade()
			health_component.increase_max_hp((entity as PropertyItem).points)
			entity.signal_entity_used.emit(entity)
			
			
		Constants.ENTITY_TYPE.STRENGTH_TEMP_UP:
			print('ENTITY_TYPE.STRENGTH_TEMP_UP')
			SfxManager.play_heal()
			attack_compoent.increase_temp_attack((entity as PropertyItem).points)
			entity.signal_entity_used.emit(entity)
		
		Constants.ENTITY_TYPE.STRENGTH_UP:
			print('ENTITY_TYPE.STRENGTH_UP')
			SfxManager.play_upgrade()
			attack_compoent.increase_base_attack((entity as PropertyItem).points)
			entity.signal_entity_used.emit(entity)
			
			
		Constants.ENTITY_TYPE.EXIT:
			print('ENTITY_TYPE.EXIT')
			SfxManager.play_win()
			await get_tree().create_timer(1.0).timeout
			AutoLoadEvent.signal_level_won.emit()
			
		Constants.ENTITY_TYPE.RECYCLING:
			pass
			
		Constants.ENTITY_TYPE.ENERGY_UP:
			print('ENTITY_TYPE.ENERGY_UP')
			SfxManager.play_upgrade()
			resource_component.add_resource((entity as PropertyItem).points)
			entity.signal_entity_used.emit(entity)
			
		Constants.ENTITY_TYPE.ENERGY_ROOM_UP:
			print('ENTITY_TYPE.ENERGY_ROOM_UP')
			SfxManager.play_upgrade()
			resource_component.increase_resource_capacity((entity as PropertyItem).points)
			entity.signal_entity_used.emit(entity)
			
		Constants.ENTITY_TYPE.INVENTORY_ROOM_UP:
			print('ENTITY_TYPE.INVENTORY_ROOM_UP')
			SfxManager.play_upgrade()
			AutoLoadEvent.signal_inventory_capacity_increase.emit()
			entity.signal_entity_used.emit(entity)
			
		Constants.ENTITY_TYPE.CHEST:
			print('ENTITY_TYPE.CHEST')
			SfxManager.play_open_chest()
			if entity.has_signal('signal_chest_pickup'):
				entity.signal_chest_pickup.emit(entity)
			
		Constants.ENTITY_TYPE.SWITCHER:
			pass
		
