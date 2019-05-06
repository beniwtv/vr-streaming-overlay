extends Control

func _ready():
	SignalManager.connect("render_targetsize", self, "_on_render_targetsize_changed")
	SignalManager.connect("redraw_overlay", self, "_on_redraw_overlay")
	SignalManager.connect("secrets_loaded", self, "_on_redraw_overlay")
	
func _on_render_targetsize_changed(size):
	rect_size = size

func _on_redraw_overlay():
	# Remove all widgets
	for i in get_children():
    	i.queue_free()
	
	# Somehow we need to wait two frames for Godot...
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	# Create fresh widgets
	var arrayWidgets = SettingsManager.get_value("user", "widgets/configuration", DefaultSettings.get_default_setting("widgets/configuration"))
	
	for i in range(0, arrayWidgets.size()):
		var metadata = arrayWidgets[i]
		
		var widget_data = load(metadata["data"]["widget"]).new()
		var widget = load(widget_data.get_widget_render_scene()).instance()
		widget.apply_config(metadata["id"], metadata["data"]["config"])
		widget.set_meta("widget_id", metadata["id"])
		
		if metadata["data"]["parent"]:
			var parentitem = _walk_nodes(self, metadata["data"]["parent"])
			parentitem.add_child(widget)
		else:
			add_child(widget)

func _walk_nodes(node, widget_id):
	if node.get_meta("widget_id") == widget_id:
		return node
	else:
		var founditem
	
		for i in node.get_children():				
			founditem = _walk_nodes(i, widget_id)
			if founditem: return founditem
