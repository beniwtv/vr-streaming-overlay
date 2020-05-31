extends Tabs

var UUID = preload("res://addons/godot-uuid/uuid.gd")
var OverlayListNode = "MarginContainer/VBoxContainer/OverlaysContainer/OverlayList"
var TabContainerNode = "MarginContainer/VBoxContainer/OverlaysContainer/OverlaySettings/TabContainer"

# Stores the final user's overlays configuration
var overlays : Array
var current_overlay_uuid : String

func _ready() -> void:
	SignalManager.connect("vr_init", self, "_on_vr_init")
	SignalManager.connect("settings_changed", self, "_on_settings_changed")
	
	# Load configured overlays and pointers
	overlays = SettingsManager.get_value("user", "overlays/configuration", [])
	
	# Select first overlay automatically, if any
	if overlays.size() > 0:
		select_overlay(0)
		
	redraw_list(true)

func _on_vr_init(status : String) -> void:
	if status == "done":
		$"MarginContainer/VBoxContainer/StatusBox".text = "You can now put on your headset!"
	else:
		$"MarginContainer/VBoxContainer/StatusBox".text = "Could not initialize OpenVR -> check console output!"

func _on_AddButton_pressed() -> void:
	# Add few things to metadata we need for saving later
	var overlay : Dictionary = {
		"name": "New overlay",
		"config": {},
		"widgets": DefaultSettings.get_default_setting("widgets/configuration"),
		"uuid": UUID.v4()
	}
	
	SignalManager.emit_signal("overlay_add", overlay)
	overlays.push_back(overlay)
	save_overlays()
	select_overlay(overlays.size() - 1)
	redraw_list(true)

# Saves the overlays to the user's config file
func save_overlays() -> void:
	SettingsManager.set_value("user", "overlays/configuration", overlays)

# Redraws the item list according to our overlays
func redraw_list(select_item : bool) -> void:
	yield(get_tree(), "idle_frame")
	
	get_node(OverlayListNode).clear()
	
	var treeroot : TreeItem = get_node(OverlayListNode).create_item()
	treeroot.set_text(0, "root")
	treeroot.set_metadata(0, "root")
	
	for overlay in overlays:
		var overlay_visible : bool = true
		if overlay.has("visible"): overlay_visible = overlay["visible"]
		
		var treeitem : TreeItem = get_node(OverlayListNode).create_item()
		treeitem.set_text(0, overlay["name"])
		treeitem.set_metadata(0, {"uuid": overlay["uuid"], "visible": overlay_visible})

		# Add remove and show/hide buttons
		if overlay_visible:
			treeitem.add_button(0, load("res://ui/theme/visible.png"), 0, false, "Hide this overlay")
		else:
			treeitem.add_button(0, load("res://ui/theme/hidden.png"), 0, false, "Show this overlay")
			
		treeitem.add_button(0, load("res://ui/theme/remove.png"), 1, false, "Delete this overlay")

	if select_item:
		var item = treeroot.get_children()
		
		while (item):
			if current_overlay_uuid == item.get_metadata(0)["uuid"]:
				item.select(0)
			
			item = item.get_next()

# When an overlay is selected
func _on_OverlayList_item_selected() -> void:
	var selectedTreeItem : TreeItem = get_node(OverlayListNode).get_selected()
	var uuid : String = selectedTreeItem.get_metadata(0)["uuid"]
	
	for i in range(0, overlays.size()):
		if overlays[i]["uuid"] == uuid:
			select_overlay(i)

# Delete or show/hide button pressed
func _on_OverlayList_button_pressed(item : TreeItem, column : int, id : int) -> void:
	var uuid : String = item.get_metadata(0)["uuid"]
	var overlay_visible : bool = item.get_metadata(0)["visible"]
	var overlayIndex : int = -1

	for i in range(0, overlays.size()):
		if overlays[i]["uuid"] == uuid:
			overlayIndex = i
			
	if overlayIndex > -1:
		if id == 1:
			overlays.remove(overlayIndex)
			SignalManager.emit_signal("overlay_remove", uuid)
			
			if overlays.size() > 0:
				select_overlay(0)
			elif overlays.size() == 0:
				get_node(TabContainerNode).visible = false
		else:
			if overlays[overlayIndex].has("visible"):
				overlays[overlayIndex]["visible"] = !overlays[overlayIndex]["visible"]
			else:
				overlays[overlayIndex]["visible"] = false
				
			SignalManager.emit_signal("overlay_visibility_toggle", uuid)
	
		save_overlays()
		redraw_list(true)

# Select the overlay, load it's configuration and display it
func select_overlay(index : int) -> void:
	get_node(TabContainerNode).visible = true
	get_node(TabContainerNode + "/General settings").set_active_overlay(overlays[index])
	get_node(TabContainerNode + "/Widgets").set_active_overlay(overlays[index])
	current_overlay_uuid = overlays[index]["uuid"]

# Saves all the overlays
func _on_settings_changed(overlay : Dictionary) -> void:
	SignalManager.emit_signal("redraw_overlay", overlay)
	save_overlays()
	redraw_list(false)
