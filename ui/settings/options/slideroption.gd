extends MarginContainer

var option_name

func _ready():
	pass # Replace with function body.

func set_label(text):
	$BaseOption.set_label(text)
	
func set_option_name(name, default):	
	$BaseOption/HBoxContainer/HBoxContainer/HSlider.value = SettingsManager.get_value("user", name, default)
	option_name = name

func set_slider_range(min_value, max_value, step):
	$BaseOption/HBoxContainer/HBoxContainer/HSlider.min_value = min_value
	$BaseOption/HBoxContainer/HBoxContainer/HSlider.max_value = max_value
	$BaseOption/HBoxContainer/HBoxContainer/HSlider.step = step

func _on_HSlider_value_changed(value):
	$BaseOption/HBoxContainer/HBoxContainer/ValueDisplay.text = str(value)
	
	if option_name:
		SettingsManager.set_value("user", option_name, value)
		SignalManager.emit_signal("settings_changed")		
