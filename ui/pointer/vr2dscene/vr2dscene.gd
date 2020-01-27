extends Control

func set_configuration(config : Dictionary, widgets : Array, render_target_size : Vector2) -> void:
	# Set VR texture size
	rect_size = render_target_size
	$VRBackground.rect_size = render_target_size
