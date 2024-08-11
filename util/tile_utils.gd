extends Node
class_name TileUtils


static func get_rotation(xflip, yflip, transpose)->Array:
	if (!xflip and !transpose):
		return [0.0, yflip]
	elif(xflip  and !transpose ):
		return [PI, !yflip]
	elif(!xflip and transpose):
		return [-PI/2, !yflip]
	elif(xflip and transpose):
		return [PI/2, yflip]
	return []


static func get_custom_data(tile:TileMap, tile_layer:int, cell_id:Vector2i, data_name:String, default:Variant):
	var data = tile.get_cell_tile_data(tile_layer, cell_id)
	if data:
		return data.get_custom_data(data_name)
	else:
		return default
