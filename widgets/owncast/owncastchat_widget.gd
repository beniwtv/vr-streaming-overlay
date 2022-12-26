extends RichTextLabel

# Things we need to check during connection to Owncast
var authenticated = false

# Websocket connection to Owncast
var websocket : WebSocketClient
var httpclient : HTTPRequest
var http_busy = false

# Current chat lines displayed in the chat window
var chat_lines = PoolStringArray()

# Download queue for emoji
var download_queue = []

# Configuration data
var uuid = null
var url = null
var access_token = null
var compact_mode = false

var text_color = Color(255, 255, 255)
var show_timestamps = false

# Apply config given by widget manager
func apply_config(widget_id, config):
	var connections = PasswordStorage.get_secret("connections")
	if !connections: connections = []
	
	if config.has("ratio"): size_flags_stretch_ratio = config["ratio"]
	if config.has("text_color"): text_color = config["text_color"]
	if config.has("compact_mode"): compact_mode = config["compact_mode"]
	if config.has("show_timestamps"): show_timestamps = config["show_timestamps"]
	
	if config.has("connection"):
		for i in connections:
			if config["connection"] == i["uuid"]:
				uuid = i["uuid"]
				url = i["url"]
				access_token = i["accessToken"]
	
	if config.has("font"):
		var dynamic_font = DynamicFont.new()
		dynamic_font.font_data = load(config["font"].file)
		dynamic_font.size = config["font"].size
		dynamic_font.add_fallback(load("res://ui/font/TwitterColorEmoji-SVGinOT.ttf"))
		set("custom_fonts/normal_font", dynamic_font)
	
	connect_to_owncast()

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Owncast chat widget loading!")

	# Prepare our chat lines array
	for i in range(0, 200):
		chat_lines.append("\n")

func _exit_tree():
	print("Owncast chat widget unloading!")
	
	if websocket:
		websocket.disconnect_from_host(0, "OK")
		websocket = null

# Download server's emoji
func download_emoji():
	var headers : Array = [
		"User-Agent: VR Streaming Overlay/1.0 (Godot)",
		"Accept: application/json"
	]
	
	var emoji_directory = Directory.new()
	emoji_directory.make_dir_recursive("user://emoji/" + uuid + "/")
	
	httpclient = HTTPRequest.new()
	add_child(httpclient)
	httpclient.connect("request_completed", self, "_on_owncast_list_emoji", [], CONNECT_DEFERRED)
	var err = httpclient.request(url + "/api/emoji", headers, true, HTTPClient.METHOD_GET)
	assert(err==OK)

func _on_owncast_list_emoji(result, response_code, headers, body) -> void:
	httpclient.disconnect("request_completed", self, "_on_owncast_list_emoji")
	var emojiResponse : JSONParseResult = JSON.parse(body.get_string_from_utf8())
	
	if response_code == 200:
		if typeof(emojiResponse.result) == TYPE_ARRAY:
			for emoji in emojiResponse.result:
				download_queue.append(emoji)

# Connect to Owncast websocket
func connect_to_owncast():
	if !url: return false
	if !access_token: return false
	
	chat_lines.append("CONNECTING... ")
	redraw_chat()
	
	websocket = WebSocketClient.new()
	websocket.connect("data_received", self, "_on_websocket_received")
	websocket.connect("connection_established", self, "_on_websocket_connected")
	websocket.connect("connection_error", self, "_on_websocket_error")

	# Remove "https://" from URL, if any
	var err = websocket.connect_to_url("wss://" + url.replace("https://", "") + "/ws?accessToken=" + access_token)

	if (err!=OK):
		# Make sure we could connect to Owncast
		chat_lines.append("ERROR! VERIFY CONNECTION TO INTERNET")
		redraw_chat()
		
func _on_websocket_received():
	var packet: PoolByteArray = websocket.get_peer(1).get_packet()
	var json_result: JSONParseResult = JSON.parse(packet.get_string_from_utf8())
	
	if json_result.error == OK:
		parse_websocket_data(json_result.result)

func _on_websocket_connected(protocol: String):
	chat_lines.append("CONNECTED TO OWNCAST!")
	download_emoji()
	redraw_chat()
	
