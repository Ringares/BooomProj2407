extends Node
class_name WeightTable

var total_weight = 0.
var accu_weight_dict = {}
var weight_dict = {}

func _init(items=Array()):
	for i in items:
		add_item(i, 0.1)


func calulate_accu_weight_dict(temp_weight_dict):
	var temp_total_weight = 0
	var temp_accu_weight_dict = {}
	for obj in temp_weight_dict.keys():
		temp_total_weight += temp_weight_dict[obj]
		temp_accu_weight_dict[obj] = temp_total_weight
	return [temp_accu_weight_dict, temp_total_weight]


func add_item(obj, weight:float):
	if obj in weight_dict:
		weight_dict[obj] += weight
	else:
		weight_dict[obj] = weight
		
	var results = calulate_accu_weight_dict(weight_dict)
	accu_weight_dict = results[0]
	total_weight = results[1]

func get_size():
	return weight_dict.size()

func rand_pick():
	var roll: float = randf_range(0.0, total_weight)
	for obj in accu_weight_dict.keys():
		if (accu_weight_dict[obj] > roll):
			return obj
	return null
	
func rand_pick_multi(nums:int):
	var results = []
	if nums >= weight_dict.size():
		results = weight_dict.keys()
		results.shuffle()
	else:
		while results.size() < nums:
			var pick = rand_pick()
			if pick not in results:
				results.append(pick)
	return results
		
	
func rand_pick_by_exclude(exclude_obj:Array):
	var temp_weight_dict = {}
	for obj in weight_dict.keys():
		if obj in exclude_obj:
			break
		else:
			temp_weight_dict[obj] = weight_dict[obj]
			
	var results = calulate_accu_weight_dict(temp_weight_dict)
	var temp_accu_weight_dict = results[0]
	var temp_total_weight = results[1]
	
	var roll: float = randf_range(0.0, temp_total_weight)
	for obj in temp_accu_weight_dict.keys():
		if (temp_accu_weight_dict[obj] > roll):
			return obj
	return null
