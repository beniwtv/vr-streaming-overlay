extends RichTextLabel

var irc_stream = null
var irc_joined = false
var chat_lines = PoolStringArray()
var nick = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	# Prepare our chat lines array
	chat_lines.append("\n")
	
	SignalManager.connect("oauth_changed", self, "connect_to_twitch")
	SignalManager.connect("settings_changed", self, "_on_settings_changed")	

	nick = SettingsManager.get_value("user", "twitchchat/nick", "")

func _on_settings_changed():
	nick = SettingsManager.get_value("user", "twitchchat/nick", "")

func connect_to_twitch(chat_token):
	clear()
	append_bbcode("CONNECTING... ")
	
	irc_stream = StreamPeerTCP.new()	
	var err = irc_stream.connect_to_host("irc.chat.twitch.tv", 6667)
	
	if (err!=OK):
		# Make sure we could connect to Twitch
		clear()
		append_bbcode("ERROR! VERIFY CONNECTION TO INTERNET")
	
	while irc_stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		OS.delay_msec(500)
	
	irc_stream.put_data(("PASS oauth:" + chat_token + "\n").to_utf8())
	irc_stream.put_data(("NICK " + nick + "\n").to_utf8())
	
	print(nick)
	
	# Request advanced tags from Twitch
	irc_stream.put_data(("CAP REQ :twitch.tv/tags\n").to_utf8())
	
	# Join our channel to monitor
	irc_stream.put_data(("JOIN #" + nick + "\n").to_utf8())
	
	irc_joined = true
	append_bbcode("READY!")
	
func _process(delta):
	# Check for new messages in IRC
	if irc_joined and irc_stream.get_available_bytes() > 0:
		var line = irc_stream.get_utf8_string(irc_stream.get_available_bytes())
		parse_irc_line(line)	

func parse_irc_line(lines):
	lines = lines.split('\n')
	
	for line in lines:
		print(line)
		var parts = line.split(' ')

		if parts.size() > 1:
			if parts[0] == "PING":
				irc_stream.put_data(("PONG " + str(parts[1]) + "\n").to_utf8())
			elif parts[2] == "PRIVMSG":
				var message = ""

				for i in range (4, parts.size()):
					message += parts[i] + " "
			
				message = message.substr(1, message.length()-1)
				var tagParts = parts[0].split(";")
				var badges = Array(tagParts[0].split("=")[1].split(","))
				var mod = true if badges.find("moderator/1") > -1 or badges.find("broadcaster/1") > -1 else false
				var color = tagParts[1].split("=")[1]
				var author = tagParts[2].split("=")[1]

				if author != "StageSmasher":
					var badges_string = "[img]res://widgets/twitch/moderator.png[/img]" if mod else ""

					chat_lines.append("[color=" + color + "]" + author + "[/color] " + badges_string + "\n")
					chat_lines.append(message + "\n\n")	

					chat_lines.invert()
					chat_lines.resize(20)
					chat_lines.invert()
	
					clear()
					append_bbcode(chat_lines.join(""))
					
