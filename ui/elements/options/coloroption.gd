extends MarginContainer

export(String) var option_name
export(String) var label

export(NodePath) var widget_node

# Default functions implemented in every options element
func _ready() -> void:
	set_label(label)

	$BaseOption/HBoxContainer/ColorPickerButton.connect("color_changed", self, "_on_ColorPickerButton_color_changed")

func set_label(text : String) -> void:
	$BaseOption.set_label(text)

func set_option_name(name : String) -> void:
	option_name = name

func get_value() -> Color:
	return $BaseOption/HBoxContainer/ColorPickerButton.color

func set_value(value : Color) -> void:
	$BaseOption/HBoxContainer/ColorPickerButton.color = value

func set_widget_node(path : Node) -> void:
	widget_node = path

# Optional functions related to the specific control
func _on_ColorPickerButton_color_changed(color : Color) -> void:
	if widget_node:
		widget_node.set_config_value(option_name, color)
