extends Node

@onready var spawn_timer: Timer = $SpawnTimer
@onready var day_transition: CanvasLayer = $DayTransition

var slots: Array = []
var active: Array = []
var day_index = -1
var customer_index = 0
var day_customers: Array
var spawn_interval: float = 2.0
var spawning_paused: bool = false

# Class to store what will go in a customer slot, really should rename this to something else to avoid confusion
class Slot:
	var _order
	var _customer_name
	var _customer
	var _dialogues
	var _pausing
	var random_filters = ["_RANDOM_COOKIES_", "_RANDOM_BREAD_", "_RANDOM_NORMAL_"]
	var valid_orders = [
		{"name": "Plain Cookies", "filters": ["_RANDOM_COOKIES_", "_RANDOM_NORMAL_"]},
		{"name": "Sugar Cookies", "filters": ["_RANDOM_COOKIES_", "_RANDOM_NORMAL_"]},
		{"name": "Chocolate Chip Cookies", "filters": ["_RANDOM_COOKIES_", "_RANDOM_NORMAL_"]},
		{"name": "Butter Cookies", "filters": ["_RANDOM_COOKIES_", "_RANDOM_NORMAL_"]},
		{"name": "Cheese Cookies", "filters": ["_RANDOM_COOKIES_", "_RANDOM_NORMAL_"]},
		{"name": "Mixed Nut Cookies", "filters": ["_RANDOM_COOKIES_", "_RANDOM_NORMAL_"]},
		{"name": "Chocolate Crinkles", "filters": ["_RANDOM_COOKIES_", "_RANDOM_NORMAL_"]},
		{"name": "Ube Crinkles", "filters": ["_RANDOM_COOKIES_", "_RANDOM_NORMAL_"]},
		{"name": "Banana Bread", "filters": ["_RANDOM_BREAD_", "_RANDOM_NORMAL_"]},
		{"name": "Coco Bread", "filters": ["_RANDOM_BREAD_", "_RANDOM_NORMAL_"]},
		{"name": "Pandesal", "filters": ["_RANDOM_BREAD_", "_RANDOM_NORMAL_"]},
		{"name": "Cheese Pandesal", "filters": ["_RANDOM_BREAD_", "_RANDOM_NORMAL_"]},
		{"name": "Ube Pandesal", "filters": ["_RANDOM_BREAD_", "_RANDOM_NORMAL_"]},
		{"name": "Milk", "filters": []},
		{"name": "Eggs", "filters": []},
		{"name": "Cake Box", "filters": []}
	]
	
	func _init(order: String, customer_name: String, pausing: bool = false):
		set_order(order)
		_customer_name = customer_name
		_pausing = pausing

	# Set the order from a name or randomly with a filter
	func set_order(order):
		if valid_orders.any(func(valid_order): return valid_order["name"] == order):
			_order = order
			return
		assert(order in random_filters, "Invalid order: %s" % order)
		var filtered = []
		for valid_order in valid_orders:
			if order in valid_order["filters"]:
				filtered.append(valid_order["name"])
		assert(filtered.size() > 0, "No orders matching random filter: %s" % order)
		_order = filtered[randi_range(0, filtered.size() - 1)]

	# Set the customer
	func set_customer(existing):
		_customer = Customers.get_customer(_customer_name, existing)

	# Set the dialogues (pre-order and post-order)
	func set_dialogues():
		var suffix = _customer.get_name().to_lower()
		_dialogues = [
			"dialogue_take_order_" + suffix,
			"dialogue_success_" + suffix,
			"dialogue_failure_" + suffix,
			"dialogue_timeout_" + suffix
		]

	func is_random():
		return _customer_name in random_filters

	func get_order():
		return _order

	func get_customer():
		return _customer

	func get_dialogues():
		return _dialogues
	
	func get_pausing():
		return _pausing


