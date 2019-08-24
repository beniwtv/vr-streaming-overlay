extends RichTextLabel

# Things we need to check during connection to Twitch
var irc_joined = false
var authenticated = false
var capok = false

# IRC commands run in a thread, so we don't block the UI
var irc_thread = null

# TCP stream we are connected to (with SSL on top)
var irc_stream = null

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

var channels = PoolStringArray()
var text_color = Color(255, 255, 255)
var show_timestamps = false

# Apply config given by widget manager
func apply_config(widget_id, config):
	var connections = PasswordStorage.get_secret("connections")
	if !connections: connections = []
	
	if config.has("ratio"): size_flags_stretch_ratio = config["ratio"]
	if config.has("channels"): channels = PoolStringArray(config["channels"])
	if config.has("text_color"): text_color = config["text_color"]
	if config.has("compact_mode"): compact_mode = config["compact_mode"]
	if config.has("show_timestamps"): show_timestamps = config["show_timestamps"]
	
	if config.has("connection"):
		for i in connections:
			if config["connection"] == i["uuid"]:
				username = i["name"]
				chat_token = i["token"]
	
	if config.has("font"):
		var dynamic_font = DynamicFont.new()
		dynamic_font.font_data = load(config["font"].file)
		dynamic_font.size = config["font"].size
		dynamic_font.add_fallback(load("res://ui/font/TwitterColorEmoji-SVGinOT.ttf"))
		set("custom_fonts/normal_font", dynamic_font)
	
	connect_to_twitch()

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Twitch widget loading!")
	
	# Prepare our chat lines array
	chat_lines.append("\n")

func _exit_tree():
	print("Twitch widget unloading!")
	
	if irc_thread and irc_thread.is_active():
		irc_thread.wait_to_finish()
	
	if irc_stream:
		irc_stream.disconnect_from_stream()
		irc_stream = null

# Connect to Twitch IRC in a separate thread
func connect_to_twitch():
	if !username: return false
	if !chat_token: return false
	
	irc_thread = Thread.new()
	irc_thread.start(self, "connect_to_irc")

func connect_to_irc(params):
	chat_lines.append("CONNECTING... ")
	redraw_chat()
	
	var tcp_stream = StreamPeerTCP.new()
	var err = tcp_stream.connect_to_host("irc.chat.twitch.tv", 6697)

	if (err!=OK):
		# Make sure we could connect to Twitch
		chat_lines.append("ERROR! VERIFY CONNECTION TO INTERNET")
		redraw_chat()
	
	irc_stream = StreamPeerSSL.new()
	irc_stream.set_blocking_handshake_enabled(true)
	irc_stream.connect_to_stream(tcp_stream, true, "irc.chat.twitch.tv")

	var count = 0

	while irc_stream.get_status() != StreamPeerSSL.STATUS_CONNECTED:
		OS.delay_msec(500)
		
		if count >= 60:
			chat_lines.append("ERROR! VERIFY CONNECTION TO INTERNET")
			redraw_chat()
			
			params.thread.call_deferred("wait_to_finish") # Execute on idle main thread
			
			return false
		else:
			count = count + 1

	authenticated = false
	
	irc_stream.put_data(("PASS oauth:" + chat_token + "\n").to_utf8())
	irc_stream.put_data(("NICK " + username + "\n").to_utf8())
	
	count = 0
	
	while !authenticated:
		irc_stream.poll()
		
		if irc_stream.get_available_bytes() > 0:
			var line = irc_stream.get_utf8_string(irc_stream.get_available_bytes())
			var code = parse_irc_line(line)
			if !code: return false
	
		OS.delay_msec(500)
	
		if count >= 60:		
			chat_lines.append("ERROR! VERIFY CONNECTION TO INTERNET")
			redraw_chat()
			
			params.thread.call_deferred("wait_to_finish") # Execute on idle main thread
			
			return false
		else:
			count = count + 1
	
	# Request advanced tags from Twitch
	irc_stream.put_data(("CAP REQ :twitch.tv/tags\n").to_utf8())
	
	count = 0
	
	while !capok:
		irc_stream.poll()

		if irc_stream.get_available_bytes() > 0:
			var line = irc_stream.get_utf8_string(irc_stream.get_available_bytes())
			var code = parse_irc_line(line)
			if !code: return false
	
		OS.delay_msec(500)
	
		if count >= 60:
			chat_lines.append("ERROR! VERIFY CONNECTION TO INTERNET")
			redraw_chat()
			
			params.thread.call_deferred("wait_to_finish") # Execute on idle main thread
			
			return false
		else:
			count = count + 1
	
	# Join our channel to monitor
	irc_stream.put_data(("JOIN " + channels.join(",") + "\n").to_utf8())

	count = 0

	while !irc_joined:
		irc_stream.poll()

		if irc_stream.get_available_bytes() > 0:
			var line = irc_stream.get_utf8_string(irc_stream.get_available_bytes())
			var code = parse_irc_line(line)
			if !code: return false
	
		OS.delay_msec(500)
		
		if count >= 60:			
			chat_lines.append("ERROR! VERIFY CONNECTION TO INTERNET")
			redraw_chat()
			
			params.thread.call_deferred("wait_to_finish") # Execute on idle main thread
			
			return false
		else:
			count = count + 1
	
