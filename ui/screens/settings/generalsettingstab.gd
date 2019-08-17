extends Tabs

var SettingsNode = "MarginContainer/VBoxContainer/HBoxContainer/"

func _ready():
	# Left side
	var backgroundcolor = preload("res://ui/elements/options/coloroption.tscn").instance()
	get_node(SettingsNode + "LeftSettings").add_child(backgroundcolor)
	backgroundcolor.set_label("Background color:")
	backgroundcolor.set_option_name("overlay/color")
	backgroundcolor.set_value(SettingsManager.get_value("user", "overlay/color", DefaultSettings.get_default_setting("overlay/color")))
	backgroundcolor.set_widget_node(self)
	
	var backgroundopacity = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "LeftSettings").add_child(backgroundopacity)
	backgroundopacity.set_label("Background opacity:")
	backgroundopacity.set_slider_range(0, 1, 0.01)
	backgroundopacity.set_option_name("overlay/opacity")
	backgroundopacity.set_value(SettingsManager.get_value("user", "overlay/opacity", DefaultSettings.get_default_setting("overlay/opacity")))
	backgroundopacity.set_widget_node(self)
	
	var undimchime = preload("res://ui/elements/options/toggleoption.tscn").instance()
	get_node(SettingsNode + "LeftSettings").add_child(undimchime)
	undimchime.set_label("Play chime on event:")
	undimchime.set_option_name("overlay/undimchime")
	undimchime.set_value(SettingsManager.get_value("user", "overlay/undimchime", DefaultSettings.get_default_setting("overlay/undimchime")))
	undimchime.set_widget_node(self)

	var chimedevice = preload("res://ui/elements/options/dropdownoption.tscn").instance()
	get_node(SettingsNode + "LeftSettings").add_child(chimedevice)
	chimedevice.set_label("Play chime on output/device:")
	chimedevice.set_option_name("overlay/chimedevice")
	
	var displaydevices : Array
	
	for audiodevice in AudioServer.get_device_list():
		var displayDevice = {
			"name": audiodevice,
			"value": audiodevice
		}
		
		displaydevices.push_back(displayDevice)
	
	chimedevice.set_values(displaydevices)
	chimedevice.set_value(SettingsManager.get_value("user", "overlay/chimedevice", DefaultSettings.get_default_setting("overlay/chimedevice")))
	chimedevice.set_widget_node(self)
	
	# Right side
	var overlaysize = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(overlaysize)
	overlaysize.set_label("Overlay size in meters:")
	overlaysize.set_slider_range(0.1, 5, 0.1)
	overlaysize.set_option_name("overlay/size")
	overlaysize.set_value(SettingsManager.get_value("user", "overlay/size", DefaultSettings.get_default_setting("overlay/size")))
	overlaysize.set_widget_node(self)
		
	var position_x = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(position_x)
	position_x.set_label("Adjust position (left/right):")
	position_x.set_slider_range(-10, 10, 0.01)
	position_x.set_option_name("overlay/position_x")
	position_x.set_value(SettingsManager.get_value("user", "overlay/position_x", DefaultSettings.get_default_setting("overlay/position_x")))
	position_x.set_widget_node(self)
	position_x.add_to_group("absolute_mode")
	
	var position_y = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(position_y)
	position_y.set_label("Adjust position (up/down):")
	position_y.set_slider_range(-10, 10, 0.01)
	position_y.set_option_name("overlay/position_y")
	position_y.set_value(SettingsManager.get_value("user", "overlay/position_y", DefaultSettings.get_default_setting("overlay/position_y")))
	position_y.set_widget_node(self)
	position_y.add_to_group("absolute_mode")
	
	var position_z = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(position_z)
	position_z.set_label("Adjust position (far/near):")
	position_z.set_slider_range(-10, 10, 0.01)
	position_z.set_option_name("overlay/position_z")
	position_z.set_value(SettingsManager.get_value("user", "overlay/position_z", DefaultSettings.get_default_setting("overlay/position_z")))
	position_z.set_widget_node(self)
	position_z.add_to_group("absolute_mode")
	
	var rotation_x = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(rotation_x)
	rotation_x.set_label("Adjust rotation (X):")
	rotation_x.set_slider_range(-1, 1, 0.1)
	rotation_x.set_option_name("overlay/rotation_x")
	rotation_x.set_value(SettingsManager.get_value("user", "overlay/rotation_x", DefaultSettings.get_default_setting("overlay/rotation_x")))
	rotation_x.set_widget_node(self)
	rotation_x.add_to_group("absolute_mode")
	
	var rotation_y = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(rotation_y)
	rotation_y.set_label("Adjust rotation (Y):")
	rotation_y.set_slider_range(-1, 1, 0.1)
	rotation_y.set_option_name("overlay/rotation_y")
	rotation_y.set_value(SettingsManager.get_value("user", "overlay/rotation_y", DefaultSettings.get_default_setting("overlay/rotation_y")))
	rotation_y.set_widget_node(self)
	rotation_y.add_to_group("absolute_mode")
	
	var rotation_z = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(rotation_z)
	rotation_z.set_label("Adjust rotation (Z):")
	rotation_z.set_slider_range(0, 6.2, 0.1)
	rotation_z.set_option_name("overlay/rotation_z")
	rotation_z.set_value(SettingsManager.get_value("user", "overlay/rotation_z", DefaultSettings.get_default_setting("overlay/rotation_z")))
	rotation_z.set_widget_node(self)
	rotation_z.add_to_group("absolute_mode")
	
	var position_y_hand = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(position_y_hand)
	position_y_hand.set_label("Adjust position (left/right):")
	position_y_hand.set_slider_range(-10, 10, 0.01)
	position_y_hand.set_option_name("overlay/position_y_hand")
	position_y_hand.set_value(SettingsManager.get_value("user", "overlay/position_y_hand", DefaultSettings.get_default_setting("overlay/position_y_hand")))
	position_y_hand.set_widget_node(self)
	position_y_hand.add_to_group("hand_mode")
	
	var position_z_hand = preload("res://ui/elements/options/slideroption.tscn").instance()
	get_node(SettingsNode + "RightSettings").add_child(position_z_hand)
	position_z_hand.set_label("Adjust position (far/near):")
	position_z_hand.set_slider_range(-5, 0, 0.01)
	position_z_hand.set_option_name("overlay/position_z_hand")
	position_z_hand.set_value(SettingsManager.get_value("user", "overlay/position_z_hand", DefaultSettings.get_default_setting("overlay/position_z_hand")))
	position_z_hand.set_widget_node(self)
	position_z_hand.add_to_group("hand_mode")
	
	get_node(SettingsNode + "LeftSettings/TrackingOrigin/OptionButton").add_item('Seated', 0)
	get_node(SettingsNode + "LeftSettings/TrackingOrigin/OptionButton").add_item('Standing', 1)
		
	for i in range(0, get_node(SettingsNode + "LeftSettings/TrackingOrigin/OptionButton").get_item_count()):
		if SettingsManager.get_value("user", "overlay/origin", DefaultSettings.get_default_setting("overlay/origin")) == get_node(SettingsNode + "LeftSettings/TrackingOrigin/OptionButton").get_item_id(i): 
			get_node(SettingsNode + "LeftSettings/TrackingOrigin/OptionButton").select(i)	

	adjust_hand_mode_ui()

	SignalManager.connect("vr_init", self, "_on_vr_init")

