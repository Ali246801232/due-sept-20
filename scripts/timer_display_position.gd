extends TextureProgressBar

func _ready():
	global_position = get_parent().get_parent().global_position + Vector2(8.0, -42.0)  # idfk man
