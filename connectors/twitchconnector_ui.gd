extends Control

var receiver : Node = null
var info : Dictionary = {}

func set_connection_info(info : Dictionary) -> void:
	self.info = info
	$VBoxContainer/MarginContainer/Token.text = info["token"]

func verify_connection(receiver : Node) -> void:
	self.receiver = receiver
	
	var headers : Array = [
		"User-Agent: VR Streaming Overlay/1.0 (Godot)",
		"Accept: application/json",
		"Authorization: Bearer " + $VBoxContainer/MarginContainer/Token.text
	]
	
	$HTTPRequest.connect("request_completed", self, "_on_twitch_verify", [], CONNECT_DEFERRED)
	var err = $HTTPRequest.request("https://api.twitch.tv/helix/users", headers, true, HTTPClient.METHOD_GET)
	assert(err==OK)

func _on_twitch_verify(result, response_code, headers, body) -> void:
	$HTTPRequest.disconnect("request_completed", self, "_on_twitch_verify")
	
	var userResponse : JSONParseResult = JSON.parse(body.get_string_from_utf8())

	if response_code == 200:
		var response = {
			"error": false,
			"name": userResponse.result["data"][0]["login"],
			"icon": load("res://connectors/twitchconnector.png"),
			"valid": true,
			"type": "twitch",
			"token": $VBoxContainer/MarginContainer/Token.text
		}
		
		if info:
			response["uuid"] = info["uuid"]

		receiver.connection_verified(response)
	else:
		var response : Dictionary
		
		if userResponse:
			response = {
				"error": true,
				"message": userResponse.result["message"],
				"valid": false
			}
		else:
			response = {
				"error": true,
				"message": "Temporary connection problem. Please verify your connection.",
				"valid": true
			}
		
		if info:
			response["uuid"] = info["uuid"]
		
		receiver.connection_verified(response)
