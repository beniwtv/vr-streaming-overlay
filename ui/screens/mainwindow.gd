extends VBoxContainer

func _ready() -> void:
	SignalManager.connect("secrets_loaded", self, "_on_secrets_loaded")

# Display settings window once secret file has loaded
func _on_secrets_loaded() -> void:
	$LoginScreen.visible = false
	$SettingsScreen.visible = true
