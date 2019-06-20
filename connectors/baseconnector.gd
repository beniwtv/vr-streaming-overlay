extends Node

func get_connector_display_name() -> String:
	return get("display_name")

func get_connector_icon() -> StreamTexture:
	return get("icon")

func get_connector_tooltip() -> String:
	return get("tooltip")

func get_connector_scene() -> String:
	return get("scene")

func get_metadata() -> Dictionary:
	return {"connector": get_script().resource_path, "display_name": get("display_name"), "scene": get("scene"), "type": get("type")}
