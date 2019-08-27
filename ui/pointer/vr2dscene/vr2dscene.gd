extends Control

func _ready() -> void:
	SignalManager.connect("render_targetsize", self, "_on_render_targetsize_changed")

func _on_render_targetsize_changed(size : Vector2) -> void:
	rect_size = size
	$VRBackground.rect_size = size
