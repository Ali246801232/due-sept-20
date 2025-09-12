extends Area2D

class_name CustomerSlot

signal order_taken()
signal order_complete(success)
signal timer_ended
signal update_score(score)
@onready var customer_sprite = $CustomerSprite
@onready var order_timer = $OrderTimer
@onready var order_popup = $OrderPopup
@onready var interact_popup = $InteractPopup
var distance_anchor
var order: String = ""
var state: int = 0
var customer
var time_limit
var score

# Called when the node enters the scene tree for the first time.
func _ready():
	Freeze.connect("frozen", Callable(self, "freeze"))
	Freeze.connect("unfrozen", Callable(self, "unfreeze"))

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
	
	order_timer.connect("timeout", Callable(self, "_on_timeout"))
	
	distance_anchor = position

# Add a nearby interactable upon entering its area
func _on_body_entered(body: Node):
	if body.has_method("add_interactable"):
		body.add_interactable(self)

# Remove a nearby interactable upon leaving its area
func _on_body_exited(body: Node):
	if body.has_method("remove_interactable"):
		body.remove_interactable(self)

# The closest interactable changed
func _on_closest_interactable_changed(target):
	if target == self:
		interact_popup.visible = true
	else:
		interact_popup.visible = false

# Some interaction happened
func _on_interaction(target):
	if Freeze.is_frozen:
		return
	if target == self:
		interact()

# Called when the user interacts with this customer
func interact():
	if state == 0:
		state = take_order()
	else:
		state = check_order()

func set_customer(customer_name):
	customer = Customers.get_customer(customer_name)
	customer_sprite.texture = customer.get_sprite()

func set_random_order():
	order = customer.get_random_order()

func take_order():
	if not customer:
		return 0
	set_random_order()
	order_popup.set_order(order)
	emit_signal("order_taken")

	time_limit = 90 * customer.get_effects()["time_multiplier"]
	order_timer.start(time_limit)
	return 1

func check_order():
	if not customer:
		return 1
	order_timer.stop()
	var inventory = Inventory.get_inventory()
	Inventory.set_inventory(Inventory.get_empty())
	if inventory["item"] == order:
		emit_signal("order_complete", true)
		order_popup.set_success(true)
		score = calculate_score(order_timer.time_left, customer.get_effects()["score_multiplier"])
	else:
		emit_signal("order_complete", false)
		order_popup.set_success(false)
		score = -10
	emit_signal("update_score", score)
	return 0

func _on_timeout():
	state = 0
	order = ""
	score = -10
	emit_signal("timer_ended")
	order_popup.set_success(false)
	emit_signal("update_score", score)

# Calculate score based on time remaining
func calculate_score(remaining_time: float, multiplier: float) -> int:
	var elapsed_time: float = time_limit - remaining_time
	if elapsed_time <= 20.0:
		return 100
	var raw_score: float = 100.0 * remaining_time / max(time_limit - 20.0, 1.0)
	return int(clamp(raw_score, 10.0, 100.0) * multiplier)

func freeze():
	order_timer.paused = true

func unfreeze():
	order_timer.paused = false
