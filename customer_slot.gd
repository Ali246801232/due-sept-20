extends Area2D

class_name CustomerSlot

@onready var order_timer = $OrderTimer
@onready var order_popup = $OrderPopup
var order: String

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect player interaction signal
	var player = get_tree().current_scene.get_node("Player")
	if player:
		player.connect("interacted", Callable(self, "_on_interaction"))
		player.connect("closest_interactable_changed", Callable(self, "_on_closest_interactable_changed"))

	# Connect Area2D signals
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))

func interact():
	pass

func set_customer(customer_name):
	pass

func set_random_customer():
	customers


func take_order():
	pass
