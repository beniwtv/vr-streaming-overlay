# Copyright © 2018-2019 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node

# Define as many configuration files as you want here.
# The one containing video-related settings should be assigned to
# `application/override/project_settings_override` in the Project Settings,
# so that its settings can be effective when overriding built-in settings
# such as the directional shadow size.
var config_files := {
	system = {
		path = "user://system.ini",
	},
	user = {
		path = "user://user.ini",
	},
	cache = {
		path = "user://cache.ini",
	},
}

# Used to save when no properties are being changed (debouncing).
# This way, settings can be preserved in case of a crash
onready var save_timer := $SaveTimer as Timer

func _ready() -> void:
	# Load all configuration files
	for key in config_files:
		var config_file: Dictionary = config_files[key]
		config_file.config = ConfigFile.new()
		config_file.config.load(config_file.path)

# Splits a single key string into a section and key.
# This way, users can benefit from an API closer to ProjectSettings.
func _split_section_key(key: String) -> Dictionary:
	var section_key := key.split("/", true, 1)

	# A section is required, as ConfigFile does not permit saving keys in the "root" section
	if section_key.size() != 2:
		push_error('The key must be prefixed with a section (denoted using a "/" character).')
		assert(false)

	return {
		section = section_key[0],
		key = section_key[1],
	}

# Deletes the specified section along with all the key-value pairs inside
# in the given configuration file.
func erase_section(file: String, section: String) -> void:
	config_files[file].config.erase_section(section)

# Returns an array of all defined key identifiers in the specified section
# of the given configuration file.
func get_section_keys(file: String, section: String) -> PoolStringArray:
	return config_files[file].config.get_section_keys(section)

# Returns an array of all defined section identifiers in the given
# configuraton file.
func get_sections(file: String) -> PoolStringArray:
	return config_files[file].config.get_sections()

# Returns a value from the given configuration file.
# The section is inferred from the first key fragment, e.g.
# `player/color` will get the value of the `color` value
# in the `player` section.
# If no default value is specified, then this function will look in the
# Project Settings for the key (prefixed by "defaults/"). This way,
# default values can be centralized, preventing duplication in scripts.
func get_value(file: String, key: String, default = null):
	var section_key := _split_section_key(key)

	# Fetch default value from Project Settings if no default value was supplied
	if default == null:
		default = ProjectSettings.get_setting("defaults/" + key)

	return config_files[file].config.get_value(
			section_key.section,
			section_key.key,
			default
	)

# Returns `true` if the key exists in the given configuration file.
# The section is inferred from the first key fragment, e.g.
# `player/color` will get the value of the `color` value
# in the `player` section.
func has_section(file: String, section: String):
	return config_files[file].config.has_section(section)

# Returns `true` if the key exists in the given configuration file.
# The section is inferred from the first key fragment, e.g.
# `player/color` will get the value of the `color` value
# in the `player` section.
func has_section_key(file: String, key: String):
	var section_key := _split_section_key(key)

	return config_files[file].config.has_section_key(
			section_key.section,
			section_key.key
	)

# Sets a value in the given configuration file.
# The section is inferred from the first key fragment, e.g.
# `player/color` will get the value of the `color` value
# in the `player` section.
func set_value(file: String, key: String, value) -> void:
	var section_key := _split_section_key(key)

	config_files[file].config.set_value(
			section_key.section,
			section_key.key,
			value
	)

	save_timer.start()

# Saves configuration files with predefined paths.
# This method should be used over `Settings.file.save(path)`
# unless a custom path needs to be specified.
func save() -> void:
	for key in config_files:
		var config_file: Dictionary = config_files[key]
		config_file.config.save(config_file.path)

func _exit_tree() -> void:
	# Always save configuration files when quitting the project
	save()
