extends WindowDialog

var services : Array = []
var currentconnectorui : Node = null
var settings_dialog : Node = null

var ConnectorsBoxNode : String = "MarginContainer/VBoxContainer/ConnectorBoxNode"
var ConnectorUIContainerNode : String = "MarginContainer/VBoxContainer/ConnectorUIContainer"

func _ready():
	# Load dynamic connectors for services
	var dir : Directory = Directory.new()
	
	if dir.open("res://connectors") == OK:
		dir.list_dir_begin()
		var file_name : String = dir.get_next()
		var blacklist : Array = ["baseconnector.gd"]

		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				if file_name.ends_with(".gd") and blacklist.find(file_name) == -1 and !file_name.ends_with("ui.gd"):
					var connector = load("res://connectors/" + file_name).new()
					print("Found service connector: " + connector.get_connector_display_name() + " (" + file_name + ")")
			
					get_node(ConnectorsBoxNode).add_item(connector.get_connector_display_name(), connector.get_connector_icon())
					get_node(ConnectorsBoxNode).set_item_tooltip(get_node(ConnectorsBoxNode).get_item_count() - 1, connector.get_connector_tooltip())
					get_node(ConnectorsBoxNode).set_item_metadata(get_node(ConnectorsBoxNode).get_item_count() - 1, connector.get_metadata())
			
			file_name = dir.get_next()
	else:
		print("Unable to load connectors - path not found!")	

func edit_connection(connection : Dictionary):
	for i in range(0, get_node(ConnectorsBoxNode).get_item_count()):
		if get_node(ConnectorsBoxNode).get_item_metadata(i)["type"] == connection["type"]:
			get_node(ConnectorsBoxNode).select(i)
			_on_ConnectorBoxNode_item_selected(i)
			currentconnectorui.set_connection_info(connection)

func set_settings_dialog(dialog : Node):
	settings_dialog = dialog

func _on_OKButton_pressed():
	currentconnectorui.verify_connection(self)

func connection_verified(response : Dictionary):
	if response.error:
		var accept_dialog : AcceptDialog = AcceptDialog.new()
		accept_dialog.window_title = "Authentication failed"
		accept_dialog.dialog_text = "I am sorry - this token did not work! - " + response.message

		add_child(accept_dialog)	
		accept_dialog.popup_centered()
	else:
		settings_dialog.add_connection(response)
		visible = false
	
func _on_CancelButton_pressed():
	visible = false	

func _on_ConnectorBoxNode_item_selected(index : int):
	var connector : Dictionary = get_node(ConnectorsBoxNode).get_item_metadata(index)
	
	currentconnectorui = load(connector["scene"]).instance()
	get_node(ConnectorUIContainerNode).add_child(currentconnectorui)
