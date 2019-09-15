extends WindowDialog

var settings_dialog : Node = null
var current_overlay : Dictionary

func set_settings_dialog(dialog : Node):
	settings_dialog = dialog

	var dimundim = preload("res://ui/elements/options/toggleoption.tscn").instance()
	$MarginContainer/VBoxContainer.add_child(dimundim)
	dimundim.set_label("Dim/undim on activity:")
	dimundim.set_option_name("dimundim")
	dimundim.set_value(DefaultSettings.get_default_setting("overlay/dimundim"))
	dimundim.set_widget_node(settings_dialog)
	dimundim.add_to_group("absolute_tracking_settings")

	var undimstare = preload("res://ui/elements/options/toggleoption.tscn").instance()
	$MarginContainer/VBoxContainer.add_child(undimstare)
	undimstare.set_label("Also undim on stare:")
	undimstare.set_option_name("undimstare")
	undimstare.set_value(DefaultSettings.get_default_setting("overlay/undimstare"))
	undimstare.set_widget_node(settings_dialog)
	undimstare.add_to_group("absolute_tracking_settings")
	
	var undimstareseconds = preload("res://ui/elements/options/numberoption.tscn").instance()
	$MarginContainer/VBoxContainer.add_child(undimstareseconds)
	undimstareseconds.set_label("Undim after (seconds) of staring:")
	undimstareseconds.set_spinbox_range(0, 180, 1)
	undimstareseconds.set_option_name("undimstareseconds")
	undimstareseconds.set_value(DefaultSettings.get_default_setting("overlay/undimstareseconds"))
	undimstareseconds.set_widget_node(settings_dialog)
	undimstareseconds.add_to_group("absolute_tracking_settings")

	var dimdownopacity = preload("res://ui/elements/options/slideroption.tscn").instance()
	$MarginContainer/VBoxContainer.add_child(dimdownopacity)
	dimdownopacity.set_label("Dim to opacity:")
	dimdownopacity.set_slider_range(0, 1, 0.01)
	dimdownopacity.set_option_name("dimdownopacity")
	dimdownopacity.set_value(DefaultSettings.get_default_setting("overlay/dimdownopacity"))
	dimdownopacity.set_widget_node(settings_dialog)
	dimdownopacity.add_to_group("absolute_tracking_settings")

	var dimdownafter = preload("res://ui/elements/options/numberoption.tscn").instance()
	$MarginContainer/VBoxContainer.add_child(dimdownafter)
	dimdownafter.set_label("Dim after (seconds):")
	dimdownafter.set_spinbox_range(0, 180, 1)
	dimdownafter.set_option_name("dimdownafter")
	dimdownafter.set_value(DefaultSettings.get_default_setting("overlay/dimdownafter"))
	dimdownafter.set_widget_node(settings_dialog)
	dimdownafter.add_to_group("absolute_tracking_settings")

func set_active_overlay(overlay : Dictionary) -> void:
	current_overlay = overlay
	
	# Now laod the overlay's configuration
	for settings_node in get_tree().get_nodes_in_group("absolute_tracking_settings"):
		for option in current_overlay["config"]:
			if settings_node.get_option_name() == option:
				settings_node.set_value(current_overlay["config"][option])
