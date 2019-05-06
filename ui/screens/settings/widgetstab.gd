extends Tabs

var WidgetsBoxNode = "MarginContainer/VBoxContainer/Widgets/WidgetBox"
var WidgetTree = "MarginContainer/VBoxContainer/HBoxContainer/WidgetTree"
var OptionContainer = "MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/WidgetOptionsArea"

var UUID = preload("res://addons/godot-uuid/uuid.gd")

# Stores the final user's widget configuration
var widgets = preload("res://utils/tree.gd").new()

# Contains the current widget options panel being displayed
var current_widget_panel = null
var current_widget_id = null

func _ready():
	# Load base widgets
	var MarginContainerWidget = preload("res://widgets/margincontainer.gd").new();

	get_node(WidgetsBoxNode).add_item(MarginContainerWidget.get_widget_display_name(), MarginContainerWidget.get_widget_icon())
	get_node(WidgetsBoxNode).set_item_tooltip(get_node(WidgetsBoxNode).get_item_count() - 1, MarginContainerWidget.get_widget_tooltip())
	get_node(WidgetsBoxNode).set_item_metadata(get_node(WidgetsBoxNode).get_item_count() - 1, MarginContainerWidget.get_metadata())

	var VboxContainerWidget = preload("res://widgets/vboxcontainer.gd").new();
	
	get_node(WidgetsBoxNode).add_item(VboxContainerWidget.get_widget_display_name(), VboxContainerWidget.get_widget_icon())
	get_node(WidgetsBoxNode).set_item_tooltip(get_node(WidgetsBoxNode).get_item_count() - 1, VboxContainerWidget.get_widget_tooltip())
	get_node(WidgetsBoxNode).set_item_metadata(get_node(WidgetsBoxNode).get_item_count() - 1, VboxContainerWidget.get_metadata())
	
	var HboxContainerWidget = preload("res://widgets/hboxcontainer.gd").new();
	
	get_node(WidgetsBoxNode).add_item(HboxContainerWidget.get_widget_display_name(), HboxContainerWidget.get_widget_icon())
	get_node(WidgetsBoxNode).set_item_tooltip(get_node(WidgetsBoxNode).get_item_count() - 1, HboxContainerWidget.get_widget_tooltip())
	get_node(WidgetsBoxNode).set_item_metadata(get_node(WidgetsBoxNode).get_item_count() - 1, HboxContainerWidget.get_metadata())
	
	# Load dynamic widgets
	var dir = Directory.new()
	
	if dir.open("res://widgets") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var blacklist = ["basewidget.gd", "margincontainer.gd", "vboxcontainer.gd", "hboxcontainer.gd"]

		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				if file_name.ends_with(".gd") and blacklist.find(file_name) == -1 and !file_name.ends_with("options.tscn") and !file_name.ends_with("options.gd") and !file_name.ends_with("widget.gd"):
					var widget = load("res://widgets/" + file_name).new()
					print("Found widget: " + widget.get_widget_display_name() + " (" + file_name + ")")
			
					get_node(WidgetsBoxNode).add_item(widget.get_widget_display_name(), widget.get_widget_icon())
					get_node(WidgetsBoxNode).set_item_tooltip(get_node(WidgetsBoxNode).get_item_count() - 1, widget.get_widget_tooltip())
					get_node(WidgetsBoxNode).set_item_metadata(get_node(WidgetsBoxNode).get_item_count() - 1, widget.get_metadata())
			
			file_name = dir.get_next()
	else:
		print("Unable to load widgets - path not found!")

	# Load saved tree or add default margin + Twitch chat widgets
	widgets.set_tree_from_array(SettingsManager.get_value("user", "widgets/configuration", DefaultSettings.get_default_setting("widgets/configuration")))
	_redraw_tree()
	
	SignalManager.connect("options_changed", self, "_on_options_changed")