func _process(delta):

	# Check Twitch reponds with a pong
	if irc_joined and (OS.get_unix_time() > last_check + 20):	
		if OS.get_unix_time() > last_pong + 40:
			print("Seems we lost connection to Twitch, reconnecting...")
		
			last_check = OS.get_unix_time()

			connect_to_twitch()
			return false
		else:
			irc_stream.put_data(("PING tmi.twitch.tv\n").to_utf8())
			last_check = OS.get_unix_time()

	# Check we received a ping from Twitch
	if irc_joined and (OS.get_unix_time() > last_ping + 330):
		print("Seems we lost connection to Twitch, reconnecting...")
		
		authenticated = false
		capok = false
		irc_joined = false
				
		connect_to_twitch()
		return false
	
	# Check for new messages in IRC
	if irc_stream and irc_stream.get_status() == StreamPeerSSL.STATUS_CONNECTED:
		irc_stream.poll()

		if irc_stream.get_available_bytes() > 0:
			var line = irc_stream.get_utf8_string(irc_stream.get_available_bytes())
			parse_irc_line(line)

# Parses an IRC line received from Twitch
func parse_irc_line(lines):
	lines = lines.split('\n')
	
	for line in lines:
		print(line)
		if line.find("NOTICE *") > -1:
			append_message(line.split(":")[2] + "\n\n", 'red', 'TWITCH')
		elif line.find("001") > -1:
			# We have been authenticated
			authenticated = true
			append_message(line.split(":")[2] + "\n\n", 'green', 'TWITCH')
		
			return true
		elif line.find("CAP * ACK") > -1:
			capok = true
			return true
		elif line.find("CAP * NAK") > -1:
			capok = false
			append_message("Could not get advanced capbabilities from Twitch!\n\n", 'red', 'TWITCH')			
			return false
		elif line.find("JOIN") > -1:
			var parts = line.split("JOIN ")
			append_message("Joined channel: " + parts[1].strip_edges() + "!\n\n", 'green', null)
			
			last_ping = OS.get_unix_time()
			last_pong = OS.get_unix_time()
			
			irc_joined = true
		elif line.find("PING") > -1:
			var parts = line.split(":")
			irc_stream.put_data(("PONG " + str(parts[1]) + "\n").to_utf8())
			
			last_ping = OS.get_unix_time()
			last_check = OS.get_unix_time()		
		elif line.find("PONG") > -1:
			last_pong = OS.get_unix_time()
		elif line.find("PRIVMSG") > -1:
			# Split in text and other parts
			var parts = line.split(" :")

			var message = parts[2]
			var caps = parts[0]
			
			# Split caps into a dictionary
			var cap_parts = caps.split(";")
			var mod = false
			var color = 'white'
			var author = null
			
			for i in cap_parts:
				if i.find("moderator/1") > -1 or i.find("broadcaster/1") > -1:
					mod = true
				elif i.find("color=") > -1:
					color = i.split("=")[1]
				elif i.find("display-name") > -1:
					author = i.split("=")[1]
			
			var badges_string = "[img]res://widgets/twitch/moderator.png[/img]" if mod else ""
			var timestamp = "[color=#" + text_color.to_html(true) + "]" + str(OS.get_time()["hour"]).pad_zeros(2) + ":" + str(OS.get_time()["minute"]).pad_zeros(2) + "[/color] " if show_timestamps else ""
			var line_sep = " - " if compact_mode else "\n"
			
			chat_lines.append(timestamp + "[color=" + color + "]" + author + "[/color] " + badges_string + line_sep)
			chat_lines.append("[color=#" + text_color.to_html(true) + "]" + message + "[/color]\n\n")

			redraw_chat()
			
			SignalManager.emit_signal("event_happened")

# Redraws chat text in the richtextlabel
func redraw_chat():
	chat_lines.invert()
	chat_lines.resize(20)
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
