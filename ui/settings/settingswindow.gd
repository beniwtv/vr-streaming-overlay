extends VBoxContainer

func _ready():
	# Left side
	var backgroundcolor = preload("res://ui/settings/options/coloroption.tscn").instance()
	$"TabContainer/General settings/MarginContainer/HBoxContainer/LeftSettings".add_child(backgroundcolor)
	backgroundcolor.set_label("Background color:")
	backgroundcolor.set_option_name("overlay/color", Color(0, 0, 0))
		
	var backgroundopacity = preload("res://ui/settings/options/slideroption.tscn").instance()
	$"TabContainer/General settings/MarginContainer/HBoxContainer/LeftSettings".add_child(backgroundopacity)
	backgroundopacity.set_label("Background opacity:")
	backgroundopacity.set_slider_range(0, 1, 0.01)
	backgroundopacity.set_option_name("overlay/opacity", 0.8)
	
	var overlaysize = preload("res://ui/settings/options/slideroption.tscn").instance()
	$"TabContainer/General settings/MarginContainer/HBoxContainer/LeftSettings".add_child(overlaysize)
	overlaysize.set_label("Overlay size in meters:")
	overlaysize.set_slider_range(0.1, 5, 0.1)
	overlaysize.set_option_name("overlay/size", 1.5)
	
	# Right side
	var position_x = preload("res://ui/settings/options/slideroption.tscn").instance()
	$"TabContainer/General settings/MarginContainer/HBoxContainer/RightSettings".add_child(position_x)
	position_x.set_label("Adjust position (left/right):")
	position_x.set_slider_range(-10, 10, 0.01)
	position_x.set_option_name("overlay/position_x", 0)
	
	var position_y = preload("res://ui/settings/options/slideroption.tscn").instance()
	$"TabContainer/General settings/MarginContainer/HBoxContainer/RightSettings".add_child(position_y)
	position_y.set_label("Adjust position (up/down):")
	position_y.set_slider_range(-10, 10, 0.01)
	position_y.set_option_name("overlay/position_y", 0)
	
	var position_z = preload("res://ui/settings/options/slideroption.tscn").instance()
	$"TabContainer/General settings/MarginContainer/HBoxContainer/RightSettings".add_child(position_z)
	position_z.set_label("Adjust position (far/near):")
	position_z.set_slider_range(-10, 10, 0.01)
	position_z.set_option_name("overlay/position_z", -1.4)

	var rotation_x = preload("res://ui/settings/options/slideroption.tscn").instance()
	$"TabContainer/General settings/MarginContainer/HBoxContainer/RightSettings".add_child(rotation_x)
	rotation_x.set_label("Adjust rotation (X):")
	rotation_x.set_slider_range(-2, 2, 0.1)
	rotation_x.set_option_name("overlay/rotation_x", 0)
	
	var rotation_y = preload("res://ui/settings/options/slideroption.tscn").instance()
	$"TabContainer/General settings/MarginContainer/HBoxContainer/RightSettings".add_child(rotation_y)
	rotation_y.set_label("Adjust rotation (Y):")
	rotation_y.set_slider_range(-2, 2, 0.1)
	rotation_y.set_option_name("overlay/rotation_y", 0)
	
	var rotation_z = preload("res://ui/settings/options/slideroption.tscn").instance()
	$"TabContainer/General settings/MarginContainer/HBoxContainer/RightSettings".add_child(rotation_z)
	rotation_z.set_label("Adjust rotation (Z):")
	rotation_z.set_slider_range(-2, 2, 0.1)
	rotation_z.set_option_name("overlay/rotation_z", -1.4)
	
	# TEMP STUFF - remove later
	$"TabContainer/General settings/MarginContainer/HBoxContainer/LeftSettings/TwitchNick/LineEdit".text = SettingsManager.get_value("user", "twitchchat/nick", "")

func _on_handoption_item_selected(id):
	SettingsManager.set_value("user", "overlay/hand", id)
	SignalManager.emit_signal("settings_changed")

# TEMP STUFF - remove later
func _on_LineEdit_text_changed(new_text):
	SignalManager.emit_signal("oauth_changed", new_text)

func _on_LineEdit2_text_changed(new_text):
	SettingsManager.set_value("user", "twitchchat/nick", new_text)
	SignalManager.emit_signal("settings_changed")
