extends Control

var overlay_config : Dictionary

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
	
	# Parse overlay configuration
	overlay_config = config
	
	var size_value = DefaultSettings.get_default_setting("overlay/size")
	if overlay_config.has("size"): size_value = overlay_config["size"]
	$VRViewport.set_overlay_width_in_meters(size_value)

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
		
		var hand_value : int = DefaultSettings.get_default_setting("overlay/hand")
		if overlay_config.has("hand"): hand_value = overlay_config["hand"]

		if hand_value != 2:
			position_x = DefaultSettings.get_default_setting("overlay/position_x_hand")
			if overlay_config.has("position_x_hand"): position_x = overlay_config["position_x_hand"]
			position_y = DefaultSettings.get_default_setting("overlay/position_y_hand")
			if overlay_config.has("position_y_hand"): position_y = overlay_config["position_y_hand"]
			position_z = DefaultSettings.get_default_setting("overlay/position_z_hand")
			if overlay_config.has("position_z_hand"): position_z = overlay_config["position_z_hand"]
			
			if hand_value == 0:
				rotation_z = DefaultSettings.get_default_setting("overlay/rotation_z_hand_left")
			else:
				rotation_z = DefaultSettings.get_default_setting("overlay/rotation_z_hand_right")
			
			rotation_x = DefaultSettings.get_default_setting("overlay/rotation_x_hand")
			if overlay_config.has("rotation_x_hand"): rotation_x = overlay_config["rotation_x_hand"]
			rotation_y = DefaultSettings.get_default_setting("overlay/rotation_y")
			if overlay_config.has("rotation_y_hand"): rotation_y = overlay_config["rotation_y_hand"]
			rotation_z = DefaultSettings.get_default_setting("overlay/rotation_z")
			if overlay_config.has("rotation_z_hand"): rotation_z = overlay_config["rotation_z_hand"]
						
			transform = Transform(Basis(Vector3(0, 0, 0)), Vector3(position_x, position_y, position_z))
			transform = transform.rotated(Vector3(1, 0, 0), rotation_x)
			transform = transform.rotated(Vector3(0, 1, 0), rotation_y)
			transform = transform.rotated(Vector3(0, 0, 1), rotation_z)

			transform = transform.translated(Vector3(0, 0, 1) * position_z)
			transform = transform.orthonormalized()
		
		else:
			position_x = DefaultSettings.get_default_setting("overlay/position_x")
			if overlay_config.has("position_x"): position_x = overlay_config["position_x"]
			position_y = DefaultSettings.get_default_setting("overlay/position_y")
			if overlay_config.has("position_y"): position_y = overlay_config["position_y"]
			position_z = DefaultSettings.get_default_setting("overlay/position_z")
			if overlay_config.has("position_z"): position_z = overlay_config["position_z"]
			
			rotation_x = DefaultSettings.get_default_setting("overlay/rotation_x")
			if overlay_config.has("rotation_x"): rotation_x = overlay_config["rotation_x"]
			rotation_y = DefaultSettings.get_default_setting("overlay/rotation_y")
			if overlay_config.has("rotation_y"): rotation_y = overlay_config["rotation_y"]
			rotation_z = DefaultSettings.get_default_setting("overlay/rotation_z")
			if overlay_config.has("rotation_z"): rotation_z = overlay_config["rotation_z"]

			transform = Transform(Basis(Vector3(0, 0, 0)), Vector3(position_x, position_y, position_z))
			transform.basis = transform.basis.rotated(Vector3(1, 0, 0), rotation_x)
			transform.basis = transform.basis.rotated(Vector3(0, 1, 0), rotation_y)
			transform.basis = transform.basis.rotated(Vector3(0, 0, 1), rotation_z)
	
			transform = transform.orthonormalized()

		if hand_value != 2:
			var trackingIdFound = null
				
			for i in range(0, ARVRServer.get_tracker_count()):
				var tracker = ARVRServer.get_tracker(i)
					
				match tracker.get_hand():
					ARVRPositionalTracker.TRACKER_LEFT_HAND:
						if hand_value == 0:
							var name_parts = tracker.get_name().split("_")
							trackingIdFound = name_parts[name_parts.size() - 1]
					ARVRPositionalTracker.TRACKER_RIGHT_HAND:
						if hand_value == 1:
							var name_parts = tracker.get_name().split("_")
							trackingIdFound = name_parts[name_parts.size() - 1]
			
			if trackingIdFound:
				$VRViewport.track_relative_to_device(trackingIdFound, transform)
		else:
			$VRViewport.overlay_position_absolute(transform)
