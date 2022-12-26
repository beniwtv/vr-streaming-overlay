extends Spatial

var overlay_config : Dictionary
var collision_seconds : float = 0
var position_x : float
var position_y : float
var position_z : float
var rotation_x : float
var rotation_y : float
var rotation_z : float

# User settings
var hand_value : int
var seconds_required_to_undim : int = 0;
var size_value : float
var overlay_height: float
var seconds_required_to_show : float
var angle_required : int

func _ready() -> void:
	hand_value = DefaultSettings.get_default_setting("overlay/hand")
	seconds_required_to_undim = DefaultSettings.get_default_setting("overlay/undimstareseconds")
	position_x = DefaultSettings.get_default_setting("overlay/position_x")
	position_y = DefaultSettings.get_default_setting("overlay/position_y")
	position_z = DefaultSettings.get_default_setting("overlay/position_z")
	rotation_x = DefaultSettings.get_default_setting("overlay/rotation_x")
	rotation_y = DefaultSettings.get_default_setting("overlay/rotation_y")
	rotation_z = DefaultSettings.get_default_setting("overlay/rotation_z")
	
	seconds_required_to_show = DefaultSettings.get_default_setting("overlay/showseconds")
	angle_required = DefaultSettings.get_default_setting("overlay/showangle")
	
	adjust_position()
	adjust_size()

func set_configuration(config : Dictionary, widgets : Array, render_target_size : Vector2) -> void:
	# Parse overlay configuration
	overlay_config = config
	
	hand_value = DefaultSettings.get_default_setting("overlay/hand")
	if overlay_config.has("hand"): hand_value = overlay_config["hand"]
	
	seconds_required_to_undim = DefaultSettings.get_default_setting("overlay/undimstareseconds")
	if overlay_config.has("undimstareseconds"): seconds_required_to_undim = overlay_config["undimstareseconds"]

	size_value = DefaultSettings.get_default_setting("overlay/size")
	if overlay_config.has("size"): size_value = overlay_config["size"]

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

	overlay_height = DefaultSettings.get_default_setting("overlay/height")
	if overlay_config.has("height"): overlay_height = overlay_config["height"]

	seconds_required_to_show = DefaultSettings.get_default_setting("overlay/showseconds")
	if overlay_config.has("showseconds"): seconds_required_to_show = overlay_config["showseconds"]
	
	angle_required = DefaultSettings.get_default_setting("overlay/showangle")
	if overlay_config.has("showangle"): angle_required = overlay_config["showangle"]

	collision_seconds = 0
	
	adjust_position()
	adjust_size()

# Checks if the user is looking towards the overlay, and undims it if configured
func _physics_process(delta) -> void:
	if $ARVROrigin/ARVRCamera/RayCast.is_colliding():
		collision_seconds = collision_seconds + delta
	else:
		collision_seconds = 0
		
		if hand_value == 0 or hand_value == 1:
			get_node("../..").set_overlay_visible(false)

	if hand_value == 0 or hand_value == 1:
		# If in hand mode, detect overlay angle towards the HMD
		var position : Transform
		
		if hand_value == 0:
			position = get_node("../../3DVRViewport/VR3DScene/ARVROrigin/LeftHand").transform
		else:
			position = get_node("../../3DVRViewport/VR3DScene/ARVROrigin/RightHand").transform
		
		adjust_position(position)
		
		var normal : Vector3 = $ARVROrigin/ARVRCamera/RayCast.get_collision_normal()
		#print(normal)
		#print($ARVROrigin/ARVRCamera/RayCast.is_colliding())
		#print(hand_value)
		#print(get_node("../..").is_overlay_visible())

		#var angle : float = rad2deg(controller_transform.basis.get_euler().z)

		#if angle >= angle_required:
		#	angle_seconds = angle_seconds + delta
		#else:
		#	angle_seconds = 0
		if collision_seconds >= seconds_required_to_show:
			collision_seconds = 0
			get_node("../..").set_overlay_visible(true)
	else:
		if collision_seconds >= seconds_required_to_undim:
			collision_seconds = 0
			SignalManager.emit_signal("event_happened_silent")

func adjust_size() -> void:
	$ARVROrigin/OverlayArea.mesh.size = Vector2(size_value, size_value)
	$ARVROrigin/OverlayArea.mesh.size.y = $ARVROrigin/OverlayArea.mesh.size.y * overlay_height
	$ARVROrigin/OverlayArea/StaticBody/CollisionShape.shape.extents = Vector3(size_value * 0.8, 0.08, (size_value * overlay_height) * 0.8)

func adjust_position(areatransform : Transform = Transform()) -> void:
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
			
		#areatransform = Transform(Basis(Vector3(0, 0, 0)), Vector3(position_x, position_y, position_z))
		areatransform.basis = areatransform.basis.rotated(Vector3(1, 0, 0), rotation_x + 1.5)
		areatransform.basis = areatransform.basis.rotated(Vector3(0, 1, 0), rotation_y)
		areatransform.basis = areatransform.basis.rotated(Vector3(0, 0, 1), rotation_z)
			
		#areatransform = transform.orthonormalized()
		$ARVROrigin/OverlayArea.transform = areatransform
	else:
		areatransform = Transform(Basis(Vector3(0, 0, 0)), Vector3(position_x, position_y, position_z))
		areatransform.basis = areatransform.basis.rotated(Vector3(1, 0, 0), rotation_x + 1.5)
		areatransform.basis = areatransform.basis.rotated(Vector3(0, 1, 0), rotation_y)
		areatransform.basis = areatransform.basis.rotated(Vector3(0, 0, 1), rotation_z)

		areatransform = areatransform.orthonormalized()
		$ARVROrigin/OverlayArea.transform = areatransform
