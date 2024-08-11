extends Node
class_name AttackComponent

@export var temp_attack:int = 1
@export var base_attack:int = 1

func init_data(data:int):
	temp_attack = data
	base_attack = data
	AutoLoadEvent.signal_str_update.emit(temp_attack, base_attack)
	print('init AttackComponent: temp_attack=%d, base_attack=%d' % [temp_attack, base_attack])

func get_attack_damage():
	var return_damage
	if temp_attack > base_attack:
		return_damage = temp_attack
		# 临时攻击力只在下一次攻击中生效
		temp_attack = base_attack
	else:
		return_damage = base_attack
	return return_damage


func increase_temp_attack(points:int):
	temp_attack += points
	AutoLoadEvent.signal_str_update.emit(temp_attack, base_attack)
	print('increase_temp_attack: temp_attack=%d, base_attack=%d' % [temp_attack, base_attack])
	

func increase_base_attack(points:int):
	base_attack += points
	if temp_attack < base_attack:
		temp_attack = base_attack
	AutoLoadEvent.signal_str_update.emit(temp_attack, base_attack)
	print('increase_base_attack: temp_attack=%d, base_attack=%d' % [temp_attack, base_attack])
