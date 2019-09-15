extends MarginContainer

export(String) var option_name
export(String) var label

export(NodePath) var widget_node

# Default functions implemented in every options element
func _ready() -> void:
	set_label(label)

	$BaseOption/HBoxContainer/SpinBox.connect("value_changed", self, "_on_SpinBox_value_changed")

func set_label(text : String) -> void:
	$BaseOption.set_label(text)

func get_option_name() -> String:
	return option_name

func set_option_name(name : String) -> void:
	option_name = name

func get_value() -> float:
	return $BaseOption/HBoxContainer/SpinBox.value

func set_value(value : float) -> void:
	$BaseOption/HBoxContainer/SpinBox.value = value

func set_widget_node(path : Node) -> void:
	widget_node = path

# Optional functions related to the specific control
func set_spinbox_range(min_value : int, max_value : int, step : float) -> void:
	$BaseOption/HBoxContainer/SpinBox.min_value = min_value
	$BaseOption/HBoxContainer/SpinBox.max_value = max_value
	$BaseOption/HBoxContainer/SpinBox.step = step

func _on_SpinBox_value_changed(value : float) -> void:
	if widget_node:
		widget_node.set_config_value(option_name, value)
