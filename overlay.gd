extends Control

var OpenVRConfig
var OpenVROverlay

var SettingsNode : String = "MainWindow/SettingsScreen/General settings/MarginContainer/VBoxContainer/HBoxContainer/"

#onready var vr3dscene = get_node("3DVRViewport")
#onready var debugrect = get_node("MainWindow/SettingsScreen/General settings/MarginContainer/VBoxContainer/3DDebugRect")

func _ready() -> void:
	#vr3dscene.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	#yield(get_tree(), "idle_frame")
	#yield(get_tree(), "idle_frame")
	#debugrect.texture = vr3dscene.get_texture()
		
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
		
		# Load configured overlays and pointers
		var overlay = load("res://ui/overlay/overlayinstance.tscn").instance()
		$Overlays.add_child(overlay)
		
		#var pointer1 = load("res://ui/pointer/pointerinstance.tscn").instance()
		#$Overlays.add_child(pointer1)
		
		# Set our resolution for the 2D scene
		var target_size : Vector2 = arvr_interface.get_render_targetsize()
		SignalManager.emit_signal("render_targetsize", target_size)
		
		SignalManager.emit_signal("vr_init", "done")
	else:
		SignalManager.emit_signal("vr_init", "error")
					
	SignalManager.connect("settings_changed", self, "_on_settings_changed")

func _process(delta : float) -> void:
	if Input.is_action_just_pressed("center_on_hmd"):
		# Calling center_on_hmd will cause the ARVRServer to adjust all tracking data so the player is centered on the origin point looking forward
		ARVRServer.center_on_hmd(true, false)

func _on_settings_changed() -> void:
	if OpenVROverlay:
		OpenVRConfig.set_tracking_universe(SettingsManager.get_value("user", "overlay/origin", DefaultSettings.get_default_setting("overlay/origin")))
