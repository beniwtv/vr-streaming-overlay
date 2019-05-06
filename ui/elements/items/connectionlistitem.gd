extends Control

var uuid = null
var eventNode = null

func set_item_icon(icon):
	$HBoxContainer/ConnectionIcon.texture = icon

func set_item_name(name):
	$HBoxContainer/VBoxContainer/ConnectionNameLabel.text = name
	
func set_item_type(type):
	var connector = load("res://connectors/" + type + "connector.gd").new()
	$HBoxContainer/VBoxContainer/ConnectionTypeLabel.text = connector.get_connector_display_name()

func set_is_valid(valid):
	if valid:
		$HBoxContainer/IsValid.visible = true
		$HBoxContainer/NotValid.visible = false
	else:
		$HBoxContainer/IsValid.visible = false
		$HBoxContainer/NotValid.visible = true	

func set_uuid(uuid):
	self.uuid = uuid

func set_event_node(node):
	eventNode = node

func _on_DeleteConnectionButton_pressed():
	if eventNode:
		eventNode.remove_connection(uuid)

func _on_EditConnectionButton_pressed():
	if eventNode:
		eventNode.edit_connection(uuid)
