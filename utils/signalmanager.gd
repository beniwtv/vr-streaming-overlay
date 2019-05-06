extends Node

# Fired when password file was loaded
signal secrets_loaded

# Fired when we know the texture size to render, so overlay can resize properly
signal render_targetsize

# Fired when VR and overlay are initialized
signal vr_init

# Fired when the user changed settings, causes overlay to reinit
signal settings_changed

# Fired when options in a widget are changed, causes the redray_overlay to fire
signal options_changed

# Fired if the overlay needs to be redrawn
signal redraw_overlay

# TEMP for Twitch oauth
signal oauth_changed
