extends Control

var dim_timer
var controller_transform : Transform
var overlay_config : Dictionary
var angle_seconds : float = 0

# User settings
var hand_value : int
var seconds_required_to_show : float
var angle_required : int
var color_value : Color
var opacity_value : float
var dimdownafter : int
var dimundim : bool
var undimchime : bool
var chimedevice: String
var dimdownopacity : float

# Widget configuration
var widgets : Array
var widgethash : int

func _ready() -> void:
	SignalManager.connect("secrets_loaded", self, "redraw_overlay")
	SignalManager.connect("event_happened", self, "_on_event_happened")
	SignalManager.connect("event_happened_silent", self, "_on_event_happened_silent")

	dim_timer = get_node("DimTimer")
	dim_timer.wait_time = DefaultSettings.get_default_setting("overlay/dimdownafter")
	
	if DefaultSettings.get_default_setting("overlay/dimundim") and DefaultSettings.get_default_setting("overlay/hand") == 2:
		dim_timer.start()
	
	$VRBackground.color = DefaultSettings.get_default_setting("overlay/color")
	$VRBackground.modulate.a = DefaultSettings.get_default_setting("overlay/opacity")
	
	hand_value = DefaultSettings.get_default_setting("overlay/hand")
	seconds_required_to_show = DefaultSettings.get_default_setting("overlay/showseconds")
	angle_required = DefaultSettings.get_default_setting("overlay/minangle")
	color_value = DefaultSettings.get_default_setting("overlay/color")
	opacity_value = DefaultSettings.get_default_setting("overlay/opacity")
	dimdownafter = DefaultSettings.get_default_setting("overlay/dimdownafter")
	dimundim = DefaultSettings.get_default_setting("overlay/dimundim")
	undimchime = DefaultSettings.get_default_setting("overlay/undimchime")
	dimdownopacity = DefaultSettings.get_default_setting("overlay/dimdownopacity")
	
func set_configuration(config : Dictionary, widgets : Array, render_target_size : Vector2) -> void:
	if widgethash != widgets.hash():
		widgethash = widgets.duplicate(true).hash()
		self.widgets = widgets
		redraw_overlay()
	
	# Set VR texture size
	rect_size = render_target_size
	$VRBackground.rect_size = render_target_size
	$WidgetsContainer.rect_size = render_target_size
	
	# Parse overlay configuration
	overlay_config = config
	
	hand_value = DefaultSettings.get_default_setting("overlay/hand")
	if overlay_config.has("hand"): hand_value = overlay_config["hand"]

	seconds_required_to_show = DefaultSettings.get_default_setting("overlay/showseconds")
	if overlay_config.has("showseconds"): seconds_required_to_show = overlay_config["showseconds"]

	angle_required = DefaultSettings.get_default_setting("overlay/minangle")
	if overlay_config.has("minangle"): angle_required = overlay_config["minangle"]

	$WidgetsContainer.modulate.a = 255

	color_value = DefaultSettings.get_default_setting("overlay/color")
	if overlay_config.has("color"): color_value = overlay_config["color"]
	$VRBackground.color = color_value
	
	opacity_value = DefaultSettings.get_default_setting("overlay/opacity")
	if overlay_config.has("opacity"): opacity_value = overlay_config["opacity"]
	$VRBackground.modulate.a = opacity_value

	dim_timer.stop()
	
	dimdownafter = DefaultSettings.get_default_setting("overlay/dimdownafter")
	if overlay_config.has("dimdownafter"): dimdownafter = overlay_config["dimdownafter"]
	dim_timer.wait_time = dimdownafter

	dimundim = DefaultSettings.get_default_setting("overlay/dimundim")
	if overlay_config.has("dimundim"): dimundim = overlay_config["dimundim"]

	if dimundim and hand_value == 2:
		dim_timer.start()
	else:
		undim_overlay()

	undimchime = DefaultSettings.get_default_setting("overlay/undimchime")
	if overlay_config.has("undimchime"): undimchime = overlay_config["undimchime"]

	chimedevice = DefaultSettings.get_default_setting("overlay/chimedevice")
	if overlay_config.has("chimedevice"): chimedevice = overlay_config["chimedevice"]

	dimdownopacity = DefaultSettings.get_default_setting("overlay/dimdownopacity")
	if overlay_config.has("dimdownopacity"): dimdownopacity = overlay_config["dimdownopacity"]
	
	angle_seconds = 0

# In hand mode, calculates the controler's angle and shows/hides the overlay
func _process(delta):
	# Detect controller gestures
	if hand_value == 0:
		controller_transform = get_node("../../3DVRViewport/VR3DScene/ARVROrigin/LeftHand").transform

		var angle : float = rad2deg(controller_transform.basis.get_euler().z)

		if angle >= angle_required:
			angle_seconds = angle_seconds + delta
		else:
			angle_seconds = 0
	elif hand_value == 1:
		controller_transform = get_node("../../3DVRViewport/VR3DScene/ARVROrigin/RightHand").transform
	
		var angle : float = rad2deg(controller_transform.basis.get_euler().z)
		
		if angle <= angle_required * -1:
			angle_seconds = angle_seconds + delta
		else:
			angle_seconds = 0
	else:
		visible = true
		return

	if angle_seconds >= seconds_required_to_show:
		visible = true
	else:
		visible = false

# Re-draw all widgets in this overlay (for example, due to configuration changes)
func redraw_overlay() -> void:
	# Remove all widgets
	for i in $WidgetsContainer.get_children():
		i.queue_free()

	# Somehow we need to wait two frames for Godot...
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	# Create fresh widgets
	for i in range(0, widgets.size()):
		var metadata = widgets[i]

		var widget_data : Node = load(metadata["data"]["widget"]).new()
		var widget : Node = load(widget_data.get_widget_render_scene()).instance()
		widget.apply_config(metadata["id"], metadata["data"]["config"])
		widget.set_meta("widget_id", metadata["id"])

		if metadata["data"]["parent"]:
			var parentitem : Node = _walk_nodes($WidgetsContainer, metadata["data"]["parent"])
			parentitem.add_child(widget)
		else:
			$WidgetsContainer.add_child(widget)

func _walk_nodes(node, widget_id) -> Node:
	if node.get_meta("widget_id") == widget_id:
		return node
	else:
		var founditem : Node
	
		for i in node.get_children():
			founditem = _walk_nodes(i, widget_id)
			if founditem: return founditem
		
		return node
	
# This dims the overlay down if necessary
func _on_DimTimer_timeout() -> void:
	$WidgetsContainer.modulate.a = dimdownopacity
	$VRBackground.modulate.a = dimdownopacity

# When events happen (e.g. generated by widgets, undim the overlay if necessary
func _on_event_happened_silent() -> void:
	undim_overlay()

# When events happen (e.g. generated by widgets, undim the overlay if necessary
func _on_event_happened() -> void:
	# Set default audio device
	AudioServer.set_device(chimedevice)
	
	if undimchime:
		$AudioStreamPlayer.play(0.0)
	
	undim_overlay()

func undim_overlay() -> void:
	$WidgetsContainer.modulate.a = 255
	$VRBackground.modulate.a = opacity_value
	
	$DimTimer.stop()
	
	if dimundim and hand_value == 2:
		$DimTimer.start()
