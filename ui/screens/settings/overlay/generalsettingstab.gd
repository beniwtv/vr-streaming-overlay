extends Tabs

var SettingsNode = "MarginContainer/VBoxContainer/HBoxContainer/"
var current_overlay : Dictionary

func _ready():
	# Left side
	var overlayname = preload("res://ui/elements/options/lineeditoption.tscn").instance()
	get_node(SettingsNode + "LeftSettings").add_child(overlayname)
	overlayname.set_label("Overlay name:")
	overlayname.set_option_name("name")
	overlayname.set_value(DefaultSettings.get_default_setting("overlay/name"))
	overlayname.set_widget_node(self)
	overlayname.add_to_group("general_settings")
	
	var trackinghand = preload("res://ui/elements/options/dropdownoption.tscn").instance()
	get_node(SettingsNode + "LeftSettings").add_child(trackinghand)
	trackinghand.set_label("Tracking mode:")
	trackinghand.set_option_name("hand")
	
	var displayhands : Array = [
		{
			"name": "None (absolute position)",
			"value": 2
		},
		{
			"name": "Left hand",
			"value": 0
		},
		{
			"name": "Right hand",
			"value": 1
		}
	]
	
	trackinghand.set_values(displayhands)
	trackinghand.set_value(DefaultSettings.get_default_setting("overlay/hand"))
	trackinghand.set_widget_node(self)
	trackinghand.add_to_group("general_settings")
	trackinghand.set_optional_button(load("res://ui/theme/edit.png"), "Configure this tracking mode...")
	
	var worldmode = preload("res://ui/elements/options/dropdownoption.tscn").instance()
	get_node(SettingsNode + "LeftSettings").add_child(worldmode)
	worldmode.set_label("World mode:")
	worldmode.set_option_name("origin")
	
	var displaymodes : Array = [
		{
			"name": "Seated",
			"value": 0
		},
		{
			"name": "Standing",
			"value": 1
		}
	]
	
	worldmode.set_values(displaymodes)
	worldmode.set_value(DefaultSettings.get_default_setting("overlay/origin"))
	worldmode.set_widget_node(self)
	worldmode.add_to_group("absolute_mode")
	worldmode.add_to_group("general_settings")
	
	var backgroundcolor = preload("res://ui/elements/options/coloroption.tscn").instance()
	get_node(SettingsNode + "LeftSettings").add_child(backgroundcolor)
	backgroundcolor.set_label("Background color:")
	backgroundcolor.set_option_name("color")
	backgroundcolor.set_value(DefaultSettings.get_default_setting("overlay/color"))
	backgroundcolor.set_widget_node(self)
	backgroundcolor.add_to_group("general_settings")
	
	var backgroundopacity = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "LeftSettings").add_child(backgroundopacity)
	backgroundopacity.set_label("Background opacity:")
	backgroundopacity.set_slider_range(0, 1, 0.01)
	backgroundopacity.set_option_name("opacity")
	backgroundopacity.set_value(DefaultSettings.get_default_setting("overlay/opacity"))
	backgroundopacity.set_widget_node(self)
	backgroundopacity.add_to_group("general_settings")
	
	var undimchime = preload("res://ui/elements/options/toggleoption.tscn").instance()
	get_node(SettingsNode + "LeftSettings").add_child(undimchime)
	undimchime.set_label("Play chime on event:")
	undimchime.set_option_name("undimchime")
	undimchime.set_value(DefaultSettings.get_default_setting("overlay/undimchime"))
	undimchime.set_widget_node(self)
	undimchime.add_to_group("general_settings")

	var chimedevice = preload("res://ui/elements/options/dropdownoption.tscn").instance()
	get_node(SettingsNode + "LeftSettings").add_child(chimedevice)
	chimedevice.set_label("Play chime on output/device:")
	chimedevice.set_option_name("chimedevice")
	
	var displaydevices : Array
	
	for audiodevice in AudioServer.get_device_list():
		var displayDevice = {
			"name": audiodevice,
			"value": audiodevice
		}
		
		displaydevices.push_back(displayDevice)
	
	chimedevice.set_values(displaydevices)
	chimedevice.set_value(DefaultSettings.get_default_setting("overlay/chimedevice"))
	chimedevice.set_widget_node(self)
	chimedevice.add_to_group("general_settings")
	
	# Right side
	var overlaysize = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(overlaysize)
	overlaysize.set_label("Overlay size in meters:")
	overlaysize.set_slider_range(0.1, 5, 0.1)
	overlaysize.set_option_name("size")
	overlaysize.set_value(DefaultSettings.get_default_setting("overlay/size"))
	overlaysize.set_widget_node(self)
	overlaysize.add_to_group("general_settings")
		
	var position_x = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(position_x)
	position_x.set_label("Adjust position (left/right):")
	position_x.set_slider_range(-10, 10, 0.01)
	position_x.set_option_name("position_x")
	position_x.set_value(DefaultSettings.get_default_setting("overlay/position_x"))
	position_x.set_widget_node(self)
	position_x.add_to_group("absolute_mode")
	position_x.add_to_group("general_settings")
	
	var position_y = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(position_y)
	position_y.set_label("Adjust position (up/down):")
	position_y.set_slider_range(-10, 10, 0.01)
	position_y.set_option_name("position_y")
	position_y.set_value(DefaultSettings.get_default_setting("overlay/position_y"))
	position_y.set_widget_node(self)
	position_y.add_to_group("absolute_mode")
	position_y.add_to_group("general_settings")
	
	var position_z = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(position_z)
	position_z.set_label("Adjust position (far/near):")
	position_z.set_slider_range(-10, 10, 0.01)
	position_z.set_option_name("position_z")
	position_z.set_value(DefaultSettings.get_default_setting("overlay/position_z"))
	position_z.set_widget_node(self)
	position_z.add_to_group("absolute_mode")
	position_z.add_to_group("general_settings")
	
	var rotation_x = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(rotation_x)
	rotation_x.set_label("Adjust rotation (X):")
	rotation_x.set_slider_range(-15, 15, 0.1)
	rotation_x.set_option_name("rotation_x")
	rotation_x.set_value(DefaultSettings.get_default_setting("overlay/rotation_x"))
	rotation_x.set_widget_node(self)
	rotation_x.add_to_group("absolute_mode")
	rotation_x.add_to_group("general_settings")
		
	var rotation_y = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(rotation_y)
	rotation_y.set_label("Adjust rotation (Y):")
	rotation_y.set_slider_range(-15, 15, 0.1)
	rotation_y.set_option_name("rotation_y")
	rotation_y.set_value(DefaultSettings.get_default_setting("overlay/rotation_y"))
	rotation_y.set_widget_node(self)
	rotation_y.add_to_group("absolute_mode")
	rotation_y.add_to_group("general_settings")
	
	var rotation_z = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(rotation_z)
	rotation_z.set_label("Adjust rotation (Z):")
	rotation_z.set_slider_range(-15, 15, 0.1)
	rotation_z.set_option_name("rotation_z")
	rotation_z.set_value(DefaultSettings.get_default_setting("overlay/rotation_z"))
	rotation_z.set_widget_node(self)
	rotation_z.add_to_group("absolute_mode")
	rotation_z.add_to_group("general_settings")
	
	var position_z_hand = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(position_z_hand)
	position_z_hand.set_label("Adjust position (far/near):")
	position_z_hand.set_slider_range(-5, 0, 0.01)
	position_z_hand.set_option_name("position_z_hand")
	position_z_hand.set_value(DefaultSettings.get_default_setting("overlay/position_z_hand"))
	position_z_hand.set_widget_node(self)
	position_z_hand.add_to_group("hand_mode")
	position_z_hand.add_to_group("general_settings")

