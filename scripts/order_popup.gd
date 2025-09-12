extends Sprite2D

@onready var order_sprite = $Sprite2D

var success_texture = load("res://assets/ui/order_success.png")
var failure_texture = load("res://assets/ui/order_failure.png")

func _ready():
	clear_order()

func set_order(item_name):
	order_sprite.texture = Icons.items[item_name]
	visible = true

func clear_order():
	order_sprite.texture = null
	visible = false

func set_success(success):
	if success:
		order_sprite.texture = success_texture
	else:
		order_sprite.texture = failure_texture
