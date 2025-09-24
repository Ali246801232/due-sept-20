extends Sprite2D

func _ready():
	global_position = get_parent().global_position + Vector2(0.0, -70.0)  # idfk man

func set_slots(ingredients):
	$Slot1.texture = Icons.items.get(ingredients[0], null)
	$Slot2.texture = Icons.items.get(ingredients[1], null)
	$Slot3.texture = Icons.items.get(ingredients[2], null)
	$Slot4.texture = Icons.items.get(ingredients[3], null)
