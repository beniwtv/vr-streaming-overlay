extends Tree

var WidgetsNode = "../../../.."

# Check if we can drop this node to our widget tree
func can_drop_data(position, data):
	var candrop = typeof(data) == TYPE_DICTIONARY and data.has("display_name") and data.has("option_scene")
	
	if candrop:
		drop_mode_flags = DROP_MODE_ON_ITEM | DROP_MODE_INBETWEEN
	else:
		drop_mode_flags = DROP_MODE_DISABLED
	
	return candrop
	
# A node was dropped to our tree, handle it as widget
func drop_data(position, data):
	var treeitem = get_item_at_position(position)
	var treesection = get_drop_section_at_position(position)
	var uuid = null
	
	if treeitem and treesection == -1:
		var treeparent = treeitem.get_parent()
		
		if treeparent:
			uuid = treeparent.get_metadata(0)
	elif treeitem and treesection == 0:
		uuid = treeitem.get_metadata(0)
	elif treeitem and treesection == 1:
		var treeparent = treeitem.get_parent()
		
		if treeparent:
			uuid = treeparent.get_metadata(0)
		else:
			treeparent = treeitem
			uuid = treeparent.get_metadata(0)		
	else:
		pass		
	
	if treeitem:
		get_node(WidgetsNode).add_widget_to_tree(uuid, treeitem.get_metadata(0), treesection, data['widget'])

# A delete button was pressed on the tree, remove it
func _on_WidgetTree_button_pressed(item, column, id):
	get_node(WidgetsNode).remove_widget_from_tree(item.get_metadata(column))

# Item was selected, open it's option panel
func _on_WidgetTree_item_selected():
	get_node(WidgetsNode).show_widget_options((get_selected().get_metadata(0)))
