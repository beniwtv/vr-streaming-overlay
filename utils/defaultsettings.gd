extends Node

var UUID = preload("res://addons/godot-uuid/uuid.gd")

# General settings
var overlay_hand = 2
var overlay_color = Color(0, 0, 0)
var overlay_opacity = 0.8
var overlay_origin = 1
var overlay_dimundim = true
var overlay_dimdownopacity = 0.4
var overlay_dimdownafter = 30
var overlay_undimchime = true
var overlay_chimedevice = "Default"
var overlay_undimstare = true
var overlay_undimstareseconds = 5

# Overlay position / rotation
var overlay_size = 1.5

var overlay_position_x = 0
var overlay_position_y = 0
var overlay_position_z = -1.4

var overlay_rotation_x = 0
var overlay_rotation_y = 0
var overlay_rotation_z = 0

# Default settings for widgets
var margin_container_margin_top = 10
var margin_container_margin_left = 10
var margin_container_margin_right = 10
var margin_container_margin_bottom = 10

# Default margin + Twitch chat widget
var parent_id : String = UUID.v4()
var twitch_id : String = UUID.v4()

var widgets_configuration : Array = [{
	"data": {
		"config": {
			"ratio": 1,
			"margin_top": 10,
			"margin_left": 10,
			"margin_right": -10,
			"margin_bottom": -10
		},
		"display_name": "Margin container",
		"id": parent_id,
		"option_scene": "res://widgets/margincontainer_options.tscn",
		"parent": null,
		"widget": "res://widgets/margincontainer.gd"
	},
	"id": parent_id,
	"position": "m"
},{
	"data": {
		"config": {
			"ratio": 1,
			"text_color": Color(255, 255, 255),
			"show_timestamps": false
		},
		"display_name": "Twitch chat",
		"id": twitch_id,
		"option_scene": "res://widgets/twitch/twitchchat_options.tscn",
		"parent": parent_id,
		"widget": "res://widgets/twitchchat.gd"
	},
	"id": twitch_id,
	"position": "m:m"
}]

func get_default_setting(setting):
	var settingParts = setting.split("/", setting)
	var varname = settingParts.join("_")

	return get(varname)
