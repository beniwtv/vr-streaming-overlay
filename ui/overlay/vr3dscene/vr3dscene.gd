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
var seconds_required_to_undim : int = 0;
var size_value : float
var overlay_height: float

func _ready() -> void:
	seconds_required_to_undim = DefaultSettings.get_default_setting("overlay/undimstareseconds")
	position_x = DefaultSettings.get_default_setting("overlay/position_x")
	position_y = DefaultSettings.get_default_setting("overlay/position_y")
	position_z = DefaultSettings.get_default_setting("overlay/position_z")
	rotation_x = DefaultSettings.get_default_setting("overlay/rotation_x")
	rotation_y = DefaultSettings.get_default_setting("overlay/rotation_y")
	rotation_z = DefaultSettings.get_default_setting("overlay/rotation_z")
	
	adjust_position()
	adjust_size()

func set_configuration(config : Dictionary, widgets : Array, render_target_size : Vector2) -> void:
	# Parse overlay configuration
	overlay_config = config
	
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

	collision_seconds = 0
	
	adjust_position()
	adjust_size()

# Checks if the user is looking towards the overlay, and undims it if configured
func _physics_process(delta) -> void:
	if $ARVROrigin/ARVRCamera/RayCast.is_colliding():
		collision_seconds = collision_seconds + delta
	else:
		collision_seconds = 0

	if collision_seconds >= seconds_required_to_undim:
		collision_seconds = 0
		SignalManager.emit_signal("event_happened_silent")

func adjust_size() -> void:
	$ARVROrigin/OverlayArea.mesh.size = Vector2(size_value, size_value)
	$ARVROrigin/OverlayArea.mesh.size.y = $ARVROrigin/OverlayArea.mesh.size.y * overlay_height
	$ARVROrigin/OverlayArea/StaticBody/CollisionShape.shape.extents = Vector3(size_value * 0.8, 0.08, (size_value * overlay_height) * 0.8)

func adjust_position() -> void:
	var areatransform : Transform = Transform(Basis(Vector3(0, 0, 0)), Vector3(position_x, position_y, position_z))
	areatransform.basis = areatransform.basis.rotated(Vector3(1, 0, 0), rotation_x + 1.5)
	areatransform.basis = areatransform.basis.rotated(Vector3(0, 1, 0), rotation_y)
	areatransform.basis = areatransform.basis.rotated(Vector3(0, 0, 1), rotation_z)

	areatransform = areatransform.orthonormalized()
	$ARVROrigin/OverlayArea.transform = areatransform
