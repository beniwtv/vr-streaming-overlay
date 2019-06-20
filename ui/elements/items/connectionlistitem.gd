extends Control

var uuid : String = ""
var eventNode : Node = null

func set_item_icon(icon : StreamTexture) -> void:
	$HBoxContainer/ConnectionIcon.texture = icon

func set_item_name(name : String) -> void:
	$HBoxContainer/VBoxContainer/ConnectionNameLabel.text = name
	
func set_item_type(type : String) -> void:
	var connector = load("res://connectors/" + type + "connector.gd").new()
	$HBoxContainer/VBoxContainer/ConnectionTypeLabel.text = connector.get_connector_display_name()

func set_is_valid(valid : bool) -> void:
	if valid:
		$HBoxContainer/IsValid.visible = true
		$HBoxContainer/NotValid.visible = false
	else:
		$HBoxContainer/IsValid.visible = false
		$HBoxContainer/NotValid.visible = true	

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
