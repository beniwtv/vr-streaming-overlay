extends HBoxContainer

func apply_config(widget_id, config):
	if config.has("ratio"): size_flags_stretch_ratio = config["ratio"]
