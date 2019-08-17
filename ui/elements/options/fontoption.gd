extends MarginContainer

export(String) var option_name
export(String) var label

export(NodePath) var widget_node

var currentfont : Dictionary

# Default functions implemented in every options element
func _ready() -> void:
	set_label(label)

func set_label(text : String) -> void:
	$BaseOption.set_label(text)

func set_option_name(name : String) -> void:
	option_name = name

func get_value() -> Dictionary:
	return currentfont

func set_value(value : Dictionary) -> void:
	$BaseOption/HBoxContainer/HBoxContainer/FontStatusLabel.text = value.name + ", " + str(value.size) + " px"
	currentfont = value

func set_widget_node(path : Node) -> void:
	widget_node = path

# Optional functions related to the specific control
func handle_result(result : Dictionary) -> void:
	currentfont = result
	$BaseOption/HBoxContainer/HBoxContainer/FontStatusLabel.text = result.name + ", " + str(result.size) + " px"

	if widget_node:
		widget_node.set_config_value(option_name, result)

func _on_FontSelectButton_pressed():
	var selectfiledialog = preload("res://ui/dialogs/selectfontdialog.tscn").instance()
	add_child(selectfiledialog)
			
	if currentfont:
		selectfiledialog.edit_font(currentfont)

	selectfiledialog.set_result_dialog(self)
	selectfiledialog.popup_centered()
