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

func _ready() -> void:
	# Get all customer slots
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
	
	Customers.new_customer("Ali", {"orders": ["Chocolate Chip Cookies"], "effects": {"time_multiplier": 1000}, "allow_random": false})
	Customers.new_customer("Melan", {"include": ["Pandesal"]})
	Customers.new_customer("Kenz", {"effects": {"time_multiplier": 1.50}})
	Customers.new_customer("Miku", {"include": ["Pandesal"], "effects": {"hide_recipes": true}, "allow_random": false})
	Customers.new_customer("Mordekaiser", {"include": ["Cookies"]})
	Customers.new_customer("Kraze", {"include": ["Cookies", "Crinkles"], "effects": {"timer_multipler": 0.5}})
	Customers.new_customer("Carton", {"orders": ["Milk"]})
	Customers.new_customer("Chekered", {"include": ["Cookies"]})
	Customers.new_customer("Soda", {})
	Customers.new_customer("Rev", {})
	Customers.new_customer("Chiyo", {})
	Customers.new_customer("Cake Box", {"orders": ["Box"]})
	
	start_day()

func spawn_customer():
	print(day_index)
	print(customer_index)

	if customer_index > day_customers[day_index].size():
		return

	var inactive_indices := []
	for i in range(active.size()):
		if not active[i]:
			inactive_indices.append(i)
	if inactive_indices.is_empty():
		return
	var slot_index = inactive_indices[randi() % inactive_indices.size()]

	var customer_name = day_customers[day_index][customer_index]
	slots[slot_index].set_customer(customer_name)
	active[slot_index] = true
	customer_index += 1
	spawn_timer.wait_time = randf_range(spawn_interval - 5, spawn_interval + 5)
	spawn_timer.start()

func start_day():
	spawn_customer()

func next_day():
	day_index += 1

# TODO:
func run_dialogue(customer_name):
	pass

func _on_order_taken(slot_index):
	run_dialogue(slots[slot_index].get_name())

func _on_order_complete(success, slot_index):
	active[slot_index] = false
	slots[slot_index].clear_customer()
	run_dialogue(slots[slot_index].get_name())
	if customer_index > day_customers[day_index].size():
		next_day()

func _on_timer_ended(slot_index):
	active[slot_index] = false
	slots[slot_index].clear_customer()
	run_dialogue(slots[slot_index].get_name())
	if customer_index > day_customers[day_index].size():
		next_day()

func set_customer(slot_index):
	slots[slot_index].set_customer(day_customers[day_index][customer_index])
