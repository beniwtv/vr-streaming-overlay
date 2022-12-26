extends Control

var receiver : Node = null
var info : Dictionary = {}

func set_connection_info(info : Dictionary) -> void:
	self.info = info
	if info.has("url"): $VBoxContainer/MarginContainerURL/URL.text = info["url"]
	if info.has("username"): $VBoxContainer/MarginContainerUsername/Username.text = info["username"]
	if info.has("password"): $VBoxContainer/MarginContainerPassword/Password.text = info["password"]

func verify_connection(receiver : Node) -> void:
	self.receiver = receiver
	
	var headers : Array = [
		"User-Agent: VR Streaming Overlay/1.0 (Godot)",
		"Accept: application/json",
		"Authorization: Basic " + Marshalls.utf8_to_base64($VBoxContainer/MarginContainerUsername/Username.text + ":" + $VBoxContainer/MarginContainerPassword/Password.text)
	]
	
	# Check if there is a user for us
	$HTTPRequest.connect("request_completed", self, "_on_owncast_check_tokens", [], CONNECT_DEFERRED)
	var err = $HTTPRequest.request($VBoxContainer/MarginContainerURL/URL.text + "/api/admin/accesstokens", headers, true, HTTPClient.METHOD_GET)
	assert(err==OK)

func _on_owncast_check_tokens(result, response_code, headers, body) -> void:
	$HTTPRequest.disconnect("request_completed", self, "_on_owncast_check_tokens")
	var tokensResponse : JSONParseResult = JSON.parse(body.get_string_from_utf8())

	if response_code == 200:
		if typeof(tokensResponse.result) == TYPE_ARRAY:
			var foundtoken = null
			
			for token in tokensResponse.result:
				if token["displayName"] == "VR Streaming Overlay":
					foundtoken = token
			
			if !foundtoken:
				# Create a new user for us
				var sendheaders : Array = [
					"User-Agent: VR Streaming Overlay/1.0 (Godot)",
					"Accept: application/json",
					"Authorization: Basic " + Marshalls.utf8_to_base64($VBoxContainer/MarginContainerUsername/Username.text + ":" + $VBoxContainer/MarginContainerPassword/Password.text)
				]
				
				var sendbody = to_json({"name": "VR Streaming Overlay", "scopes": []})
	
				$HTTPRequest.connect("request_completed", self, "_on_owncast_create_token", [], CONNECT_DEFERRED)
				var err = $HTTPRequest.request($VBoxContainer/MarginContainerURL/URL.text + "/api/admin/accesstokens/create", sendheaders, true, HTTPClient.METHOD_POST, sendbody)
				assert(err==OK)
			else:
				var response = {
					"error": false,
					"name": foundtoken["displayName"],
					"icon": load("res://connectors/owncastconnector.png"),
					"valid": true,
					"type": "owncast",
					"url": $VBoxContainer/MarginContainerURL/URL.text,
					"username": $VBoxContainer/MarginContainerUsername/Username.text,
					"password": $VBoxContainer/MarginContainerPassword/Password.text,
					"accessToken": foundtoken["accessToken"]
				}
		
				if info:
					response["uuid"] = info["uuid"]
		
				receiver.connection_verified(response)
		else:
			var response : Dictionary
			
			response = {
				"error": true,
				"message": "Could not parse response: " + body.get_string_from_utf8(),
				"valid": true
			}
			
			if info:
				response["uuid"] = info["uuid"]
			
			receiver.connection_verified(response)
	else:
		var response : Dictionary
		
		if tokensResponse:
			response = {
				"error": true,
				"message": tokensResponse.result["message"],
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

func _on_owncast_create_token(result, response_code, headers, body) -> void:
	$HTTPRequest.disconnect("request_completed", self, "_on_owncast_create_token")
	var tokenResponse : JSONParseResult = JSON.parse(body.get_string_from_utf8())
	
	if response_code == 200:
		var response = {
			"error": false,
			"name": tokenResponse.result["displayName"],
			"icon": load("res://connectors/owncastconnector.png"),
			"valid": true,
			"type": "owncast",
			"url": $VBoxContainer/MarginContainerURL/URL.text,
			"username": $VBoxContainer/MarginContainerUsername/Username.text,
			"password": $VBoxContainer/MarginContainerPassword/Password.text,
			"accessToken": tokenResponse.result["accessToken"]
		}
		
		if info:
			response["uuid"] = info["uuid"]
		
		receiver.connection_verified(response)

func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(meta)
