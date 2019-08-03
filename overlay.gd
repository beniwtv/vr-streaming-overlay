extends Control

var OpenVRConfig
var OpenVROverlay
var target_size = Vector2()

var SettingsNode : String = "MainWindow/SettingsScreen/General settings/MarginContainer/VBoxContainer/HBoxContainer/"

onready var vr3dscene = get_node("3DVRViewport")
onready var debugrect = get_node("MainWindow/SettingsScreen/General settings/MarginContainer/VBoxContainer/3DDebugRect")

func _ready() -> void:
	vr3dscene.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	debugrect.texture = vr3dscene.get_texture()
		
	# Set default audio device
	AudioServer.set_device(SettingsManager.get_value("user", "overlay/chimedevice", DefaultSettings.get_default_setting("overlay/chimedevice")))
	
	# Get configuration object
	OpenVRConfig = preload("res://addons/godot-openvr/OpenVRConfig.gdns").new()
	OpenVRConfig.set_application_type(2) # Set to OVERLAY MODE = 2, NORMAL MODE = 1
	OpenVRConfig.set_tracking_universe(SettingsManager.get_value("user", "overlay/origin", DefaultSettings.get_default_setting("overlay/origin"))) # Set to SEATED MODE = 0, STANDING MODE = 1, RAW MODE = 2
	
	# Find the OpenVR interface and initialise it
	var arvr_interface : ARVRInterface = ARVRServer.find_interface("OpenVR")

	if arvr_interface and arvr_interface.initialize():
		# Make sure we run at 90 FPS for this
		OS.vsync_enabled = false
		Engine.target_fps = 90
		
		# Set our resolution for the 2D scene
		target_size = arvr_interface.get_render_targetsize()
		$VRViewport.size = target_size
		$"3DVRViewport".size = target_size
		
		SignalManager.emit_signal("render_targetsize", target_size)
		
		# Create and display our overlay
		OpenVROverlay = preload("res://addons/godot-openvr/OpenVROverlay.gdns").new()
		OpenVROverlay.create_overlay("beniwtv.vr-streaming.overlay","VR Streaming Overlay") # Unique key and friendly name
		OpenVROverlay.set_overlay_width_in_meters(SettingsManager.get_value("user", "overlay/size", DefaultSettings.get_default_setting("overlay/size")))

		OpenVROverlay.show_overlay()
		
		SignalManager.emit_signal("vr_init", "done")
		
		# Listen for trackers becoming available / going away
		ARVRServer.connect("tracker_added", self, "_on_trackers_changed")
		ARVRServer.connect("tracker_removed", self, "_on_trackers_changed")

		get_node(SettingsNode + "LeftSettings/TrackingHand/OptionButton").add_item('None (absolute position)', 2)
		get_node(SettingsNode + "LeftSettings/TrackingHand/OptionButton").add_item('Left hand', 0)
		get_node(SettingsNode + "LeftSettings/TrackingHand/OptionButton").add_item('Right hand', 1)
		
		for i in range(0, get_node(SettingsNode + "LeftSettings/TrackingHand/OptionButton").get_item_count()):
			if SettingsManager.get_value("user", "overlay/hand", DefaultSettings.get_default_setting("overlay/hand")) == get_node(SettingsNode + "LeftSettings/TrackingHand/OptionButton").get_item_id(i): 
				get_node(SettingsNode + "LeftSettings/TrackingHand/OptionButton").select(i)
			
		if SettingsManager.get_value("user", "overlay/hand", DefaultSettings.get_default_setting("overlay/hand")) == 2:
			get_node(SettingsNode + "LeftSettings/TrackingOrigin").visible = true
		else:
			get_node(SettingsNode + "LeftSettings/TrackingOrigin").visible = false
		
		attempt_tracking()
		
	else:
		SignalManager.emit_signal("vr_init", "error")
					
	SignalManager.connect("settings_changed", self, "_on_settings_changed")

func _process(delta : float) -> void:
	if Input.is_action_just_pressed("center_on_hmd"):
		# Calling center_on_hmd will cause the ARVRServer to adjust all tracking data so the player is centered on the origin point looking forward
		ARVRServer.center_on_hmd(true, false)

func _on_settings_changed() -> void:
	if OpenVROverlay:
		OpenVROverlay.set_overlay_width_in_meters(SettingsManager.get_value("user", "overlay/size", DefaultSettings.get_default_setting("overlay/size")))
		OpenVRConfig.set_tracking_universe(SettingsManager.get_value("user", "overlay/origin", DefaultSettings.get_default_setting("overlay/origin")))
		attempt_tracking()

func _on_trackers_changed(tracker_name : String, tracker_type : int, tracker_id) -> void:
	attempt_tracking()
	
func attempt_tracking():
	var position_x : float = SettingsManager.get_value("user", "overlay/position_x", DefaultSettings.get_default_setting("overlay/position_x"))
	var position_y : float = SettingsManager.get_value("user", "overlay/position_y", DefaultSettings.get_default_setting("overlay/position_y"))
	var position_z : float = SettingsManager.get_value("user", "overlay/position_z", DefaultSettings.get_default_setting("overlay/position_y"))
	
	var rotation_x : float = SettingsManager.get_value("user", "overlay/rotation_x", DefaultSettings.get_default_setting("overlay/rotation_x"))
	var rotation_y : float = SettingsManager.get_value("user", "overlay/rotation_y", DefaultSettings.get_default_setting("overlay/rotation_y"))
	var rotation_z : float = SettingsManager.get_value("user", "overlay/rotation_z", DefaultSettings.get_default_setting("overlay/rotation_z"))
	
	var transform : Transform = Transform(Basis(Vector3(0, 0, 0)), Vector3(position_x, position_y, position_z))
	transform.basis = transform.basis.rotated(Vector3(1, 0, 0), rotation_x)	
	transform.basis = transform.basis.rotated(Vector3(0, 1, 0), rotation_y)	
	transform.basis = transform.basis.rotated(Vector3(0, 0, 1), rotation_z)	

	transform = transform.orthonormalized()

	if get_node(SettingsNode + "LeftSettings/TrackingHand/OptionButton").get_selected_id() != 2:
		var trackingIdFound = null
			
		for i in range(0, ARVRServer.get_tracker_count()):
			var tracker = ARVRServer.get_tracker(i)
				
			match tracker.get_hand():
				ARVRPositionalTracker.TRACKER_LEFT_HAND:
					if get_node(SettingsNode + "LeftSettings/TrackingHand/OptionButton").get_selected_id() == 0:
						var name_parts = tracker.get_name().split("_")
						trackingIdFound = name_parts[name_parts.size() - 1]
				ARVRPositionalTracker.TRACKER_RIGHT_HAND:
					if get_node(SettingsNode + "LeftSettings/TrackingHand/OptionButton").get_selected_id() == 1:
						var name_parts = tracker.get_name().split("_")
						trackingIdFound = name_parts[name_parts.size() - 1]
		
		if trackingIdFound:
			OpenVROverlay.track_relative_to_device(trackingIdFound, transform)
	else:
		OpenVROverlay.overlay_position_absolute(transform)
