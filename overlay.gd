extends Control

func _ready():
	# Find the OpenVR interface and initialise it
	var arvr_interface = ARVRServer.find_interface("OpenVR")
	
	if arvr_interface and arvr_interface.initialize():
		# Make sure we run at 90 FPS for this
		OS.vsync_enabled = false
		Engine.target_fps = 90
	
	SignalManager.connect("settings_changed", self, "_on_settings_changed")
	
	$VRViewport/VRBackground.color = SettingsManager.get_value("user", "overlay/color", Color(0, 0, 0))
	$VRViewport/VRBackground.modulate.a = SettingsManager.get_value("user", "overlay/opacity", 0.8)
	
func _process(delta):
	# Test for escape to close application, space to reset our reference frame
	if (Input.is_key_pressed(KEY_ESCAPE)):
		get_tree().quit()
	elif (Input.is_key_pressed(KEY_SPACE)):
		# Calling center_on_hmd will cause the ARVRServer to adjust all tracking data so the player is centered on the origin point looking forward
		ARVRServer.center_on_hmd(true, true)

func _on_settings_changed():
	$VRViewport/VRBackground.color = SettingsManager.get_value("user", "overlay/color", Color(0, 0, 0))
	$VRViewport/VRBackground.modulate.a = SettingsManager.get_value("user", "overlay/opacity", 0.8)