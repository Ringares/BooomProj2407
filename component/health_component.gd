extends Node
class_name HealthComponent

@export var curr_hp:int = 1
@export var max_hp:int = 1
@export var need_signal:bool = false

signal signal_curr_hp_changed

func init_data(data:int):
	curr_hp = data
	max_hp = data
	if need_signal: AutoLoadEvent.signal_hp_update.emit(curr_hp, max_hp)
	print('init HealthComponent: curr_hp=%d, max_hp=%d' % [curr_hp, max_hp])

func increase_max_hp(points:int):
	max_hp += points
	if curr_hp < max_hp:
		curr_hp = max_hp
	if need_signal: AutoLoadEvent.signal_hp_update.emit(curr_hp, max_hp)
	print('increase_max_hp: curr_hp=%d, max_hp=%d' % [curr_hp, max_hp])
	
func heal_hp(points:int):
	curr_hp = curr_hp + points
	if need_signal: AutoLoadEvent.signal_hp_update.emit(curr_hp, max_hp)
	print('heal_hp: curr_hp=%d, max_hp=%d' % [curr_hp, max_hp])
	
func take_damage(points:int)->bool:
	curr_hp = clampi(curr_hp - points, 0, max_hp)
	var is_dead = curr_hp == 0
	signal_curr_hp_changed.emit(curr_hp)
	if need_signal: AutoLoadEvent.signal_hp_update.emit(curr_hp, max_hp)
	print(get_parent(), 'take_damage: curr_hp=%d, max_hp=%d' % [curr_hp, max_hp])
	return is_dead

