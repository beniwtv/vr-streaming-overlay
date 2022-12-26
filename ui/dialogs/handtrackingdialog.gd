extends WindowDialog

var settings_dialog : Node = null
var current_overlay : Dictionary

func set_settings_dialog(dialog : Node):
	settings_dialog = dialog

	var showseconds = preload("res://ui/elements/options/numberoption.tscn").instance()
	$MarginContainer/VBoxContainer.add_child(showseconds)
	showseconds.set_label("Delay showing for (seconds):")
	showseconds.set_spinbox_range(0, 5, 0.1)
	showseconds.set_option_name("showseconds")
	showseconds.set_value(DefaultSettings.get_default_setting("overlay/showseconds"))
	showseconds.set_widget_node(settings_dialog)
	showseconds.add_to_group("hand_tracking_settings")

	var showangle = preload("res://ui/elements/options/numberoption.tscn").instance()
	$MarginContainer/VBoxContainer.add_child(showangle)
	showangle.set_label("Angle to HMD for showing (degrees):")
	showangle.set_spinbox_range(0, 360, 1)
	showangle.set_option_name("showangle")
	showangle.set_value(DefaultSettings.get_default_setting("overlay/showangle"))
	showangle.set_widget_node(settings_dialog)
	showangle.add_to_group("hand_tracking_settings")

func set_active_overlay(overlay : Dictionary) -> void:
	current_overlay = overlay
	
	# Now laod the overlay's configuration
	for settings_node in get_tree().get_nodes_in_group("hand_tracking_settings"):
		for option in current_overlay["config"]:
			if settings_node.get_option_name() == option:
				settings_node.set_value(current_overlay["config"][option])
