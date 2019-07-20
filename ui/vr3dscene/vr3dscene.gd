extends Spatial

var delay = 0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if delay > 500:
		delay = 0
		print(ARVRServer.get_hmd_transform())

	delay = delay + 1