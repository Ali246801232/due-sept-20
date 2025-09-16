extends Sprite2D

@onready var order_sprite = $Sprite2D
@onready var success_timer = $SuccessTimer

var success_texture = load("res://assets/ui/order_success.webp")
var failure_texture = load("res://assets/ui/order_failure.webp")

func _ready():
	# Game freezing signals
	Freeze.connect("frozen", Callable(self, "freeze"))
	Freeze.connect("unfrozen", Callable(self, "unfreeze"))

	clear_order()
	success_timer.connect("timeout", Callable(self, "clear_order"))

func set_order(item_name):
	order_sprite.texture = Icons.items[item_name]
	visible = true
	success_timer.stop()

func clear_order():
	order_sprite.texture = null
	visible = false
	success_timer.stop()

func set_success(success):
	if success:
		order_sprite.texture = success_texture
	else:
		order_sprite.texture = failure_texture
	if not success_timer.is_stopped():
		success_timer.stop()
	success_timer.start(2.0)

func freeze():
	success_timer.paused = true

func unfreeze():
	success_timer.paused = false
