extends MarginContainer

export(String) var option_name
export(String) var label

export(NodePath) var widget_node

# Default functions implemented in every options element
func _ready():
	set_label(label)

	$BaseOption/HBoxContainer/LineEdit.connect("text_changed", self, "_on_LineEdit_text_changed")

func set_label(text):
	$BaseOption.set_label(text)

func set_option_name(name):	
	option_name = name

func get_value():
	return $BaseOption/HBoxContainer/LineEdit.text

func set_value(value):
	$BaseOption/HBoxContainer/LineEdit.text = value

func set_widget_node(path):
	widget_node = path

# Optional functions related to the specific control
func _on_LineEdit_text_changed(new_text):
	if widget_node:
		widget_node.set_config_value(option_name, new_text)