func set_active_overlay(overlay : Dictionary) -> void:
	current_overlay = overlay
	
	# Reset everything to default before loading current overlay's configuration
	for settings_node in get_tree().get_nodes_in_group("general_settings"):
		settings_node.set_value(DefaultSettings.get_default_setting("overlay/" + settings_node.get_option_name()))
	
	# Now laod the overlay's configuration
	for settings_node in get_tree().get_nodes_in_group("general_settings"):
		if settings_node.get_option_name() == "name":
			settings_node.set_value(current_overlay["name"])
			
		for option in current_overlay["config"]:
			if settings_node.get_option_name() == option:
				settings_node.set_value(current_overlay["config"][option])

	adjust_hand_mode_ui()

# Saves options from the widgets to the user settings file
func set_config_value(option, value):
	if option == "name":
		current_overlay["name"] = value
	else:
		current_overlay["config"][option] = value

	SignalManager.emit_signal("settings_changed", current_overlay)
	
	if option == "hand" or option == "origin":
		adjust_hand_mode_ui()

# Open the correct window for configuring the tracking mode
func call_optional_button():
	if current_overlay["config"].has("hand") and current_overlay["config"]["hand"] != 2:
		var trackingdialog = preload("res://ui/dialogs/handtrackingdialog.tscn").instance()
		add_child(trackingdialog)
		
		trackingdialog.set_settings_dialog(self)
		trackingdialog.set_active_overlay(current_overlay)
		trackingdialog.popup_centered()
	else:
		var trackingdialog = preload("res://ui/dialogs/absolutetrackingdialog.tscn").instance()
		add_child(trackingdialog)
		
		trackingdialog.set_settings_dialog(self)
		trackingdialog.set_active_overlay(current_overlay)
		trackingdialog.popup_centered()

func adjust_hand_mode_ui():
	if current_overlay["config"].has("hand") and current_overlay["config"]["hand"] != 2:
		for node in get_tree().get_nodes_in_group("absolute_mode"):
			node.visible = false
		for node in get_tree().get_nodes_in_group("hand_mode"):
			node.visible = true
	else:
		for node in get_tree().get_nodes_in_group("absolute_mode"):
			node.visible = true
		for node in get_tree().get_nodes_in_group("hand_mode"):
			node.visible = false
