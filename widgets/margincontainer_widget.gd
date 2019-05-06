extends MarginContainer

func apply_config(widget_id, config):

	if config.has("ratio"): size_flags_stretch_ratio = config["ratio"]
	if config.has("margin_top"): margin_top = config["margin_top"]
	if config.has("margin_left"): margin_left = config["margin_left"]
	if config.has("margin_right"): margin_right = config["margin_right"]
	if config.has("margin_bottom"): margin_bottom = config["margin_bottom"]
