extends Control

var OpenVRConfig
var OpenVROverlay
var target_size = Vector2()

func _ready():
	# Get configuration object
	OpenVRConfig = preload("res://addons/godot-openvr/OpenVRConfig.gdns").new()
	OpenVRConfig.set_application_type(1) # Set to OVERLAY MODE = 2, NORMAL MODE = 1
	
	# Find the OpenVR interface and initialise it
	var arvr_interface = ARVRServer.find_interface("OpenVR")
	
	if arvr_interface and arvr_interface.initialize():
		# Make sure we run at 90 FPS for this
		OS.vsync_enabled = false
		Engine.target_fps = 90
		
		# Set our resolution for the 2D scene
		target_size = arvr_interface.get_render_targetsize()
		$VRViewport.size = target_size
		$VRViewport/VRBackground.rect_size = target_size
		
		SignalManager.emit_signal("render_targetsize", target_size)
		
		# Create and display our overlay
		OpenVROverlay = preload("res://addons/godot-openvr/OpenVROverlay.gdns").new()
		OpenVROverlay.create_overlay("beniwtv.vr-streaming.overlay","VR Streaming Overlay") # Unique key and friendly name
		OpenVROverlay.set_overlay_width_in_meters(SettingsManager.get_value("user", "overlay/size", 1.5))

		OpenVROverlay.show_overlay()
	
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
	OpenVROverlay.set_overlay_width_in_meters(SettingsManager.get_value("user", "overlay/size", 1.5))
