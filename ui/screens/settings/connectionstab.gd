extends Tabs

var UUID = preload("res://addons/godot-uuid/uuid.gd")

var ConnectionContainerNode = "MarginContainer/VBoxContainer/PanelContainer/ScrollContainer/ConnectionsContainer"
var connections = []
var currentconnectorui = null

func _ready():
	SignalManager.connect("secrets_loaded", self, "_on_secrets_loaded")

func _on_secrets_loaded():
	connections = PasswordStorage.get_secret("connections")
	
	if connections:
		for i in connections:
			var connector = load("res://connectors/" + i["type"] + "connector.gd").new()
			
			currentconnectorui = load(connector["scene"]).instance()
			currentconnectorui.visible = false
			add_child(currentconnectorui)

			currentconnectorui.set_connection_info(i)
			currentconnectorui.verify_connection(self)
			
		redraw_connections()
	else:
		connections = []

func connection_verified(connection):
	remove_child(currentconnectorui)
	currentconnectorui.queue_free()

	for i in connections:
		if i["uuid"] == connection["uuid"]:
			i["valid"] = connection["valid"]

	redraw_connections()

func _on_AddButton_pressed():
	var addconnectiondialog = preload("res://ui/dialogs/addconnectiondialog.tscn").instance()
	add_child(addconnectiondialog)
	
	addconnectiondialog.set_settings_dialog(self)
	addconnectiondialog.popup_centered()

func add_connection(connection):
	if !connection.has("uuid"):
		connection["uuid"] = UUID.v4()
	
		connections.append(connection)
		PasswordStorage.set_secret("connections", connections)
	else:
		for i in range(0, connections.size()):
			if connections[i]["uuid"] == connection["uuid"]:
				connections[i] = connection
	
	redraw_connections()

func edit_connection(uuid):
	for i in connections:
		if i["uuid"] == uuid:
			var addconnectiondialog = preload("res://ui/dialogs/addconnectiondialog.tscn").instance()
			add_child(addconnectiondialog)
			
			addconnectiondialog.edit_connection(i)
			addconnectiondialog.set_settings_dialog(self)
			addconnectiondialog.popup_centered()

func remove_connection(uuid):
	for i in range(connections.size() - 1, -1, -1):
		if connections[i]["uuid"] == uuid:
			connections.remove(i)
	
	PasswordStorage.set_secret("connections", connections)
	redraw_connections()

func redraw_connections():
	for t in get_node(ConnectionContainerNode).get_children():
		get_node(ConnectionContainerNode).remove_child(t)
		t.queue_free()
		
	var iteration = 0
		
	for i in connections:
		if iteration > 0:
			var splitter = HSeparator.new()
			get_node(ConnectionContainerNode).add_child(splitter)
		
		var connectionitem = preload("res://ui/elements/items/connectionlistitem.tscn").instance()
		connectionitem.set_item_icon(i["icon"])
		connectionitem.set_item_name(i["name"])
		connectionitem.set_item_type(i["type"])
		connectionitem.set_is_valid(i["valid"])
		connectionitem.set_uuid(i["uuid"])
		connectionitem.set_event_node(self)
		
		get_node(ConnectionContainerNode).add_child(connectionitem)

		iteration = iteration + 1
