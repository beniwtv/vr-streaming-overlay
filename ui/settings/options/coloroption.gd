extends MarginContainer

var option_name

func _ready():
	pass # Replace with function body.

func set_label(text):
	$BaseOption.set_label(text)
	
func set_option_name(name, default):	
	$BaseOption/HBoxContainer/ColorPickerButton.color = SettingsManager.get_value("user", name, default)
	option_name = name

func _on_ColorPickerButton_color_changed(color):
	SettingsManager.set_value("user", option_name, color)
	SignalManager.emit_signal("settings_changed")
