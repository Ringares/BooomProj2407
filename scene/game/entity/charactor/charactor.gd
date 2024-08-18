extends Entity
class_name Charactor

@export var move_component:GridMoveComponent
@export var attack_compoent:AttackComponent
@export var health_component:HealthComponent
@export var resource_component:ResourceComponent
@export var number_indicator_component:NumberIndicatorComponent

@onready var anim = %Anim
@onready var animation_player = %AnimationPlayer


func set_direction(dir:Vector2):
	if move_component:
		move_component.direction = dir


func get_direction():
	if move_component:
		return move_component.direction
	else:
		return null


func play_level_enter_anim():
	await ready
	animation_player.play("enter_level")
	await get_tree().create_timer(2).timeout


func move_to_pos(to_position:Vector2, need_anim:bool):
	if not need_anim:
		self.position = to_position
		return
	
	if tween !=null and tween.is_valid():
		tween.kill()
		
	
	tween = create_tween()
	if self.position.x == to_position.x:
		var jump_direction = (self.position as Vector2).direction_to(to_position).rotated(-PI/2)
		var half_position = self.position + (to_position - self.position) * 1/3 + jump_direction * 16
		
		tween.tween_property(self, "position", half_position, move_component.move_dutation*1/3)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", to_position, move_component.move_dutation*2/3)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		#tween.tween_property(self, "position", to_position, move_component.move_dutation)\
			#.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		#tween.parallel().tween_property(anim, 'scale', Vector2(1.0,1.1), move_component.move_dutation/2)\
			#.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		#tween.chain().tween_property(anim, 'scale', Vector2(1.0,1.0), move_component.move_dutation/2)\
			#.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	else:
		var half_position = self.position + (to_position - self.position) * 1/3 + Vector2.UP * 16
		tween.tween_property(self, "position", half_position, move_component.move_dutation*1/3)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", to_position, move_component.move_dutation*2/3)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		#tween.tween_property(self, "position", to_position, move_component.move_dutation)\
			#.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		#tween.parallel().tween_property(anim, 'scale', Vector2(1.1,1.0), move_component.move_dutation/2)\
			#.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		#tween.chain().tween_property(anim, 'scale', Vector2(1.0,1.0), move_component.move_dutation/2)\
			#.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	