func _ready() -> void:
	# Game freezing signals
	Freeze.connect("frozen", Callable(self, "freeze"))
	Freeze.connect("unfrozen", Callable(self, "unfreeze"))
	
	# Get and store all customer slots
	for child in get_children():
		if child is CustomerSlot:
			slots.append(child)
			active.append(false)
	assert(slots.size() > 0, "There must be at least one CustomerSlot node")

	# Connect signals for each slot
	for index in range(slots.size()):
		var slot = slots[index]
		slot.connect("order_taken", Callable(self, "_on_order_taken").bind(index))
		slot.connect("order_complete", Callable(self, "_on_order_complete").bind(index))
		slot.connect("timer_ended", Callable(self, "_on_order_timeout").bind(index))
		slot.connect("pause_spawns", Callable(self, "_on_pause_spawns"))
		slot.connect("resume_spawns", Callable(self, "_on_resume_spawns"))
	spawn_timer.timeout.connect(Callable(self, "spawn_customer"))
	
	# All customers
	Customers.new_customer("Ali", {"effects": {"time_multiplier": 0.5}, "allow_random": false})
	Customers.new_customer("Kenz", {"effects": {"time_multiplier": 1.50}, "allow_random": false, "manual_first": true})
	Customers.new_customer("Miku", {"effects": {"hide_recipes": true}, "allow_random": false})
	Customers.new_customer("Mordekaiser", {"allow_random": false})
	Customers.new_customer("Kraze", {"effects": {"time_multipler": 0.5}, "allow_random": false, "manual_first": true})
	Customers.new_customer("Melan", {"allow_random": false, "manual_first": true})
	Customers.new_customer("Carton", {"allow_random": false, "manual_first": true})
	Customers.new_customer("Chekered", {"allow_random": false, "manual_first": true})
	Customers.new_customer("Soda", {})
	Customers.new_customer("Rev", {})
	Customers.new_customer("Kaori", {})
	Customers.new_customer("Ash", {})
	Customers.new_customer("Cake Box", {"time_multiplier": 1000, "allow_random": false})

	day_customers = [
		[Slot.new("Sugar Cookies", "Kraze")],
		[Slot.new("Cheese Pandesal", "Melan")],
		[Slot.new("Cheese Pandesal", "Melan")],
		[Slot.new("Cheese Pandesal", "Melan")],
		[Slot.new("Cheese Pandesal", "Melan")],
		[Slot.new("Cheese Pandesal", "Melan")]
	]

	#day_customers = [
		#[
			#Slot.new("Chocolate Chip Cookies", "Ali", true),
			#Slot.new("_RANDOM_COOKIES_", "_RANDOM_"),
			#Slot.new("_RANDOM_COOKIES_", "_RANDOM_"),
			#Slot.new("_RANDOM_COOKIES_", "_RANDOM_"),
			#Slot.new("_RANDOM_COOKIES_", "_RANDOM_")
		#],
		#[
			#Slot.new("Cheese Pandesal", "Melan", true),
			#Slot.new("_RANDOM_BREAD_", "_RANDOM_"),
			#Slot.new("_RANDOM_BREAD_", "_RANDOM_"),
			#Slot.new("_RANDOM_BREAD_", "_RANDOM_"),
			#Slot.new("_RANDOM_COOKIES_", "_RANDOM_")
		#],
		#[
			#Slot.new("_RANDOM_NORMAL_", "_RANDOM_"),
			#Slot.new("Cheese Cookies", "Kraze"),
			#Slot.new("_RANDOM_NORMAL_", "_RANDOM_"),
			#Slot.new("_RANDOM_NORMAL_", "Kenz"),
			#Slot.new("_RANDOM_NORMAL_", "_RANDOM_")
		#],
		#[
			#Slot.new("_RANDOM_BREAD_", "Miku"),
			#Slot.new("_RANDOM_NORMAL_", "_RANDOM_"),
			#Slot.new("_RANDOM_NORMAL_", "_RANDOM_"),
			#Slot.new("_RANDOM_NORMAL_", "_RANDOM_"),
			#Slot.new("_RANDOM_COOKIES_", "Mordekaiser"),
			#Slot.new("_RANDOM_NORMAL_", "_RANDOM_")
		#],
		#[
			#Slot.new("_RANDOM_NORMAL_", "_RANDOM_"),
			#Slot.new("Eggs", "Chekered"),
			#Slot.new("_RANDOM_NORMAL_", "_RANDOM_"),
			#Slot.new("_RANDOM_NORMAL_", "_RANDOM_"),
			#Slot.new("Milk", "Carton"),
			#Slot.new("_RANDOM_NORMAL_", "_RANDOM_")
		#],
		#[
			#Slot.new("Cake Box", "Cake Box")
		#]
	#]

# Spawn the next customer in a random empty slot, every once in a while
func spawn_customer():
	# Attempt to find a valid slot index
	if day_index > day_customers.size() - 1 or customer_index > day_customers[day_index].size() - 1 or spawning_paused:
		return
	var inactive_indices := []
	for i in range(active.size()):
		if not active[i]:
			inactive_indices.append(i)
	if inactive_indices.is_empty():
		return
	var slot_index = inactive_indices[randi() % inactive_indices.size()]

	# Spawn the next customer in the chosen slot
	set_slot(slot_index)
	active[slot_index] = true
	customer_index += 1
	spawn_timer.wait_time = randf_range(0.75*spawn_interval, 1.25*spawn_interval)
	spawn_timer.start()

# Start a day by spawning the first customer
func start_day():
	await get_tree().create_timer(0.5).timeout
	Dialogue.run_sequence("dialogue_day%d_start" % (day_index + 1))
	spawn_customer()


# Increment the day count
func next_day():
	if day_index > day_customers.size() - 1:
		Dialogue.run_sequence("ending_cutscene")
		return
	Dialogue.run_sequence("dialogue_day%d_end" % (day_index  + 1))
	day_index += 1
	customer_index = 0
	spawn_timer.stop()
	day_transition.transition_day(day_index)
	start_day()

func _on_order_taken(slot_index):
	Dialogue.run_sequence(slots[slot_index].dialogues[0])

func _on_order_complete(success, slot_index):
	if success:
		Dialogue.run_sequence(slots[slot_index].dialogues[1])
	else:
		Dialogue.run_sequence(slots[slot_index].dialogues[2])
	active[slot_index] = false
	if customer_index > day_customers[day_index].size()  - 1 and slots_empty():
		next_day()

func _on_timer_ended(slot_index):
	active[slot_index] = false
	Dialogue.run_sequence(slots[slot_index].dialogues[3])
	if customer_index > day_customers[day_index].size() - 1 and slots_empty():
		next_day()

func set_slot(slot_index):
	var existing = []
	for slot in slots:
		if slot.customer:
			existing.append(slot.customer.get_name())
	var customer = day_customers[day_index][customer_index]
	customer.set_customer(existing)
	if not customer.is_random():
		customer.set_dialogues()
	slots[slot_index].set_slot(customer)

func slots_empty():
	for slot in active:
		if slot:
			return false
	return true

func _on_pause_spawns():
	if not spawning_paused:
		spawn_timer.stop()
	spawning_paused = true

func _on_resume_spawns():
	if spawning_paused:
		spawn_customer()
	spawning_paused = false

func freeze():
	spawn_timer.paused = true

func unfreeze():
	spawn_timer.paused = false

func _on_resetted(day):
	for slot in slots:
		slot.clear_slot()
	day_index = -1
