extends "res://connectors/baseconnector.gd"

var display_name : String = "Owncast"
var tooltip : String = "Connector to connect to the Owncast API / chat"
var icon : StreamTexture = preload("res://connectors/owncastconnector.png")
var type : String = "owncast"

var scene : String = "res://connectors/owncastconnector_ui.tscn"
