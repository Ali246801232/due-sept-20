extends Node

var slots: Array = []
var active: Array = []
@onready var spawn_timer: Timer = $SpawnTimer
var spawn_interval: float = 10.0

var day_index = 0
var customer_index = 0
var day_customers = [
	
	["Ali", "_RANDOM_COOKIES_", "_RANDOM_COOKIES_", "_RANDOM_COOKIES_", "_RANDOM_COOKIES_"],
	["_RANDOM_COOKIES_", "Melan", "_RANDOM_BREAD_", "_RANDOM_BREAD_", "_RANDOM_BREAD_"],
	["_RANDOM_NORMAL_", "_RANDOM_NORMAL_", "_RANDOM_NORMAL_", "Kenz"],
	["Miku", "_RANDOM_NORMAL_", "_RANDOM_NORMAL_", "Mordekaiser", "_RANDOM_NORMAL_"],
	["_RANDOM_NORMAL_", "Kraze", "_RANDOM_NORMAL_", "_RANDOM_NORMAL_", "Carton", "_RANDOM_NORMAL_"],
	["Cake Box"]
]


# Class to store what will go in a customer slot, really should rename this to something else to avoid confusion
class Slot:
	var _order: String
	var _customer: String
	var _dialogues: Array[String]
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
		{"name": "Plain Bread", "filters": ["_RANDOM_BREAD_", "_RANDOM_NORMAL_"]},
		{"name": "Banana Bread", "filters": ["_RANDOM_BREAD_", "_RANDOM_NORMAL_"]},
		{"name": "Egg Bread", "filters": ["_RANDOM_BREAD_", "_RANDOM_NORMAL_"]},
		{"name": "Coco Bread", "filters": ["_RANDOM_BREAD_", "_RANDOM_NORMAL_"]},
		{"name": "Cheese Pandesal", "filters": ["_RANDOM_BREAD_", "_RANDOM_NORMAL_"]},
		{"name": "Ube Pandesal", "filters": ["_RANDOM_BREAD_", "_RANDOM_NORMAL_"]},
		{"name": "Milk", "tags": []},
		{"name": "Eggs", "tags": []}
	]
	
	func _init(order, customer_name, dialogues):
		set_order(order)
		set_customer(customer_name)
		set_dialogues(dialogues)

	# Set the order from a name or randomly with a filter
	func set_order(order):
		if valid_orders.any(func(x): return x["name"] == order):
			return order
		assert(random_filters.any(func(x): return x["name"] == order), "Invalid order: %s" % order)
		var filtered = []
		for valid_order in valid_orders:
			if order in random_filters:
				for tag in random_filters[order]:
					if tag in valid_order["tags"]:
						filtered.append(valid_order.name)
						break
		assert(filtered.size() > 0, "No orders matching random filter: %s" % order)
		_order = filtered[randi_range(0, filtered.size() - 1)]

	# Set the customer
	func set_customer(customer_name):
		_customer = Customers.get_customer(customer_name)

	# Set the dialogues (pre-order and post-order)
	func set_dialogues(dialogues):
		_dialogues = dialogues
	
	func get_order():
		return _order

	func get_customer():
		return _customer

	func get_dialogues():
		return _dialogues

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
		slot.connect("timer_ended", Callable(self, "_on_timer_ended").bind(index))
	spawn_timer.timeout.connect(Callable(self, "spawn_customer"))
	
	# All customers
	Customers.new_customer("Ali", {"effects": {"time_multiplier": 1000}, "allow_random": false})
	Customers.new_customer("Kenz", {"effects": {"time_multiplier": 1.50}})
	Customers.new_customer("Miku", {"effects": {"hide_recipes": true}, "allow_random": false})
	Customers.new_customer("Mordekaiser", {"allow_random": false})
	Customers.new_customer("Kraze", {"effects": {"timer_multipler": 0.5}})
	Customers.new_customer("Melan", {})
	Customers.new_customer("Carton", {})
	Customers.new_customer("Chekered", {})
	Customers.new_customer("Soda", {})
	Customers.new_customer("Rev", {})
	Customers.new_customer("Kaori", {})
	Customers.new_customer("Ash", {})
	Customers.new_customer("Cake Box", {"time_multiplier": 1000, "allow_random": false})
	
	start_day()


# Spawn the next customer in a random empty slot, every once in a while
func spawn_customer():
	# Attempt to find a valid slot index
	if customer_index > day_customers[day_index].size():
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
	spawn_timer.wait_time = randf_range(0.5*spawn_interval, 1.5*spawn_interval)
	spawn_timer.start()

# Start a day by spawning the first customer
func start_day():
	# run_dialogue()  # day start dialogue
	spawn_customer()

# Increment the day count
func next_day():
	day_index += 1
	# run_dialogue()  # day end dialogue

# TODO:
func run_dialogue(customer_name):
	pass

func _on_order_taken(slot_index):
	run_dialogue(slots[slot_index].dialogue)  # pre-order dialogue

func _on_order_complete(success, slot_index):
	run_dialogue(slots[slot_index].get_name())  # post-order dialogue
	active[slot_index] = false
	slots[slot_index].clear_slot()
	if customer_index > day_customers[day_index].size():
		next_day()

func _on_timer_ended(slot_index):
	active[slot_index] = false
	slots[slot_index].clear_slot()
	run_dialogue(slots[slot_index].get_name())
	if customer_index > day_customers[day_index].size():
		next_day()

func set_slot(slot_index):
	slots[slot_index].set_slot(day_customers[day_index][customer_index])

func freeze():
	spawn_timer.paused = true

func unfreeze():
	spawn_timer.paused = false
