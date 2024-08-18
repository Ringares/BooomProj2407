extends CanvasLayer
class_name TutorialScene

signal signal_tutorial_dimiss

const DialogueConstants = preload("res://addons/dialogue_manager/constants.gd")

const _1_1 = preload("res://asset/image/tutorial/1_1.png")
const _1_2 = preload("res://asset/image/tutorial/1_2.png")
const _1_3 = preload("res://asset/image/tutorial/1_3.png")
const _1_4 = preload("res://asset/image/tutorial/1_4.png")
const _1_5 = preload("res://asset/image/tutorial/1_5.png")
const _2_1 = preload("res://asset/image/tutorial/2_1.png")
const _2_2 = preload("res://asset/image/tutorial/2_2.png")
const _3_1 = preload("res://asset/image/tutorial/3_1.png")
const _4_1 = preload("res://asset/image/tutorial/4_1.png")

const img_list = [
	_1_1,_1_2,_1_3,_1_4,_1_5,_2_1,_2_2,_3_1,_4_1
]

const text_list = [
	"这是星光，是一只战斗超群的太空猫，它有血量和力量两种属性。",
	"当处于自动行动模式时，猫咪会自动向前行走，而处于手动模式时每次按空格按键可以向前走一步，可以通过T按键在自动模式和手动模式之间切换。",
	"星光可以在场景中发到一些装有轨道的宝箱，玩家可以消耗一点电力将道具放置在空间站中改变星光移动方向。空间站中有的浅色地块代表可以放置道具，而深色地块代表无法放置道具的区域。",
	"空间站中遍布可怕的怪物，我们要步步为营保护星光的安全，击败怪物可以获得放置道具所需的电力。星光与怪物交战时会同时遭受对方力量值的攻击，一方生命值到0则为战败。",
	"我们最终的目标是帮助星光到达逃生点，那么现在开始吧！",
	"力量药剂可以临时为星光带来力量加成，但只会生效一次；而生命药剂则可以在本关中为星光增加抵挡伤害的护盾。",
	"关卡中有些怪物是会根据时间而反复刷新的，要注意哦。本关中会出现生命和力量都更加强大的敌人，合理运用道具击败敌人吧！",
	"星光发现了装有怪物的宝箱，消耗电力选择放置的位置即可生成怪物，要拿来做什么用呢...",
	"本关中会出现新的道具：转换器！获得转换器后消耗电力可以将两个地块交换位置，灵活使用或许会有奇效！",
]

@export var start_idx:int = 0
@export var end_idx:int = 3
@export var begin_idx:int = 0


var curr_idx:int = 0:
	set(new_idx):
		
		if new_idx <= 0 :
			left_button.hide()
		else:
			left_button.show()
			
		if new_idx > end_idx:
			dismiss()
		else:
			curr_idx = new_idx
			_next_line()


@onready var texture_rect = $TextureRect
@onready var dialogue_label:DialogueLabel = %DialogueLabel

@onready var left_button = $LeftButton
@onready var right_button = $RightButton
	

func display(force:bool=false):
	if not force:
		if GameLevelLog.get_finished_tutorial_id() >= begin_idx:
			return false
	
	curr_idx = begin_idx
	show()
	return true


func dismiss():
	hide()
	signal_tutorial_dimiss.emit()
	GameLevelLog.set_finished_tutorial_id(begin_idx)
	

func _input(event):
	if self.visible:
		if Input.is_action_just_pressed("ui_accept"):
			if dialogue_label.is_typing:
				dialogue_label.skip_typing()
			curr_idx += 1
			get_viewport().set_input_as_handled()
			
			
		if Input.is_action_just_pressed("ui_cancel"):
			dismiss()
			get_viewport().set_input_as_handled()
			


func _next_line():
	SfxManager.play_turn_direction()
	var curr_text = text_list[curr_idx]
	var curr_img = img_list[curr_idx]
	
	texture_rect.texture = curr_img
	dialogue_label.dialogue_line = DialogueLine.new({
				id = "",#id = data.get(&"id", ""),
				type = DialogueConstants.TYPE_DIALOGUE,
				next_id = "",#next_id = data.next_id,
				character = "",#character = await get_resolved_character(data, extra_game_states),
				text = curr_text,

			})
	dialogue_label.type_out()
	await dialogue_label.finished_typing


func _on_left_button_pressed():
	curr_idx -= 1


func _on_right_button_pressed():
	curr_idx += 1
