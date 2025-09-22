extends Area2D

class_name CustomerSlot

signal order_taken()
signal order_complete(success)
signal order_timeout()
signal update_score(score)
signal pause_spawns()
signal resume_spawns()
@onready var customer_sprite = $CustomerSprite
@onready var order_timer = $OrderTimer
@onready var order_popup = $OrderPopup
@onready var interact_popup = $InteractPopup
var distance_anchor
var order
var state: int = 0
var customer
var pausing
var dialogues
var time_limit
var score: int

func _ready():
	# Game freezing signals
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
	if not customer:
		return
	if body.has_method("add_interactable"):
		body.add_interactable(self)

# Remove a nearby interactable upon leaving its area
func _on_body_exited(body: Node):
	if body.has_method("remove_interactable"):
		body.remove_interactable(self)

# The closest interactable changed
func _on_closest_interactable_changed(target):
	if not customer:
		return
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

# Timer ran out
func _on_timeout():
	state = 0
	order = null
	score = -10
	emit_signal("order_timeout", false)
	order_timer.hide_timer()
	order_popup.set_success(false)
	emit_signal("update_score", score)
	clear_slot()

# Called when the user interacts with this customer
func interact():
	if state == 0:
		state = take_order()
	else:
		state = check_order()

# Set the slot's customer and order, and show the slot
func set_slot(slot):
	order = slot.get_order()
	customer = slot.get_customer()
	pausing = slot.get_pausing()
	dialogues = slot.get_dialogues()
	customer_sprite.texture = customer.get_sprite()
	customer_sprite.animate_spawn()
	if pausing:
		emit_signal("pause_spawns")

# Clear the slot's customer and order, and hide the slot
func clear_slot():
	if pausing:
		emit_signal("resume_spawns")
	customer_sprite.animate_despawn()
	order = null
	customer = null
	pausing = false
	interact_popup.visible = false

# Take an order upon first interaction
func take_order():
	if not customer:
		return 0
	emit_signal("order_taken")
	order_popup.set_order(order)
	print(customer.get_effects()["time_multiplier"])
	time_limit = 60 * customer.get_effects()["time_multiplier"]
	order_timer.start(time_limit)
	order_timer.show_timer()
	return 1

# Complete an order upon second interaction for success or failure
func check_order():
	if not customer or not Inventory.has_item():
		return 1
	order_timer.stop()
	order_timer.hide_timer()
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
	clear_slot()
	return 0

# Calculate score based on time remaining
func calculate_score(remaining_time: float, multiplier: float) -> int:
	var elapsed_time: float = time_limit - remaining_time
	if elapsed_time <= 20.0:
		return 100
	var raw_score: float = 100.0 * remaining_time / max(time_limit - 20.0, 1.0)
	return int(clamp(raw_score, 10.0, 100.0) * multiplier)

# Game froze
func freeze():
	order_timer.paused = true

# Game unfroze
func unfreeze():
	order_timer.paused = false
