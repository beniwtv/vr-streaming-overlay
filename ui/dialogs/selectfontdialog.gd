extends WindowDialog

var font_list_node : String = "MarginContainer/VBoxContainer/HBoxContainer/FontBoxContainer/FontList"
var font_size_node : String = "MarginContainer/VBoxContainer/HBoxContainer/SizeBoxContainer/FontSizeList"

var result_dialog : Node = null
var font_options : Dictionary

func _ready():
	font_options = DefaultSettings.get_default_setting("widgets/font")
	
	# Load fonts available
	var dir : Directory = Directory.new()

	if dir.open("res://ui/font") == OK:
		dir.list_dir_begin()
		var file_name : String = dir.get_next()

		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				if file_name.ends_with(".ttf"):
					print("Found font: " + file_name)
					get_node(font_list_node).add_item(" " + file_name)
					get_node(font_list_node).set_item_metadata(get_node(font_list_node).get_item_count() - 1, "res://ui/font")

			file_name = dir.get_next()
	else:
		print("Unable to load fonts - path not found!")
		
	if dir.open("user://fonts") == OK:
		dir.list_dir_begin()
		var file_name : String = dir.get_next()

		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				if file_name.ends_with(".ttf"):
					print("Found user font: " + file_name)
					get_node(font_list_node).add_item(" " + file_name)
					get_node(font_list_node).set_item_metadata(get_node(font_list_node).get_item_count() - 1, "user://fonts")

			file_name = dir.get_next()
	
	for i in range(5, 100):
		get_node(font_size_node).add_item(" " + str(i + 1))

	render_font()

func edit_font(font : Dictionary):
	font_options = font
	
	for item in get_node(font_list_node).get_item_count():
		if get_node(font_list_node).get_item_text(item).trim_prefix(" ") == font.name:
			get_node(font_list_node).select(item)
			get_node(font_list_node).ensure_current_is_visible()
	
	for item in get_node(font_size_node).get_item_count():
		if get_node(font_size_node).get_item_text(item).trim_prefix(" ") == str(font.size):
			get_node(font_size_node).select(item)
			get_node(font_size_node).ensure_current_is_visible()
	
	render_font()

func set_result_dialog(dialog : Node):
	result_dialog = dialog

func _on_OKButton_pressed():
	result_dialog.handle_result(font_options)
	visible = false

func _on_CancelButton_pressed():
	visible = false

func _on_FontList_item_selected(index):
	font_options.file = get_node(font_list_node).get_item_metadata(index) + "/" + get_node(font_list_node).get_item_text(index).trim_prefix(" ")
	font_options.name = get_node(font_list_node).get_item_text(index).trim_prefix(" ")
	render_font()

func _on_FontSizeList_item_selected(index):
	font_options.size = int(get_node(font_size_node).get_item_text(index).trim_prefix(" "))
	render_font()

func render_font():
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load(font_options.file)
	dynamic_font.size = font_options.size
	$MarginContainer/VBoxContainer/PreviewLabel.set("custom_fonts/font", dynamic_font)
