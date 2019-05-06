extends VBoxContainer

var widget_id = null
var config = null

func add_config_options(widget_id, config):
	self.config = config
	
	var margin_top_value = DefaultSettings.get_default_setting("margin_container/margin_top")
	if config.has("margin_top"): margin_top_value = config["margin_top"]

	var margin_left_value = DefaultSettings.get_default_setting("margin_container/margin_left")
	if config.has("margin_left"): margin_left_value = config["margin_left"]

	var margin_right_value = DefaultSettings.get_default_setting("margin_container/margin_right")
	if config.has("margin_right"): margin_right_value = config["margin_right"]

	var margin_bottom_value = DefaultSettings.get_default_setting("margin_container/margin_bottom")
	if config.has("margin_bottom"): margin_bottom_value = config["margin_bottom"]
	
	var margin_top = preload("res://ui/elements/options/numberoption.tscn").instance()
	add_child(margin_top)
	margin_top.set_label("Top margin:")
	margin_top.set_spinbox_range(-100, 100, 1)
	margin_top.set_option_name("margin_top")
	margin_top.set_value(margin_top_value)
	margin_top.set_widget_node(self)
	
	var margin_left = preload("res://ui/elements/options/numberoption.tscn").instance()
	add_child(margin_left)
	margin_left.set_label("Left margin:")
	margin_left.set_spinbox_range(-100, 100, 1)
	margin_left.set_option_name("margin_left")
	margin_left.set_value(margin_left_value)
	margin_left.set_widget_node(self)
	
	var margin_right = preload("res://ui/elements/options/numberoption.tscn").instance()
	add_child(margin_right)
	margin_right.set_label("Right margin:")
	margin_right.set_spinbox_range(-100, 100, 1)
	margin_right.set_option_name("margin_right")
	margin_right.set_value(margin_right_value)
	margin_right.set_widget_node(self)
	
	var margin_bottom = preload("res://ui/elements/options/numberoption.tscn").instance()
	add_child(margin_bottom)
	margin_bottom.set_label("Bottom margin:")
	margin_bottom.set_spinbox_range(-100, 100, 1)
	margin_bottom.set_option_name("margin_bottom")
	margin_bottom.set_value(margin_bottom_value)
	margin_bottom.set_widget_node(self)

func set_config_value(key, value):
	config[key] = value
	SignalManager.emit_signal("options_changed")
