extends Control

func _ready():
	SignalManager.connect("render_targetsize", self, "_on_render_targetsize_changed")
	
func _on_render_targetsize_changed(size):
	rect_size = size
