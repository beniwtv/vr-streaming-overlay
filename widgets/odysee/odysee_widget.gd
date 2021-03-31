extends RichTextLabel

# Current chat lines displayed in the chat window
var chat_lines = PoolStringArray()

# Connection-checking timestamps
var last_ping = 0
var last_pong = 0
var last_check = 0

# Configuration data
var username = null
var chat_token = null
var compact_mode = false

var claim_id = "e78621e7ea5ddb580147f8be5cd8abf8fee35d2d"
var text_color = Color(255, 255, 255)
var timestamp_color = Color(255, 255, 255)
var username_color = Color(255, 255, 255)
var show_timestamps = false

# Apply config given by widget manager
func apply_config(widget_id, config):
	
	if config.has("ratio"): size_flags_stretch_ratio = config["ratio"]
	if config.has("claim_id"): claim_id = config["claim_id"]
	if config.has("text_color"): text_color = config["text_color"]
	if config.has("username_color"): username_color = config["username_color"]
	if config.has("timestamp_color"): timestamp_color = config["timestamp_color"]
	if config.has("compact_mode"): compact_mode = config["compact_mode"]
	if config.has("show_timestamps"): show_timestamps = config["show_timestamps"]
	
	if config.has("font"):
		var dynamic_font = DynamicFont.new()
		dynamic_font.font_data = load(config["font"].file)
		dynamic_font.size = config["font"].size
		dynamic_font.add_fallback(load("res://ui/font/TwitterColorEmoji-SVGinOT.ttf"))
		set("custom_fonts/normal_font", dynamic_font)
 
	connect_to_odysee()

# Called when the node enters the scene tree for the first time.


# Connect to Odysee via websockets
func connect_to_odysee():
	return

# Redraws chat text in the richtextlabel
func redraw_chat():
	chat_lines.invert()
	chat_lines.resize(200)
	chat_lines.invert()
	
	clear()
	append_bbcode(chat_lines.join(""))

# Appends a message to the rich text label for display
func append_message(message, color, sender):
	if typeof(color) == TYPE_COLOR:
		color = '#' + color.to_html(true)
	var timestamp = "[color=#" + text_color.to_html(true) + "]" + str(OS.get_time()["hour"]).pad_zeros(2) + ":" + str(OS.get_time()["minute"]).pad_zeros(2) + "[/color] " if show_timestamps else ""

	if sender: 
		message = "[color=#" + username_color.to_html(true) + "]" + sender + "[/color]" + ' | ' + "[color=" + color + "]" + message + "[/color]"
	message = "[color=#" + timestamp_color.to_html(true) + "]" + timestamp + "[/color]" + message

	chat_lines.append(message)
	redraw_chat()
	
# Our WebSocketClient instance
var _client = WebSocketClient.new()

func _ready():
	print("Odysee chat widget loading!")
	
	# Prepare our chat lines array
	for i in range(0, 200):
		chat_lines.append("\n")
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")

	# Initiate connection to the given URL.
	var err = _client.connect_to_url("wss://comments.lbry.com/api/v2/live-chat/subscribe?subscription_id=" + claim_id)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	_client.get_peer(1).put_packet("Test packet".to_utf8())

func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	var comment = JSON.parse(_client.get_peer(1).get_packet().get_string_from_utf8())
	print(comment.result["data"]["comment"]["channel_name"] + ": " + comment.result["data"]["comment"]["comment"])
	append_message(comment.result["data"]["comment"]["comment"] + "\n", text_color, comment.result["data"]["comment"]["channel_name"])

func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()
