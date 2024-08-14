extends Node
class_name AttackComponent

@export var temp_attack:int = 0
@export var base_attack:int = 1

func init_data(data:int):
	temp_attack = 0
	base_attack = data
	AutoLoadEvent.signal_str_update.emit(temp_attack, base_attack)
	print('init AttackComponent: temp_attack=%d, base_attack=%d' % [temp_attack, base_attack])

func get_attack_damage():
	var return_damage = temp_attack + base_attack
	if temp_attack > 0:
		temp_attack = 0
		AutoLoadEvent.signal_str_update.emit(temp_attack, base_attack)
	return return_damage


func increase_temp_attack(points:int):
	temp_attack += points
	AutoLoadEvent.signal_str_update.emit(temp_attack, base_attack)
	print('increase_temp_attack: temp_attack=%d, base_attack=%d' % [temp_attack, base_attack])
	

func increase_base_attack(points:int):
	base_attack += points
	AutoLoadEvent.signal_str_update.emit(temp_attack, base_attack)
	print('increase_base_attack: temp_attack=%d, base_attack=%d' % [temp_attack, base_attack])
