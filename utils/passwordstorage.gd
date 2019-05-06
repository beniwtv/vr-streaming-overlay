extends Node

# Variable to store secrets while running
var saved_secrets = {}

# Path to the file that stores the passwords
var encypted_file = "user://encrypted.ini"

# Holds the password while running
var user_password

# Used to save when no properties are being changed (debouncing).
# This way, secrets can be preserved in case of a crash
onready var save_timer := $SaveTimer as Timer

# Checks if the secret file already exists for the user
func has_password_file():
	var file = File.new()	
	return file.file_exists(encypted_file)

# Unlocks and loads the secret file
func unlock_secret_file(password):
	var file = File.new()
	var err = file.open_encrypted_with_pass(encypted_file, File.READ, password)

	if err != OK:
		return false
		
	saved_secrets = file.get_var()
	file.close()
	
	user_password = password
	
	return true

# Creates a new secret file with the password provided
func create_new_secret_file(password):
	user_password = password
	return save()

# Seta a secret to the password file
func set_secret(key, value):
	saved_secrets[key] = value
	save_timer.start()

# Returns a secred from the password file
func get_secret(key):
	if saved_secrets.has(key):
		return saved_secrets[key]
	else:
		return null

# Saves secret file
func save():
	var file = File.new()
	var err = file.open_encrypted_with_pass(encypted_file, File.WRITE, user_password)

	if err != OK:
		return false

	file.store_var(saved_secrets)
	file.close()
	
	return true

func _exit_tree():
	# Always save secret file when quitting the project
	save()
