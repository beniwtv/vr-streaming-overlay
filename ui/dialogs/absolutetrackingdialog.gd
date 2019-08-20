extends WindowDialog

var settings_dialog : Node = null

func set_settings_dialog(dialog : Node):
	settings_dialog = dialog

	var dimundim = preload("res://ui/elements/options/toggleoption.tscn").instance()
	$MarginContainer/VBoxContainer.add_child(dimundim)
	dimundim.set_label("Dim/undim on activity:")
	dimundim.set_option_name("overlay/dimundim")
	dimundim.set_value(SettingsManager.get_value("user", "overlay/dimundim", DefaultSettings.get_default_setting("overlay/dimundim")))
	dimundim.set_widget_node(settings_dialog)

	var undimstare = preload("res://ui/elements/options/toggleoption.tscn").instance()
	$MarginContainer/VBoxContainer.add_child(undimstare)
	undimstare.set_label("Also undim on stare:")
	undimstare.set_option_name("overlay/undimstare")
	undimstare.set_value(SettingsManager.get_value("user", "overlay/undimstare", DefaultSettings.get_default_setting("overlay/undimstare")))
	undimstare.set_widget_node(settings_dialog)
	
	var undimstareseconds = preload("res://ui/elements/options/numberoption.tscn").instance()
	$MarginContainer/VBoxContainer.add_child(undimstareseconds)
	undimstareseconds.set_label("Undim after (seconds) of staring:")
	undimstareseconds.set_spinbox_range(0, 180, 1)
	undimstareseconds.set_option_name("overlay/undimstareseconds")
	undimstareseconds.set_value(SettingsManager.get_value("user", "overlay/undimstareseconds", DefaultSettings.get_default_setting("overlay/undimstareseconds")))
	undimstareseconds.set_widget_node(settings_dialog)

	var dimdownopacity = preload("res://ui/elements/options/slideroption.tscn").instance()
	$MarginContainer/VBoxContainer.add_child(dimdownopacity)
	dimdownopacity.set_label("Dim to opacity:")
	dimdownopacity.set_slider_range(0, 1, 0.01)
	dimdownopacity.set_option_name("overlay/dimdownopacity")
	dimdownopacity.set_value(SettingsManager.get_value("user", "overlay/dimdownopacity", DefaultSettings.get_default_setting("overlay/dimdownopacity")))
	dimdownopacity.set_widget_node(settings_dialog)

	var dimdownafter = preload("res://ui/elements/options/numberoption.tscn").instance()
	$MarginContainer/VBoxContainer.add_child(dimdownafter)
	dimdownafter.set_label("Dim after (seconds):")
	dimdownafter.set_spinbox_range(0, 180, 1)
	dimdownafter.set_option_name("overlay/dimdownafter")
	dimdownafter.set_value(SettingsManager.get_value("user", "overlay/dimdownafter", DefaultSettings.get_default_setting("overlay/dimdownafter")))
	dimdownafter.set_widget_node(settings_dialog)
