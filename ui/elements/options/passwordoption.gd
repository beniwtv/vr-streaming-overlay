extends MarginContainer

export(String) var option_name
export(String) var label

export(NodePath) var widget_node
export(NodePath) var enter_listener

# Default functions implemented in every options element
func _ready() -> void:
	set_label(label)

	$BaseOption/HBoxContainer/LineEdit.connect("text_changed", self, "_on_LineEdit_text_changed")
	$BaseOption/HBoxContainer/LineEdit.connect("text_entered", self, "_on_LineEdit_text_entered")

func set_label(text : String) -> void:
	$BaseOption.set_label(text)

func get_option_name() -> String:
	return option_name

func set_option_name(name : String) -> void:
	option_name = name

func get_value() -> String:
	return $BaseOption/HBoxContainer/LineEdit.text

func set_value(value : String) -> void:
	$BaseOption/HBoxContainer/LineEdit.text = value

func set_widget_node(path : Node) -> void:
	widget_node = path

func set_enter_listener(path : Node) -> void:
	enter_listener = path

# Optional functions related to the specific control
func _on_LineEdit_text_changed(new_text: String) -> void:
	if widget_node:
		widget_node.set_config_value(option_name, new_text)

func _on_LineEdit_text_entered(new_text: String) -> void:
	if enter_listener:
		enter_listener.text_entered(option_name, new_text)
