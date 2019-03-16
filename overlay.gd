extends Control

var OpenVRConfig
var OpenVROverlay
var target_size = Vector2()

func _ready():
	# Get configuration object
	OpenVRConfig = preload("res://addons/godot-openvr/OpenVRConfig.gdns").new()
	OpenVRConfig.set_application_type(2) # Set to OVERLAY MODE = 2, NORMAL MODE = 1
	
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
		
		# Listen for trackers becoming available / going away
		ARVRServer.connect("tracker_added", self, "_on_trackers_changed")
		ARVRServer.connect("tracker_removed", self, "_on_trackers_changed")

		$"SettingsWindow/TabContainer/General settings/MarginContainer/VBoxContainer/HBoxContainer/LeftSettings/TrackingHand/OptionButton".add_item('None (absolute position)', 2)
		$"SettingsWindow/TabContainer/General settings/MarginContainer/VBoxContainer/HBoxContainer/LeftSettings/TrackingHand/OptionButton".add_item('Left hand', 0)
		$"SettingsWindow/TabContainer/General settings/MarginContainer/VBoxContainer/HBoxContainer/LeftSettings/TrackingHand/OptionButton".add_item('Right hand', 1)
		
		for i in range(0, $"SettingsWindow/TabContainer/General settings/MarginContainer/VBoxContainer/HBoxContainer/LeftSettings/TrackingHand/OptionButton".get_item_count()):
			if SettingsManager.get_value("user", "overlay/hand", 2) == $"SettingsWindow/TabContainer/General settings/MarginContainer/VBoxContainer/HBoxContainer/LeftSettings/TrackingHand/OptionButton".get_item_id(i): 
				$"SettingsWindow/TabContainer/General settings/MarginContainer/VBoxContainer/HBoxContainer/LeftSettings/TrackingHand/OptionButton".select(i)
			
		if SettingsManager.get_value("user", "overlay/hand", 2) == 2:
			$"SettingsWindow/TabContainer/General settings/MarginContainer/VBoxContainer/HBoxContainer/LeftSettings/TrackingOrigin".visible = true
		else:
			$"SettingsWindow/TabContainer/General settings/MarginContainer/VBoxContainer/HBoxContainer/LeftSettings/TrackingOrigin".visible = false
		
		attempt_tracking()
			
	SignalManager.connect("settings_changed", self, "_on_settings_changed")
	
	$VRViewport/VRBackground.color = SettingsManager.get_value("user", "overlay/color", Color(0, 0, 0))
	$VRViewport/VRBackground.modulate.a = SettingsManager.get_value("user", "overlay/opacity", 0.8)
	
func _process(delta):
	if Input.is_action_just_pressed("center_on_hmd"):
		# Calling center_on_hmd will cause the ARVRServer to adjust all tracking data so the player is centered on the origin point looking forward
		ARVRServer.center_on_hmd(true, false)

func _on_settings_changed():
	$VRViewport/VRBackground.color = SettingsManager.get_value("user", "overlay/color", Color(0, 0, 0))
	$VRViewport/VRBackground.modulate.a = SettingsManager.get_value("user", "overlay/opacity", 0.8)
	OpenVROverlay.set_overlay_width_in_meters(SettingsManager.get_value("user", "overlay/size", 1.5))

	attempt_tracking()

func _on_trackers_changed(tracker_name, tracker_type, tracker_id):
	attempt_tracking()
	
func attempt_tracking():
	var position_x = SettingsManager.get_value("user", "overlay/position_x", 0)
	var position_y = SettingsManager.get_value("user", "overlay/position_y", 0)
	var position_z = SettingsManager.get_value("user", "overlay/position_z", -1.4)
	
	var rotation_x = SettingsManager.get_value("user", "overlay/rotation_x", 0)
	var rotation_y = SettingsManager.get_value("user", "overlay/rotation_y", 0)
	var rotation_z = SettingsManager.get_value("user", "overlay/rotation_z", 0)
	
	var transform = Transform(Basis(Vector3(0, 0, 0)), Vector3(position_x, position_y, position_z))
	transform.basis = transform.basis.rotated(Vector3(1, 0, 0), rotation_x)	
	transform.basis = transform.basis.rotated(Vector3(0, 1, 0), rotation_y)	
	transform.basis = transform.basis.rotated(Vector3(0, 0, 1), rotation_z)	

	transform = transform.orthonormalized()

	if $"SettingsWindow/TabContainer/General settings/MarginContainer/VBoxContainer/HBoxContainer/LeftSettings/TrackingHand/OptionButton".get_selected_id() != 2:
		var trackingIdFound = null
			
		for i in range(0, ARVRServer.get_tracker_count()):
			var tracker = ARVRServer.get_tracker(i)
				
			match tracker.get_hand():
				ARVRPositionalTracker.TRACKER_LEFT_HAND:
					if $"SettingsWindow/TabContainer/General settings/MarginContainer/VBoxContainer/HBoxContainer/LeftSettings/TrackingHand/OptionButton".get_selected_id() == 0:
						var name_parts = tracker.get_name().split("_")
						trackingIdFound = name_parts[name_parts.size() - 1]
				ARVRPositionalTracker.TRACKER_RIGHT_HAND:
					if $"SettingsWindow/TabContainer/General settings/MarginContainer/VBoxContainer/HBoxContainer/LeftSettings/TrackingHand/OptionButton".get_selected_id() == 1:
						var name_parts = tracker.get_name().split("_")
						trackingIdFound = name_parts[name_parts.size() - 1]
		
		if trackingIdFound:
			OpenVROverlay.track_relative_to_device(trackingIdFound, transform)
	else:
		OpenVROverlay.overlay_position_absolute(SettingsManager.get_value("user", "overlay/origin", 1), transform) # 0 = Seated, 1 = Standing
