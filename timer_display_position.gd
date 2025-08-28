extends TextureProgressBar

# I dont fucking know man I'm just gonna do this because i dont understand how gui placement works in godot :wilted_flower:
func _ready() -> void:
	var interactable = get_parent().get_parent()
	global_position = interactable.global_position + Vector2(8.0, -42.0)
