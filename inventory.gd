extends Node2D

signal update_inventory()

var current_item: String = ""
var current_bowl: Array = []
var holding_bowl: bool = false
var bowl_size: int = 4
var continue_marker = "_CONT_"  # for ingredients to take multiple slots

func _ready():
	set_inventory(get_empty())
	
# Check if the bowl is empty
func is_bowl_empty() -> bool:
	if not holding_bowl:
		return true
	for ingredient in current_bowl:
		if ingredient != "":
			return false
	return true

# Check if an ingredient of a given width can fit in the current bowl
func can_fit(width: int) -> bool:
	if not holding_bowl:
		return false
	var empty = 0
	for slot in current_bowl:
		if slot == "":
			empty += 1
		if empty >= width:
			return true
	return false

# Check if the bowl is full
func is_bowl_full() -> bool:
	return not can_fit(1)

# Check if there is any item
func has_item() -> bool:
	return current_item != ""

# Add an ingredient of a given width to the bowl
func add_ingredient(ingredient_name: String, width: int = 1):
	if not holding_bowl or not can_fit(width):
		return
	for i in range(bowl_size):
		if current_bowl[i] == "":
			current_bowl[i] = ingredient_name
			for j in range(1, width):
				current_bowl[i + j] = continue_marker
			emit_signal("update_inventory")
			return

# Remove all ingredients from bowl
func remove_ingredients():
	if not holding_bowl:
		return
	var bowl = current_bowl
	for i in range(bowl_size):
		current_bowl[i] = ""
	emit_signal("update_inventory")
	return bowl.duplicate()

# Add an item
func add_item(item: String):
	if current_item != "":
		return
	if item == "Bowl":
		holding_bowl = true
	current_item = item
	emit_signal("update_inventory")

# Remove an item
func remove_item() -> String:
	if current_item == "Bowl":
		holding_bowl = false
	var item = current_item
	current_item = ""
	emit_signal("update_inventory")
	return item

# Get the current inventory
func get_inventory() -> Dictionary:
	return {
		"item": current_item,
		"bowl": current_bowl.duplicate()
	}

# Replace the current inventory
func set_inventory(inventory: Dictionary):
	current_item = inventory["item"]
	current_bowl = inventory["bowl"].duplicate()
	if current_item == "Bowl":
		holding_bowl = true
	else:
		holding_bowl = false
	emit_signal("update_inventory")

# Get a copy of an empty inventory, used to initialize interactable storage
func get_empty() -> Dictionary:
	var bowl = []
	bowl.resize(bowl_size)
	bowl.fill("")
	return {
		"item": "",
		"bowl": bowl
	}

# Get a bowl with mush in it, resulting from incorrect interactable usage
func get_mush() -> Dictionary:
	var bowl = []
	bowl.resize(bowl_size)
	bowl.fill("")
	return {
		"item": "Mush",
		"bowl": bowl
	}
