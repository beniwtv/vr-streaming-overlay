extends Control

var uuid : String = ""
var eventNode : Node = null

func set_item_icon(icon : StreamTexture) -> void:
	$HBoxContainer/MarginContainer/ConnectionIcon.texture = icon

func set_item_name(name : String) -> void:
	$HBoxContainer/HBoxContainer/ConnectionNameLabel.text = name
	
func set_item_type(type : String) -> void:
	var connector = load("res://connectors/" + type + "connector.gd").new()
	$HBoxContainer/HBoxContainer/ConnectionTypeLabel.text = connector.get_connector_display_name()

func set_is_valid(valid : bool) -> void:
	if valid:
		$HBoxContainer/ValidVboxMarginContainer/ValidVBoxContainer/CenterContainer/IsValid.visible = true
		$HBoxContainer/ValidVboxMarginContainer/ValidVBoxContainer/CenterContainer/NotValid.visible = false
	else:
		$HBoxContainer/ValidVboxMarginContainer/ValidVBoxContainer/CenterContainer/IsValid.visible = false
		$HBoxContainer/ValidVboxMarginContainer/ValidVBoxContainer/CenterContainer/NotValid.visible = true	

func set_uuid(uuid : String) -> void:
	self.uuid = uuid

func set_event_node(node : Node) -> void:
	eventNode = node

func _on_DeleteConnectionButton_pressed() -> void:
	if eventNode:
		eventNode.remove_connection(uuid)

func _on_EditConnectionButton_pressed() -> void:
	if eventNode:
		eventNode.edit_connection(uuid)
