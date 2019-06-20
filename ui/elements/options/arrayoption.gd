extends MarginContainer

export(String) var option_name
export(String) var label

export(NodePath) var widget_node

# Default functions implemented in every options element
func _ready() -> void:
	set_label(label)

func set_label(text : String) -> void:
	$BaseOption.set_label(text)

func set_option_name(name : String) -> void:
	option_name = name

func get_value() -> Array:
	return $BaseOption/HBoxContainer/ArrayContainer.get_items()

func set_value(value : Array) -> void:
	$BaseOption/HBoxContainer/ArrayContainer.add_items(value)

func set_widget_node(path : Node) -> void:
	widget_node = path

# Optional functions related to the specific control
func set_item_options(icon : StreamTexture, prefix : String) -> void:
	$BaseOption/HBoxContainer/ArrayContainer.icon = icon
	$BaseOption/HBoxContainer/ArrayContainer.prefix = prefix

func fire_changed(items) -> void:
	if widget_node:
		widget_node.set_config_value(option_name, items)
