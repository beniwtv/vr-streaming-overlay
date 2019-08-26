extends Control

var OpenVROverlay
var overlay_id : int

var SettingsNode : String = "../../MainWindow/SettingsScreen/General settings/MarginContainer/VBoxContainer/HBoxContainer/"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.connect("render_targetsize", self, "_on_render_targetsize_changed")
	SignalManager.connect("settings_changed", self, "_on_settings_changed")
	
	# Listen for trackers becoming available / going away
	ARVRServer.connect("tracker_added", self, "_on_trackers_changed")
	ARVRServer.connect("tracker_removed", self, "_on_trackers_changed")
	
	# Wait for everything to be ready!?
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	# Create and display our overlay
	OpenVROverlay = preload("res://addons/godot-openvr/OpenVROverlay.gdns").new()

	var texid_overlay = VisualServer.texture_get_texid(VisualServer.viewport_get_texture($VRViewport.get_viewport_rid()))
	
	overlay_id = OpenVROverlay.create_overlay("beniwtv.vr-streaming.overlay-" + str(get_index()), "VR Streaming Overlay - Overlay #" + str(get_index()), texid_overlay) # Unique key and friendly name
	OpenVROverlay.set_overlay_width_in_meters(SettingsManager.get_value("user", "overlay/size", DefaultSettings.get_default_setting("overlay/size")), overlay_id)

	OpenVROverlay.show_overlay(overlay_id)
	
	attempt_tracking()

func _on_render_targetsize_changed(size : Vector2) -> void:
	$VRViewport.size = size
	$"3DVRViewport".size = size

func _on_settings_changed() -> void:
	if OpenVROverlay:
		OpenVROverlay.set_overlay_width_in_meters(SettingsManager.get_value("user", "overlay/size", DefaultSettings.get_default_setting("overlay/size")), overlay_id)
		attempt_tracking()

func _on_trackers_changed(tracker_name : String, tracker_type : int, tracker_id) -> void:
	attempt_tracking()

func attempt_tracking() -> void:
	if OpenVROverlay:
		var position_x : float
		var position_y : float
		var position_z : float
		
		var rotation_x : float
		var rotation_y : float
		var rotation_z : float
		
		var transform : Transform
	
		if get_node(SettingsNode + "LeftSettings/TrackingHand/OptionButton").get_selected_id() != 2:
			position_z = SettingsManager.get_value("user", "overlay/position_z_hand", DefaultSettings.get_default_setting("overlay/position_z_hand"))
			
			if get_node(SettingsNode + "LeftSettings/TrackingHand/OptionButton").get_selected_id() == 0:
				rotation_z = DefaultSettings.get_default_setting("overlay/rotation_z_hand_left")
			else:
				rotation_z = DefaultSettings.get_default_setting("overlay/rotation_z_hand_right")
			
			transform = Transform(Basis(Vector3(0, 0, 0)), Vector3(0, 0, position_z))
			transform = transform.rotated(Vector3(0, 0, 1), rotation_z)
			transform = transform.translated(Vector3(0, 0, 1) * position_z)
		else:
			position_x = SettingsManager.get_value("user", "overlay/position_x", DefaultSettings.get_default_setting("overlay/position_x"))
			position_y = SettingsManager.get_value("user", "overlay/position_y", DefaultSettings.get_default_setting("overlay/position_y"))
			position_z = SettingsManager.get_value("user", "overlay/position_z", DefaultSettings.get_default_setting("overlay/position_z"))
		
			rotation_x = SettingsManager.get_value("user", "overlay/rotation_x", DefaultSettings.get_default_setting("overlay/rotation_x"))
			rotation_y = SettingsManager.get_value("user", "overlay/rotation_y", DefaultSettings.get_default_setting("overlay/rotation_y"))
			rotation_z = SettingsManager.get_value("user", "overlay/rotation_z", DefaultSettings.get_default_setting("overlay/rotation_z"))
		
			var rand = rand_range(0, 5)
			rand = 0
			
			transform = Transform(Basis(Vector3(0, 0, 0)), Vector3(position_x, position_y, position_z - rand))
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
				OpenVROverlay.track_relative_to_device(trackingIdFound, transform, overlay_id)
		else:
			OpenVROverlay.overlay_position_absolute(transform, overlay_id)
