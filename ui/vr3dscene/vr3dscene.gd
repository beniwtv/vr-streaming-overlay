extends Spatial

var collision_seconds = 0;
var seconds_required_to_undim = 0;

func _ready() -> void:
	SignalManager.connect("settings_changed", self, "_on_settings_changed")
	seconds_required_to_undim = SettingsManager.get_value("user", "overlay/undimstareseconds", DefaultSettings.get_default_setting("overlay/undimstareseconds"))

	adjust_position()
	adjust_size()

func _physics_process(delta):
	if $ARVROrigin/ARVRCamera/RayCast.is_colliding():
		collision_seconds = collision_seconds + delta
	else:
		collision_seconds = 0

	if collision_seconds >= seconds_required_to_undim:
		collision_seconds = 0
		SignalManager.emit_signal("event_happened_silent")
	
func _on_settings_changed() -> void:
	seconds_required_to_undim = SettingsManager.get_value("user", "overlay/undimstareseconds", DefaultSettings.get_default_setting("overlay/undimstareseconds"))
	collision_seconds = 0

	adjust_position()
	adjust_size()
	
func adjust_size() -> void:
	var width = SettingsManager.get_value("user", "overlay/size", DefaultSettings.get_default_setting("overlay/size"))
	$ARVROrigin/OverlayArea.mesh.size = Vector2(width, width)	
	$ARVROrigin/OverlayArea/StaticBody/CollisionShape.shape.extents = Vector3(width * 0.35, 0.08, width * 0.35) 

func adjust_position() -> void:
	var position_x : float = SettingsManager.get_value("user", "overlay/position_x", DefaultSettings.get_default_setting("overlay/position_x"))
	var position_y : float = SettingsManager.get_value("user", "overlay/position_y", DefaultSettings.get_default_setting("overlay/position_y"))
	var position_z : float = SettingsManager.get_value("user", "overlay/position_z", DefaultSettings.get_default_setting("overlay/position_y"))
	
	var rotation_x : float = SettingsManager.get_value("user", "overlay/rotation_x", DefaultSettings.get_default_setting("overlay/rotation_x"))
	var rotation_y : float = SettingsManager.get_value("user", "overlay/rotation_y", DefaultSettings.get_default_setting("overlay/rotation_y"))
	var rotation_z : float = SettingsManager.get_value("user", "overlay/rotation_z", DefaultSettings.get_default_setting("overlay/rotation_z"))
	
	var areatransform : Transform = Transform(Basis(Vector3(0, 0, 0)), Vector3(position_x, position_y, position_z))
	areatransform.basis = areatransform.basis.rotated(Vector3(1, 0, 0), rotation_x + 1.5)	
	areatransform.basis = areatransform.basis.rotated(Vector3(0, 1, 0), rotation_y)	
	areatransform.basis = areatransform.basis.rotated(Vector3(0, 0, 1), rotation_z)	

	areatransform = areatransform.orthonormalized()
	$ARVROrigin/OverlayArea.transform = areatransform
