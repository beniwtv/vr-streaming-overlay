extends ItemList

func get_drag_data(position):
	var item = get_item_at_position(position)

	if item > -1:
		return get_item_metadata(item)
