extends Control


@onready var attack_label = %AttackLabel
@onready var hp_container = %HpContainer
@onready var temp_hp_container = %TempHpContainer

const HP_ICON = preload("res://scene/game/game_ui/hp_icon.tscn")
const HP_TEMP_ICON = preload("res://scene/game/game_ui/hp_temp_icon.tscn")

var hp_icons = []
var temp_hp_icons = []

# Called when the node enters the scene tree for the first time.
func _ready():
	AutoLoadEvent.signal_hp_update.connect(_on_signal_hp_update)
	AutoLoadEvent.signal_str_update.connect(_on_signal_str_update)


func _on_signal_hp_update(curr_hp, curr_temp, max_hp):
	print('_on_signal_hp_update', curr_hp, curr_temp, max_hp)
	#hp_label.text = "%d / %d" % [data1, data2]
	if hp_icons.size() < curr_hp:
		for i in curr_hp - hp_icons.size():
			var hp_icon = HP_ICON.instantiate()
			hp_container.add_child(hp_icon)
			hp_icons.append(hp_icon)
	elif hp_icons.size() > curr_hp:
		for i in hp_icons.size() - curr_hp:
			hp_icons.pop_front().queue_free()
	
	if temp_hp_icons.size() < curr_temp:
		for i in curr_temp - temp_hp_icons.size():
			var temp_hp_icon = HP_TEMP_ICON.instantiate()
			temp_hp_container.add_child(temp_hp_icon)
			temp_hp_icons.append(temp_hp_icon)
	elif temp_hp_icons.size() > curr_temp:
		for i in temp_hp_icons.size() - curr_temp:
			temp_hp_icons.pop_front().queue_free()


func _on_signal_str_update(temp_attack, base_attack):
	if temp_attack > 0:
		attack_label.text = "%d + %d" % [base_attack, temp_attack]
	else:
		attack_label.text = "%d" % [base_attack]
