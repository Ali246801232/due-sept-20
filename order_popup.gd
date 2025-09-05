extends Sprite2D

@onready var order_sprite = $Sprite2D

func _ready():
	clear_order()

func set_order(item_name):
	order_sprite.texture = Icons.items[item_name]
	visible = true

func clear_order():
	order_sprite.texture = null
	visible = false
