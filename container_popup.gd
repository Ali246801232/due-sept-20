extends Sprite2D

func _ready():
	global_position = get_parent().global_position + Vector2(0.0, -70.0)  # idfk man

func set_slots(ingredients):
	$Slot1.texture = Icons.ingredients[ingredients[0]]
	$Slot2.texture = Icons.ingredients[ingredients[1]]
	$Slot3.texture = Icons.ingredients[ingredients[2]]
	$Slot4.texture = Icons.ingredients[ingredients[3]]
