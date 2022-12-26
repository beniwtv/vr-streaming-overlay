extends Control

var dim_timer
var controller_transform : Transform
var overlay_config : Dictionary
var angle_seconds : float = 0

# User settings
var hand_value : int
var color_value : Color
var opacity_value : float
var dimdownafter : int
var dimundim : bool
var undimchime : bool
var chimedevice: String
var dimdownopacity : float
var overlay_height : float

# Widget configuration
var widgets : Array
var widgethash : int

var widget_thread : Thread

func _ready() -> void:
	widget_thread = Thread.new()
		
	SignalManager.connect("secrets_loaded", self, "redraw_overlay")
	SignalManager.connect("event_happened", self, "_on_event_happened")
	SignalManager.connect("event_happened_silent", self, "_on_event_happened_silent")

	dim_timer = get_node("DimTimer")
	dim_timer.wait_time = DefaultSettings.get_default_setting("overlay/dimdownafter")
	
	if DefaultSettings.get_default_setting("overlay/dimundim") and DefaultSettings.get_default_setting("overlay/hand") == 2:
		dim_timer.start()
	
	$Viewport/VRBackground.color = DefaultSettings.get_default_setting("overlay/color")
	$Viewport/VRBackground.modulate.a = DefaultSettings.get_default_setting("overlay/opacity")
	
	hand_value = DefaultSettings.get_default_setting("overlay/hand")
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

	overlay_height = DefaultSettings.get_default_setting("overlay/height")
	if config.has("height"): overlay_height = config["height"]

	$Viewport.set_size_override(true, Vector2(render_target_size.x, render_target_size.y * overlay_height)) # Custom size for 2D.
	$Viewport.set_size_override_stretch(true) # Enable stretch for custom size.
	
	# Set VR texture size
	rect_size = render_target_size
	$Viewport.size = render_target_size
	$VROverlayScreen.rect_size = render_target_size
	$Viewport/VRBackground.rect_size = render_target_size
	$Viewport/WidgetsContainer.rect_size = render_target_size
	
	#$Viewport.size.y = $Viewport.size.y * overlay_height
	$Viewport/VRBackground.rect_size.y = $Viewport/VRBackground.rect_size.y * overlay_height
	$Viewport/WidgetsContainer.rect_size.y = $Viewport/WidgetsContainer.rect_size.y * overlay_height
		
	# Parse overlay configuration
	overlay_config = config
	
	hand_value = DefaultSettings.get_default_setting("overlay/hand")
	if overlay_config.has("hand"): hand_value = overlay_config["hand"]

	$Viewport/WidgetsContainer.modulate.a = 255

	color_value = DefaultSettings.get_default_setting("overlay/color")
	if overlay_config.has("color"): color_value = overlay_config["color"]
	$Viewport/VRBackground.color = color_value
	
	opacity_value = DefaultSettings.get_default_setting("overlay/opacity")
	if overlay_config.has("opacity"): opacity_value = overlay_config["opacity"]
	$Viewport/VRBackground.modulate.a = opacity_value

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

# Re-draw all widgets in this overlay (for example, due to configuration changes)
func redraw_overlay() -> void:
	if widget_thread.is_active():
		widget_thread.wait_to_finish()
			
	# Remove all widgets
	for i in $Viewport/WidgetsContainer.get_children():
		i.queue_free()

	# Somehow we need to wait two frames for Godot...
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	# Create fresh widgets
	widget_thread.start(self, "_widget_thread")
	
func _widget_thread(params) -> void:
	for i in range(0, widgets.size()):
		var metadata = widgets[i]

		var widget_data : Node = load(metadata["data"]["widget"]).new()
		var widget : Node = load(widget_data.get_widget_render_scene()).instance()
		widget.apply_config(metadata["id"], metadata["data"]["config"])
		widget.set_meta("widget_id", metadata["id"])

		if metadata["data"]["parent"]:
			var parentitem : Node = _walk_nodes($Viewport/WidgetsContainer, metadata["data"]["parent"])
			parentitem.add_child(widget)
		else:
			$Viewport/WidgetsContainer.add_child(widget)

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
	$Viewport/WidgetsContainer.modulate.a = dimdownopacity
	$Viewport/VRBackground.modulate.a = dimdownopacity

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
	$Viewport/WidgetsContainer.modulate.a = 255
	$Viewport/VRBackground.modulate.a = opacity_value
	
	$DimTimer.stop()
	
	if dimundim and hand_value == 2:
		$DimTimer.start()

func _exit_tree():
	widget_thread.wait_to_finish()
