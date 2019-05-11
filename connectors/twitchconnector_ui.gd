extends Control

var receiver = null
var info = null

func set_connection_info(info):
	self.info = info
	$VBoxContainer/Token.text = info["token"]

func verify_connection(receiver):
	self.receiver = receiver
	
	var headers = [
		"User-Agent: VR Streaming Overlay/1.0 (Godot)",
		"Accept: application/json",
		"Authorization: Bearer " + $VBoxContainer/Token.text
	]
	
	$HTTPRequest.connect("request_completed", self, "_on_twitch_verify")
	var err = $HTTPRequest.request("https://api.twitch.tv/helix/users", headers, true, HTTPClient.METHOD_GET)
	assert(err==OK)

func _on_twitch_verify(result, response_code, headers, body):
	$HTTPRequest.disconnect("request_completed", self, "_on_twitch_verify")
	
	var userResponse = JSON.parse(body.get_string_from_utf8())
	assert(userResponse.error==OK)

	if response_code == 200:
		var response = {
			"error": false,
			"name": userResponse.result["data"][0]["login"],
			"icon": load("res://connectors/twitchconnector.png"),
			"valid": true,
			"type": "twitch",
			"token": $VBoxContainer/Token.text
		}
		
		if info:
			response["uuid"] = info["uuid"]
		
		receiver.connection_verified(response)
	else:
		var response = {
			"error": true,
			"message": userResponse.result["message"],
			"valid": false
		}
		
		if info:
			response["uuid"] = info["uuid"]
		
		receiver.connection_verified(response)