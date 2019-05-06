extends MarginContainer

export(String) var option_name
export(String) var label

export(NodePath) var widget_node

# Default functions implemented in every options element
func _ready():
	set_label(label)

	$BaseOption/HBoxContainer/SpinBox.connect("value_changed", self, "_on_SpinBox_value_changed")

func set_label(text):
	$BaseOption.set_label(text)

func set_option_name(name):	
	option_name = name

func get_value():
	return $BaseOption/HBoxContainer/SpinBox.value

func set_value(value):
	$BaseOption/HBoxContainer/SpinBox.value = value

func set_widget_node(path):
	widget_node = path

# Optional functions related to the specific control
func set_spinbox_range(min_value, max_value, step):
	$BaseOption/HBoxContainer/SpinBox.min_value = min_value
	$BaseOption/HBoxContainer/SpinBox.max_value = max_value
	$BaseOption/HBoxContainer/SpinBox.step = step

func _on_SpinBox_value_changed(value):
	if widget_node:
		widget_node.set_config_value(option_name, value)
