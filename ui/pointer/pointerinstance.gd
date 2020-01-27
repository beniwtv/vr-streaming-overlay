extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Listen for trackers becoming available / going away
	ARVRServer.connect("tracker_added", self, "_on_trackers_changed")
	ARVRServer.connect("tracker_removed", self, "_on_trackers_changed")
	
	attempt_tracking()

func destroy() -> void:
	$VRViewport.overlay_visible = false

func set_configuration(config : Dictionary, widgets: Array, render_target_size : Vector2) -> void:
	# Set texture size for VR texture
	rect_size = render_target_size
	$VRViewport.size = render_target_size
	$"3DVRViewport".size = render_target_size
	
	$VRViewport/VR2DScene.set_configuration(config, widgets, render_target_size)
	$"3DVRViewport/VR3DScene".set_configuration(config, widgets, render_target_size)

	attempt_tracking()

func _on_trackers_changed(tracker_name : String, tracker_type : int, tracker_id) -> void:
	attempt_tracking()

func attempt_tracking() -> void:
	if $VRViewport.is_overlay_visible():
		var position_x : float
		var position_y : float
		var position_z : float
		
		var rotation_x : float
		var rotation_y : float
		var rotation_z : float
		
		var transform : Transform
		
		position_x = 0.06
		position_y = -0.61
		position_z = -0.63
		rotation_x = 2.3
		rotation_y = 6.1
		rotation_z = 3.2
	
		#position_x = SettingsManager.get_value("user", "overlay/position_x", DefaultSettings.get_default_setting("overlay/position_x"))
		#position_y = SettingsManager.get_value("user", "overlay/position_y", DefaultSettings.get_default_setting("overlay/position_y"))
		#position_z = SettingsManager.get_value("user", "overlay/position_z", DefaultSettings.get_default_setting("overlay/position_z"))
		#rotation_x = SettingsManager.get_value("user", "overlay/rotation_x", DefaultSettings.get_default_setting("overlay/rotation_x"))
		#rotation_y = SettingsManager.get_value("user", "overlay/rotation_y", DefaultSettings.get_default_setting("overlay/rotation_y"))
		#rotation_z = SettingsManager.get_value("user", "overlay/rotation_z", DefaultSettings.get_default_setting("overlay/rotation_z"))
		
		transform = Transform(Basis(Vector3(0, 0, 0)), Vector3(position_x, position_y, position_z))
		transform.basis = transform.basis.rotated(Vector3(1, 0, 0), rotation_x)
		transform.basis = transform.basis.rotated(Vector3(0, 1, 0), rotation_y)
		transform.basis = transform.basis.rotated(Vector3(0, 0, 1), rotation_z)
	
		transform = transform.orthonormalized()
		transform.basis = transform.basis.scaled(Vector3(1, 300, 1))

		var leftTrackingIdFound = null
		var rightTrackingIdFound = null
		
		for i in range(0, ARVRServer.get_tracker_count()):
			var tracker = ARVRServer.get_tracker(i)
			
			match tracker.get_hand():
				ARVRPositionalTracker.TRACKER_LEFT_HAND:
					var name_parts = tracker.get_name().split("_")
					leftTrackingIdFound = name_parts[name_parts.size() - 1]
				ARVRPositionalTracker.TRACKER_RIGHT_HAND:
					var name_parts = tracker.get_name().split("_")
					rightTrackingIdFound = name_parts[name_parts.size() - 1]

		if rightTrackingIdFound != null:
			$VRViewport.track_relative_to_device(rightTrackingIdFound, transform)
		elif leftTrackingIdFound != null:
			$VRViewport.track_relative_to_device(leftTrackingIdFound, transform)
		else:
			print("No trackers (hands) available at the moment - no pointer!")