func move_to_pos_through_edge(to_position:Vector2, need_anim:bool):
	if not need_anim:
		self.position = to_position
		return
	
	if tween !=null and tween.is_valid():
		tween.kill()
	
	tween = create_tween()
	var anim_direction = - (self.position as Vector2).direction_to(to_position)
	
	print('move_to_pos_through_edge %v->%v', [self.position, to_position])
	if self.position.x == to_position.x:
		tween.tween_property(self, "position", self.position + anim_direction * 64, move_component.move_dutation/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(anim, 'scale', Vector2(1.0,0), move_component.move_dutation/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			
		tween.chain().tween_property(self, 'position', to_position - anim_direction * 64, 0.0)
			
		tween.chain().tween_property(self, "position", to_position, move_component.move_dutation/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(anim, 'scale', Vector2(1.0,1.0), move_component.move_dutation/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	else:
		tween.tween_property(self, "position", self.position + anim_direction * 64, move_component.move_dutation/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(anim, 'scale', Vector2(0.0,1.0), move_component.move_dutation/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			
		tween.chain().tween_property(self, 'position', to_position - anim_direction * 64, 0.0)
			
		tween.chain().tween_property(self, "position", to_position, move_component.move_dutation/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(anim, 'scale', Vector2(1.0,1.0), move_component.move_dutation/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished


func play_hit_anim():
	# play_hit_flash()
	if sprite_2d.material == null:
		sprite_2d.material = ShaderMaterial.new()
		sprite_2d.material.resource_local_to_scene = true
	
	sprite_2d.material.shader = HIT_FLASH_SHADER
	
	if tween !=null and tween.is_valid():
		tween.kill()
	
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("lerp_percent", 1.0)
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("flash_color", Vector3(1.0, 1.0, 1.0))
	
	var origin_pos = sprite_2d.position
	tween = create_tween()
	tween.tween_property(sprite_2d.material, "shader_parameter/lerp_percent", 0., 0.3)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		
	tween.parallel().tween_method(shake_sprite, 0,5,0.3)
	tween.parallel().tween_property(sprite_2d, "position", origin_pos + move_component.direction * 128 / 3, 0.1)
	tween.chain().tween_property(sprite_2d, "position", origin_pos, 0.)
	
	

func shake_sprite(shake_count):
	var shake = 2
	sprite_2d.position += Vector2(randf_range(-shake, shake),randf_range(-shake, shake))
	
	

func play_heal_anim():
	play_hit_flash(Vector3(1.0, 0.8, 0.8))


func play_str_up_anim():
	play_hit_flash(Vector3(0.8, 0.8, 1.0))


func pre_move_execute(entity:Entity)->bool:
	if entity == null:
		return true
	
	if entity.type in [
		Constants.ENTITY_TYPE.ENERMY_A,
		Constants.ENTITY_TYPE.ENERMY_B,
		Constants.ENTITY_TYPE.ENERMY_C ]:
		print('Constants.ENTITY_TYPE.ENERMY...')
		if not (entity as Enermy).is_valid:
			return true
		
		# 战斗逻辑
		var enermy_damage = (entity as Enermy).attack_component.get_attack_damage()
		number_indicator_component.display("-%d" % enermy_damage, Color("#ff9b9b"))
		
		var is_char_dead = health_component.take_damage(enermy_damage)
		var is_enermy_dead = (entity as Enermy).health_component.take_damage(attack_compoent.get_attack_damage())
		play_hit_anim()
		entity.play_hit_anim()
		SfxManager.play_attack()
		if is_char_dead:
			SfxManager.play_fail()
			#get_tree().create_timer(0.3).timeout.connect(func():AutoLoadEvent.signal_level_fail.emit())
			AutoLoadEvent.signal_level_fail.emit()
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
			play_heal_anim()
			health_component.heal_hp((entity as PropertyItem).points)
			number_indicator_component.display("+%d" % (entity as PropertyItem).points, Color("#ff9b9b"))
			entity.signal_entity_used.emit(entity)
			
		Constants.ENTITY_TYPE.HEALTH_UP:
			print('ENTITY_TYPE.HEALTH_UP')
			SfxManager.play_upgrade()
			play_heal_anim()
			health_component.increase_max_hp((entity as PropertyItem).points)
			number_indicator_component.display("+%d" % (entity as PropertyItem).points, Color("#ff9b9b"))
			entity.signal_entity_used.emit(entity)
			
			
		Constants.ENTITY_TYPE.STRENGTH_TEMP_UP:
			print('ENTITY_TYPE.STRENGTH_TEMP_UP')
			SfxManager.play_heal()
			play_str_up_anim()
			attack_compoent.increase_temp_attack((entity as PropertyItem).points)
			number_indicator_component.display("+%d" % (entity as PropertyItem).points, Color("#9bb7f0"))
			entity.signal_entity_used.emit(entity)
		
		Constants.ENTITY_TYPE.STRENGTH_UP:
			print('ENTITY_TYPE.STRENGTH_UP')
			SfxManager.play_upgrade()
			play_str_up_anim()
			attack_compoent.increase_base_attack((entity as PropertyItem).points)
			number_indicator_component.display("+%d" % (entity as PropertyItem).points, Color("#9bb7f0"))
			entity.signal_entity_used.emit(entity)
			
			
		Constants.ENTITY_TYPE.EXIT:
			print('ENTITY_TYPE.EXIT')
			SfxManager.play_win()
			#get_tree().create_timer(0.3).timeout.connect(func():AutoLoadEvent.signal_level_won.emit())
			AutoLoadEvent.signal_level_won.emit()
			
		Constants.ENTITY_TYPE.RECYCLER:
			pass
			
		Constants.ENTITY_TYPE.ENERGY_UP:
			print('ENTITY_TYPE.ENERGY_UP')
			SfxManager.play_upgrade()
			resource_component.add_resource((entity as PropertyItem).points)
			number_indicator_component.display("+%d" % (entity as PropertyItem).points, Color("#f4cda8"))
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
			if (entity as FuncChestItem).is_valid:
				if entity.has_signal('signal_chest_pickup'):
					entity.signal_chest_pickup.emit(entity)
			
		Constants.ENTITY_TYPE.SWITCHER:
			pass
		
