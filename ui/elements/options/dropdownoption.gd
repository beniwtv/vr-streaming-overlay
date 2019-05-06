extends MarginContainer

export(String) var option_name
export(String) var label

export(NodePath) var widget_node

# Default functions implemented in every options element
func _ready():
	$BaseOption/HBoxContainer/OptionButton.add_item("-- Please select --", 0)
	set_label(label)

	$BaseOption/HBoxContainer/OptionButton.connect("item_selected", self, "_on_OptionButton_item_selected")

func set_label(text):
	$BaseOption.set_label(text)

func set_option_name(name):	
	option_name = name

func get_value():
	var idx = $BaseOption/HBoxContainer/OptionButton.get_selected_item()
	return $BaseOption/HBoxContainer/OptionButton.get_item_metadata(idx)

func set_value(value):
	for i in range(0, $BaseOption/HBoxContainer/OptionButton.get_item_count()):
		if($BaseOption/HBoxContainer/OptionButton.get_item_metadata(i) == value):
			$BaseOption/HBoxContainer/OptionButton.select(i)

func set_widget_node(path):
	widget_node = path

# Optional functions related to the specific control
func set_values(values):
	for i in values:
		$BaseOption/HBoxContainer/OptionButton.add_item(i["name"])
		$BaseOption/HBoxContainer/OptionButton.set_item_metadata($BaseOption/HBoxContainer/OptionButton.get_item_count() - 1, i["value"])

func _on_OptionButton_item_selected(idx):
	if widget_node:
		widget_node.set_config_value(option_name, $BaseOption/HBoxContainer/OptionButton.get_item_metadata(idx))
