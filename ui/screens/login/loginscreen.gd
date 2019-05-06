extends CenterContainer

func _ready():
	if PasswordStorage.has_password_file():
		$HBoxContainer/LeftMarginContainer/LeftVBoxContainer/Welcome.visible = false
		$HBoxContainer/LeftMarginContainer/LeftVBoxContainer/Back.visible = true

		$HBoxContainer/RightMarginContainer/RightVBoxContainer/RepeatPasswordOption.visible = false

func _on_LoginButton_pressed():
	if PasswordStorage.has_password_file():
		# Open file if possible
		if PasswordStorage.unlock_secret_file($HBoxContainer/RightMarginContainer/RightVBoxContainer/PasswordOption.get_value()):
			SignalManager.emit_signal("secrets_loaded")
		else:
			# Wrong password? Tell the user...
			var accept_dialog = AcceptDialog.new()
			accept_dialog.window_title = "Wrong password"
			accept_dialog.dialog_text = "I am sorry - this password was incorrect!"
				
			add_child(accept_dialog)	
			accept_dialog.popup_centered()
	else:
		# Check passwords aren't blank
		if $HBoxContainer/RightMarginContainer/RightVBoxContainer/PasswordOption.get_value().length() > 0:
			# Check passwords match and create a new file		
			if $HBoxContainer/RightMarginContainer/RightVBoxContainer/PasswordOption.get_value() == $HBoxContainer/RightMarginContainer/RightVBoxContainer/RepeatPasswordOption.get_value():
				PasswordStorage.create_new_secret_file($HBoxContainer/RightMarginContainer/RightVBoxContainer/PasswordOption.get_value())
				SignalManager.emit_signal("secrets_loaded")
			else:
				# Passwords do not match? Tell the user...
				var accept_dialog = AcceptDialog.new()
				accept_dialog.window_title = "Passwords do not match"
				accept_dialog.dialog_text = "The provided passwords do noth match! Please make sure they match!"
				
				add_child(accept_dialog)	
				accept_dialog.popup_centered()
		else:
			var accept_dialog = AcceptDialog.new()
			accept_dialog.window_title = "Passwords can not be empty"
			accept_dialog.dialog_text = "We can not create an encrypted file without password - please enter a password to use!"
				
			add_child(accept_dialog)	
			accept_dialog.popup_centered()

func _on_ForgotPasswordButton_pressed():
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.window_title = "Are you sure?"
	confirm_dialog.dialog_text = "Do you really want to remove the current encrypted file and create a new one?"
	confirm_dialog.connect("confirmed", self, "_on_encrypted_file_remove_confirm")
	
	add_child(confirm_dialog)	
	confirm_dialog.popup_centered()

func _on_encrypted_file_remove_confirm():
	$HBoxContainer/LeftMarginContainer/LeftVBoxContainer/Welcome.visible = true
	$HBoxContainer/LeftMarginContainer/LeftVBoxContainer/Back.visible = false

	$HBoxContainer/RightMarginContainer/RightVBoxContainer/RepeatPasswordOption.visible = true
	$HBoxContainer/RightMarginContainer/RightVBoxContainer/HBoxContainer/ForgotPasswordButton.visible = false
