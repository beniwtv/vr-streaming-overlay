extends VBoxContainer

func _ready():
	$"TabContainer/General settings/MarginContainer/HBoxContainer/LeftSettings/BackgroundColor/ColorPickerButton".color = SettingsManager.get_value("user", "overlay/color", Color(0, 0, 0))
	$"TabContainer/General settings/MarginContainer/HBoxContainer/LeftSettings/BackgroundOpacity/HSlider".value = SettingsManager.get_value("user", "overlay/opacity", 0.8)
	$"TabContainer/General settings/MarginContainer/HBoxContainer/LeftSettings/OverlaySize/HSlider".value = SettingsManager.get_value("user", "overlay/size", 1.5)	
	
	# TODO
	$"TabContainer/General settings/MarginContainer/HBoxContainer/LeftSettings/TwitchNick/LineEdit".text = SettingsManager.get_value("user", "twitchchat/nick", "")
	
	SignalManager.emit_signal("settings_changed")

func _on_ColorPickerButton_color_changed(color):
	SettingsManager.set_value("user", "overlay/color", color)
	SignalManager.emit_signal("settings_changed")

func _on_HSlider_value_changed(value):
	SettingsManager.set_value("user", "overlay/opacity", value)
	SignalManager.emit_signal("settings_changed")

func _on_OverlaySizeHSlider_value_changed(value):
	SettingsManager.set_value("user", "overlay/size", value)
	SignalManager.emit_signal("settings_changed")

func _on_LineEdit_text_changed(new_text):
	SignalManager.emit_signal("oauth_changed", new_text)

func _on_LineEdit2_text_changed(new_text):
	SettingsManager.set_value("user", "twitchchat/nick", new_text)
	SignalManager.emit_signal("settings_changed")