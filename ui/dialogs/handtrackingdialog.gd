extends WindowDialog

var settings_dialog : Node = null

func set_settings_dialog(dialog : Node):
	settings_dialog = dialog

	var showseconds = preload("res://ui/elements/options/numberoption.tscn").instance()
	$MarginContainer/VBoxContainer.add_child(showseconds)
	showseconds.set_label("Delay showing for (seconds):")
	showseconds.set_spinbox_range(0, 5, 0.1)
	showseconds.set_option_name("overlay/showseconds")
	showseconds.set_value(SettingsManager.get_value("user", "overlay/showseconds", DefaultSettings.get_default_setting("overlay/showseconds")))
	showseconds.set_widget_node(settings_dialog)

	var minangle = preload("res://ui/elements/options/numberoption.tscn").instance()
	$MarginContainer/VBoxContainer.add_child(minangle)
	minangle.set_label("Minimum angle required (degrees):")
	minangle.set_spinbox_range(0, 360, 1)
	minangle.set_option_name("overlay/minangle")
	minangle.set_value(SettingsManager.get_value("user", "overlay/minangle", DefaultSettings.get_default_setting("overlay/minangle")))
	minangle.set_widget_node(settings_dialog)
