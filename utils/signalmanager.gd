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

# Fired from widgets when an interesting event happened
signal event_happened

# Fired when an interesting event happened
signal event_happened_silent

# Fired when a new overlay is requested to be added to OpenVR
signal overlay_add

# Fired when a overlay is requested to be removed from OpenVR
signal overlay_remove

# Fired when a overlay needs to be hidden/shown
signal overlay_visibility_toggle