# Saves the widgets to the user's config file
func save_tree():
	var arrayWidgets = widgets.get_tree_as_array()
	SettingsManager.set_value("user", "widgets/configuration", arrayWidgets)

# Widget was selected, open it's option panel
func show_widget_options(widget_id):
	if current_widget_panel:
		# Unload the current panel first
		current_widget_panel.queue_free()
	
	var widget = widgets.get_item(widget_id)
	current_widget_panel = load(widget["data"]["option_scene"]).instance()
	get_node(OptionContainer).add_child(current_widget_panel)

	current_widget_panel.add_config_options(widget_id, widget["data"]["config"])
	current_widget_id = widget_id
	
	# Show ratio adjust, except for the root
	if !widget["data"]["parent"]:
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/SpaceRatioOption.visible = false
	else:
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/SpaceRatioOption.visible = true
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/SpaceRatioOption/HBoxContainer/HSlider.value = widget["data"]["config"]["ratio"]

# Adds a new widget to the tree	
func add_widget_to_tree(parent, droppednear, droppedsection, widgetpath):
	var widget = load(widgetpath).new()
	
	# Add few things to metadata we need for saving later
	var metadata = widget.get_metadata()
	metadata["parent"] = parent
	metadata["config"] = {"ratio": 1}
	metadata["id"] = UUID.v4()
	
	widgets.add_item(parent, droppednear, droppedsection, metadata)

	_redraw_tree()
	save_tree()
	
	SignalManager.emit_signal("redraw_overlay")

# Removes a widget from the tree
func remove_widget_from_tree(widget_id):
	var widget = widgets.get_item(widget_id)
	
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.window_title = "Delete widget?"
	confirm_dialog.dialog_text = "Do you really want to remove the widget '" + widget["data"]["display_name"] + "' and all it's sub-widgets?"
	confirm_dialog.connect("confirmed", self, "_on_widget_remove_confirm", [widget_id])
	
	add_child(confirm_dialog)	
	confirm_dialog.popup_centered()

func _on_widget_remove_confirm(widget_id):
	widgets.remove_item(widget_id)
	
	_redraw_tree()
	save_tree()
	
	SignalManager.emit_signal("redraw_overlay")

# Redraw the tree widget in the settings window
func _redraw_tree():
	get_node(WidgetTree).clear()
	var arrayWidgets = widgets.get_tree_as_array()

	for i in range(0, arrayWidgets.size()):
		var metadata = arrayWidgets[i]
		var treeitem		
		
		if metadata["data"]["parent"]:
			var parentitem = _walk_tree(get_node(WidgetTree).get_root(), metadata["data"]["parent"])
			treeitem = get_node(WidgetTree).create_item(parentitem)
		else:
			treeitem = get_node(WidgetTree).create_item()
		
		var widget = load(metadata["data"]["widget"]).new()
		treeitem.set_text(0, widget.get_widget_display_name())
		treeitem.set_icon(0, widget.get_widget_icon())
		treeitem.set_metadata(0, metadata["id"])

		if metadata["data"]["parent"]:
			# Add remove button
			treeitem.add_button(0, load("res://ui/icons/remove.png"), -1, false, "Delete this widget")

func _walk_tree(currentitem, id):
	if currentitem.get_metadata(0) == id:
		return currentitem
	else:
		var item = currentitem.get_children()
		var foundid
	
		while (item):
			foundid = _walk_tree(item, id)
			
			if !foundid:
				item = item.get_next()
			else:
				item = null
		
		return foundid

# Updates the slider ratio value on the current widget
func _on_SpaceRatioOptionSlider_value_changed(value):
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/SpaceRatioOption/HBoxContainer/ValueDisplay.text = str(value)
	
	var data = widgets.get_item_data(current_widget_id)
	data["config"]["ratio"] = value
	widgets.set_item_data(current_widget_id, data)
	
	SignalManager.emit_signal("redraw_overlay")
	save_tree()

func _on_options_changed():
	SignalManager.emit_signal("redraw_overlay")
	save_tree()
