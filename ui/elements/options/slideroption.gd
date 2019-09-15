extends MarginContainer

export(String) var option_name
export(String) var label

export(NodePath) var widget_node

# Default functions implemented in every options element
func _ready() -> void:
	set_label(label)

	$BaseOption/HBoxContainer/HBoxContainer/HSlider.connect("value_changed", self, "_on_HSlider_value_changed")

func set_label(text : String) -> void:
	$BaseOption.set_label(text)

func get_option_name() -> String:
	return option_name

func set_option_name(name : String) -> void:
	option_name = name

func get_value() -> float:
	return $BaseOption/HBoxContainer/HBoxContainer/HSlider.value

func set_value(value : float) -> void:
	$BaseOption/HBoxContainer/HBoxContainer/HSlider.disconnect("value_changed", self, "_on_HSlider_value_changed")
	
	$BaseOption/HBoxContainer/HBoxContainer/HSlider.value = value
	$BaseOption/HBoxContainer/HBoxContainer/ValueDisplay.text = str(value)
	
	$BaseOption/HBoxContainer/HBoxContainer/HSlider.connect("value_changed", self, "_on_HSlider_value_changed")
	
func set_widget_node(path : Node) -> void:
	widget_node = path

# Optional functions related to the specific control
func set_slider_range(min_value : float, max_value : float, step : float) -> void:
	$BaseOption/HBoxContainer/HBoxContainer/HSlider.min_value = min_value
	$BaseOption/HBoxContainer/HBoxContainer/HSlider.max_value = max_value
	$BaseOption/HBoxContainer/HBoxContainer/HSlider.step = step

func _on_HSlider_value_changed(value : float):
	$BaseOption/HBoxContainer/HBoxContainer/ValueDisplay.text = str(value)

	if widget_node:
		widget_node.set_config_value(option_name, value)
