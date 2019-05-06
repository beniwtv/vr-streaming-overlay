extends VBoxContainer

var icon = null
var prefix = ""

func _ready():
	$HBoxContainer/AddButton.connect("pressed", self, "_on_AddButton_pressed")
	$HBoxContainer/ChannelEdit.connect("text_entered", self, "_on_ChannelEdit_text_entered")
	$ItemList.connect("item_selected", self, "_on_ItemList_item_selected")
	
func _on_ItemList_item_selected(index):
	$ItemList.remove_item(index)
	fire_changed()
	
func _on_ChannelEdit_text_entered(text):
	_on_AddButton_pressed()

func _on_AddButton_pressed():
	if $HBoxContainer/ChannelEdit.text.length() > 0:
		var item = ( "" if $HBoxContainer/ChannelEdit.text.begins_with(prefix) else "" + prefix ) + $HBoxContainer/ChannelEdit.text
		$HBoxContainer/ChannelEdit.text = ""

		add_items([item])
		fire_changed()
		
# Fires when an item is added/removed
func fire_changed():
	var items = []
		
	for i in range(0, $ItemList.get_item_count()):
		items.append($ItemList.get_item_text(i))
		
	$"../../..".fire_changed(items)

# Adds items to the list
func add_items(items):
	for item in items:
		var found = false
		
		for t in range(0, $ItemList.get_item_count()):
			if $ItemList.get_item_text(t) == item:
				found = true
		
		if !found:
			$ItemList.add_item(item, icon, false)
			$ItemList.set_item_tooltip($ItemList.get_item_count() - 1, "Click to remove")	

# Gets list items

func get_items():
	var items = []
		
	for i in range(0, $ItemList.get_item_count()):
		items.append($ItemList.get_item_text(i))
		
	return items
