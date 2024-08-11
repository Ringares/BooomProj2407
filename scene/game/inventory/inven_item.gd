extends Node
class_name IvenItem


var count:int = 0
var item_res:ItemRes


static func instantiate(type:Constants.ENTITY_TYPE, _count:int):
	var ins = IvenItem.new()
	ins.count = _count
	ins.item_res = ResourceLoader.load(Constants.EntityMap[type])
	return ins
	
	
