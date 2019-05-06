extends Node

func get_widget_display_name():
	return get("display_name")

func get_widget_icon():
	return get("icon")

func get_widget_tooltip():
	return get("tooltip")

func get_widget_option_scene():
	return get("option_scene")

func get_widget_render_scene():
	return get("render_scene")

func get_metadata():
	return {"widget": get_script().resource_path, "display_name": get("display_name"), "option_scene": get("option_scene")}
