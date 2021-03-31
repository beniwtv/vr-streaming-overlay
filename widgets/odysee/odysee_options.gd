extends MarginContainer

var config = null
var receiver : Node = null

func add_config_options(widget_id : String, config : Dictionary) -> void:
	self.config = config
	
	var claim_id_value = "Place Stream Claim Id Here"
	if config.has("claim_id"): claim_id_value = config["claim_id"]

	var text_color_value = "#FFFFFF"
	if config.has("text_color"): text_color_value = config["text_color"]
	
	var username_color_value = "#FFFFFF"
	if config.has("username_color"): username_color_value = config["username_color"]

	var timestamp_color_value = "#FFFFFF"
	if config.has("timestamp_color"): timestamp_color_value = config["timestamp_color"]

	var compact_mode_value = false
	if config.has("compact_mode"): compact_mode_value = config["compact_mode"]

	var show_timestamps_value = false
	if config.has("show_timestamps"): show_timestamps_value = config["show_timestamps"]

	var font_select_value = DefaultSettings.get_default_setting("widgets/font")
	if config.has("font"): font_select_value = config["font"]
	
	var items = []
	
	var claim_id = preload("res://ui/elements/options/lineeditoption.tscn").instance()
	$VBoxContainer.add_child(claim_id)
	claim_id.set_label("stream claim id:")
	claim_id.set_option_name("claim_id")
	claim_id.set_value(claim_id_value)
	claim_id.set_widget_node(self)
	
	var text_color = preload("res://ui/elements/options/coloroption.tscn").instance()
	$VBoxContainer.add_child(text_color)
	text_color.set_label("Text color:")
	text_color.set_option_name("text_color")
	text_color.set_value(text_color_value)
	text_color.set_widget_node(self)
	
	var username_color = preload("res://ui/elements/options/coloroption.tscn").instance()
	$VBoxContainer.add_child(username_color)
	username_color.set_label("Username color:")
	username_color.set_option_name("username_color")
	username_color.set_value(username_color_value)
	username_color.set_widget_node(self)
	
	var timestamp_color = preload("res://ui/elements/options/coloroption.tscn").instance()
	$VBoxContainer.add_child(timestamp_color)
	timestamp_color.set_label("Timestamp color:")
	timestamp_color.set_option_name("timestamp_color")
	timestamp_color.set_value(timestamp_color_value)
	timestamp_color.set_widget_node(self)
	
	var compact_mode = preload("res://ui/elements/options/toggleoption.tscn").instance()
	$VBoxContainer.add_child(compact_mode)
	compact_mode.set_label("Compact view:")
	compact_mode.set_option_name("compact_mode")
	compact_mode.set_value(compact_mode_value)
	compact_mode.set_widget_node(self)
	
	var show_timestamps = preload("res://ui/elements/options/toggleoption.tscn").instance()
	$VBoxContainer.add_child(show_timestamps)
	show_timestamps.set_label("Show timestamps:")
	show_timestamps.set_option_name("show_timestamps")
	show_timestamps.set_value(show_timestamps_value)
	show_timestamps.set_widget_node(self)

	var font_select = preload("res://ui/elements/options/fontoption.tscn").instance()
	$VBoxContainer.add_child(font_select)
	font_select.set_label("Font:")
	font_select.set_option_name("font")
	font_select.set_value(font_select_value)
	font_select.set_widget_node(self)

func set_receiver_node(receiver : Node) -> void:
	self.receiver = receiver

func set_config_value(key : String, value) -> void:
	config[key] = value
	
	if receiver:
		receiver.save_options_for_widget()
