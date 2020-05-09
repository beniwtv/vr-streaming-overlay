extends Control

var OpenVRConfig
var OpenVROverlay

var SettingsNode : String = "MainWindow/SettingsScreen/General settings/MarginContainer/VBoxContainer/HBoxContainer/"
var render_target_size : Vector2

#onready var vr3dscene = get_node("3DVRViewport")
#onready var debugrect = get_node("MainWindow/SettingsScreen/General settings/MarginContainer/VBoxContainer/3DDebugRect")

func _ready() -> void:
	#vr3dscene.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	#yield(get_tree(), "idle_frame")
	#yield(get_tree(), "idle_frame")
	#debugrect.texture = vr3dscene.get_texture()
	
	# Get configuration object
	OpenVRConfig = preload("res://addons/godot-openvr/OpenVRConfig.gdns").new()
	OpenVRConfig.set_application_type(2) # Set to OVERLAY MODE = 2, NORMAL MODE = 1
	OpenVRConfig.set_tracking_universe(DefaultSettings.get_default_setting("overlay/origin")) # Set to SEATED MODE = 0, STANDING MODE = 1, RAW MODE = 2
	
	# Find the OpenVR interface and initialise it
	var arvr_interface : ARVRInterface = ARVRServer.find_interface("OpenVR")

	if arvr_interface and arvr_interface.initialize():
		# Make sure we run at 90 FPS for this
		OS.vsync_enabled = false
		Engine.target_fps = 30
		Engine.iterations_per_second = 15
		
		# Load pointer overlay
		#var pointer1 = load("res://ui/pointer/pointerinstance.tscn").instance()
		#$Overlays.add_child(pointer1)
		
		# Set our resolution for the 2D scene
		render_target_size = arvr_interface.get_render_targetsize()
		
		SignalManager.emit_signal("vr_init", "done")
		
		SignalManager.connect("overlay_add", self, "_on_overlay_add")
		SignalManager.connect("overlay_remove", self, "_on_overlay_remove")
		SignalManager.connect("redraw_overlay", self, "_on_redraw_overlay")
		
		# Add all the configured overlays to OpenVR
		var overlays : Array = SettingsManager.get_value("user", "overlays/configuration", [])
		
		for overlay in overlays:
			_on_overlay_add(overlay)
	else:
		SignalManager.emit_signal("vr_init", "error")

func _process(delta : float) -> void:
	if Input.is_action_just_pressed("center_on_hmd"):
		# Calling center_on_hmd will cause the ARVRServer to adjust all tracking data so the player is centered on the origin point looking forward
		ARVRServer.center_on_hmd(true, false)

# Called when a new overlay needs to be added to OpenVR
func _on_overlay_add(overlay : Dictionary) -> void:
	var overlayInstance = load("res://ui/overlay/overlayinstance.tscn").instance()
	overlayInstance.set_meta("uuid", overlay["uuid"])
	$Overlays.add_child(overlayInstance)
	
	overlayInstance.set_configuration(overlay["config"], overlay["widgets"], render_target_size)

# Called when an overlay needs to be removed from OpenVR
func _on_overlay_remove(uuid : String) -> void:
	for overlay in $Overlays.get_children():
		if uuid == overlay.get_meta("uuid"):
			overlay.destroy()
			overlay.queue_free()

# Called when an overlay needs to be redrawn due to settings changing
func _on_redraw_overlay(overlay : Dictionary) -> void:
	for item in $Overlays.get_children():
		if overlay["uuid"] == item.get_meta("uuid"):
			item.set_configuration(overlay["config"], overlay["widgets"], render_target_size)