func _on_vr_init(status):
	if status == "done":
		$"MarginContainer/VBoxContainer/StatusBox".text = "You can now put on your headset!"
	else:
		$"MarginContainer/VBoxContainer/StatusBox".text = "Could not initialize OpenVR -> check console output!"

func _on_handoption_item_selected(id):
	SettingsManager.set_value("user", "overlay/hand", get_node(SettingsNode + "LeftSettings/TrackingHand/OptionButton").get_selected_id())
	SignalManager.emit_signal("settings_changed")
	
	if get_node(SettingsNode + "LeftSettings/TrackingHand/OptionButton").get_selected_id() == 2:
		get_node(SettingsNode + "LeftSettings/TrackingOrigin").visible = true
	else:
		get_node(SettingsNode + "LeftSettings/TrackingOrigin").visible = false
		
	adjust_hand_mode_ui()

func _on_originoption_item_selected(id):
	SettingsManager.set_value("user", "overlay/origin", get_node(SettingsNode + "LeftSettings/TrackingOrigin/OptionButton").get_selected_id())
	SignalManager.emit_signal("settings_changed")

# Saves options from the widgets to the user settings file
func set_config_value(option, value):
	SettingsManager.set_value("user", option, value)
	SignalManager.emit_signal("settings_changed")

# Open the correct window for configuring the tracking mode
func _on_ConfigureTrackingButton_pressed():
	if SettingsManager.get_value("user", "overlay/hand", DefaultSettings.get_default_setting("overlay/hand")) == 2:
		var trackingdialog = preload("res://ui/dialogs/absolutetrackingdialog.tscn").instance()
		add_child(trackingdialog)
		
		trackingdialog.set_settings_dialog(self)
		trackingdialog.popup_centered()

func adjust_hand_mode_ui():
	if SettingsManager.get_value("user", "overlay/hand", DefaultSettings.get_default_setting("overlay/hand")) == 2:
		for node in get_tree().get_nodes_in_group("absolute_mode"):
			node.visible = true
		for node in get_tree().get_nodes_in_group("hand_mode"):
			node.visible = false
	else:
		for node in get_tree().get_nodes_in_group("absolute_mode"):
			node.visible = false
		for node in get_tree().get_nodes_in_group("hand_mode"):
			node.visible = true
