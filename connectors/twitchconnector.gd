extends "res://connectors/baseconnector.gd"

var display_name : String = "Twitch"
var tooltip : String = "Connector to connect to the Twitch API / IRC chat"
var icon : StreamTexture = preload("res://connectors/twitchconnector.png")
var type : String = "twitch"

var scene : String = "res://connectors/twitchconnector_ui.tscn"