func _on_websocket_error():
	chat_lines.append("ERROR! VERIFY CONNECTION TO INTERNET")
	redraw_chat()
	
func _process(delta):
	if websocket:
		websocket.poll()
		
	# Check if there is still something in the download queue	
	if download_queue.size() > 0:
		if http_busy:
			return
		
		http_busy = true
		var entry = download_queue[0]
		
		var headers : Array = [
			"User-Agent: VR Streaming Overlay/1.0 (Godot)"
		]
		
		httpclient.connect("request_completed", self, "_on_owncast_emoji_downloaded", [], CONNECT_DEFERRED)
		httpclient.set_download_file("user://emoji/" + uuid + "/" + entry["name"] + "." + entry["emoji"].get_extension()) 

		var err = httpclient.request(url + entry["emoji"], headers, true, HTTPClient.METHOD_GET)
		assert(err==OK)
		
		download_queue.remove(0)

func _on_owncast_emoji_downloaded(result, response_code, headers, body) -> void:
	httpclient.disconnect("request_completed", self, "_on_owncast_emoji_downloaded")
	http_busy = false

# Parses a websocket data packet received from Owncast
func parse_websocket_data(data):
	if data["type"] != "CHAT" and data["type"] != "SYSTEM":
		print("Message type not implemented - bug @beniwtv!")
		print(data)
		return

	var message: String = data["body"]
	var color = 1
	var timestamp = "[color=#" + text_color.to_html(true) + "]" + str(OS.get_time()["hour"]).pad_zeros(2) + ":" + str(OS.get_time()["minute"]).pad_zeros(2) + "[/color] " if show_timestamps else ""
	var author = 'SYSTEM'
	var mod = false
		
	if data["type"] == "CHAT":
		color = data["user"]["displayColor"]
		author = data["user"]["displayName"]
		
		if "scopes" in data["user"]:
			if "mod" in data["user"]["scopes"]:		
				mod = true
			
	var badges_string = " [img]res://widgets/owncast/moderator.png[/img]" if mod else ""			
	var line_sep = " - " if compact_mode else "\n"

	# Replace emoji's
	#var regex = RegEx.new()
	#regex.compile("<[a-z]+[^>]*>")

	#var replaceRegex = RegEx.new()
	#replaceRegex.compile(".*src=\"/img/emoji/(.*)\".*")

	#print(message)
	#for result in regex.search_all(message):
	#	var replaceResult = replaceRegex.search(result.get_string())
	#	if replaceResult:
	#		var image = Image.new()
	#		var err = image.load("user://emoji/" + uuid + "/" + replaceResult.get_string(1))
			
	#		var texture = ImageTexture.new()
	#		texture.create_from_image(image, 0)
			
	#		add_image(texture, 30)
			#message = message.replace(replaceResult.get_string(),"[img]user://emoji/" + uuid + "/" + replaceResult.get_string(1) + "[/img]")
	
	#print (message)
	chat_lines.append(timestamp + "[color=#" + Color.from_hsv(color / 360.0, 0.5, 0.5).lightened(0.4).to_html(true) + "]" + author + "[/color]" + badges_string + line_sep)
	chat_lines.append("[color=#" + text_color.to_html(true) + "]" + message + "[/color]\n\n")

	redraw_chat()

	SignalManager.emit_signal("event_happened")

# Redraws chat text in the richtextlabel
func redraw_chat():
	chat_lines.invert()
	chat_lines.resize(200)
	chat_lines.invert()
	
	clear()
	append_bbcode(chat_lines.join(""))

# Appends a message to the rich text label for display
func append_message(message, color, sender):
	var timestamp = "[color=#" + text_color.to_html(true) + "]" + str(OS.get_time()["hour"]).pad_zeros(2) + ":" + str(OS.get_time()["minute"]).pad_zeros(2) + "[/color] " if show_timestamps else ""

	if sender: message = sender + ' | ' + message
	if color: message = "[color=" + color + "]" + message + "[/color]"	
	if sender and color: message = timestamp + message
	
	chat_lines.append(message)
	redraw_chat()
