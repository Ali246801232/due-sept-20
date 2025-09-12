extends Node

var slots: Array = []
var active: Array = []

var day = 0
var customer_index = 0
var day_customers = [
	["Ali"]
]
#var day_customers = [
	#["Ali", "_RANDOM_COOKIE_", "_RANDOM_COOKIE_", "_RANDOM_COOKIE_", "_RANDOM_COOKIE_"],
	#["_RANDOM_COOKIE_", "Melan", "_RANDOM_BREAD_", "_RANDOM_BREAD_", "_RANDOM_BREAD_"],
	#["_RANDOM_NORMAL_", "_RANDOM_NORMAL_", "_RANDOM_NORMAL_", "Kenz"],
	#["Miku", "_RANDOM_NORMAL_", "_RANDOM_NORMAL_", "Mordekaiser", "_RANDOM_NORMAL_"],
	#["_RANDOM_NORMAL_", "Kraze", "_RANDOM_NORMAL_", "_RANDOM_NORMAL_", "Carton", "_RANDOM_NORMAL_"],
	#["Cake"]
#]

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
	
	Customers.new_customer("Ali", {"orders": ["Chocolate Chip Cookies"], "effects": {"timer_multiplier": 0.25}})
	#Customers.new_customer("Melan", {"include": ["Pandesal"]})
	#Customers.new_customer("Kenz", {"include": ["Cookies", "Crinkles", "Bread", "Pandesal"]})
	#Customers.new_customer("Miku", {"include": ["Pandesal"], "effects": {"hide_recipes": true}})
	#Customers.new_customer("Mordekaiser", {"include": ["Cookies"]})
	#Customers.new_customer("Kraze", {"include": ["Cookies", "Crinkles"], "effects": {"timer_multipler": 0.6}})

# TODO:
func start():
	pass

# TODO:
func run_dialogue(customer_name):
	pass

func _on_order_taken(slot_index):
	active[slot_index] = true
	run_dialogue(slots[slot_index].get_name())

func _on_order_complete(slot_index):
	active[slot_index] = false
	customer_index += 1
	run_dialogue(slots[slot_index].get_name())
	if customer_index > len(day_customers[day]):
		next_day()

func _on_timer_ended(slot_index):
	active[slot_index] = false
	customer_index += 1
	run_dialogue(slots[slot_index].get_name())
	if customer_index > len(day_customers[day]):
		next_day()

func set_customer(slot_index):
	var next_customer = day_customers[day][customer_index]
	slots[slot_index].set_customer(next_customer)

# TODO:
func next_day():
	pass
