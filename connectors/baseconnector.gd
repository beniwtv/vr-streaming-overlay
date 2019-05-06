extends Node

func get_connector_display_name():
	return get("display_name")

func get_connector_icon():
	return get("icon")

func get_connector_tooltip():
	return get("tooltip")

func get_connector_scene():
	return get("scene")

func get_metadata():
	return {"connector": get_script().resource_path, "display_name": get("display_name"), "scene": get("scene"), "type": get("type")}
