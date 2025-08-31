extends Node

var recipes: Array = []

class Recipe:
	var interactable_name: String
	var input_inventory: Dictionary
	var output_inventory: Dictionary
	
	func _init(interactable_name, input_inventory, output_inventory):
		self.interactable_name = interactable_name
		self.input_inventory = input_inventory
		self.output_inventory = output_inventory

	func get_output():
		return output_inventory
	
	# Convert a bowl array into an array of groups
	func _group_bowl(bowl: Array):
		var groups: Array = []
		var current_group: Array = []

		for slot in bowl:
			if slot == "_CONT_":
				if current_group.size() == 0:
					return null
				current_group.append(slot)
			else:
				if current_group.size() > 0:
					groups.append(current_group)
				current_group = [slot]
		if current_group.size() > 0:
			groups.append(current_group)

		return groups

	# Check if two bowls are equivalent
	func bowls_equivalent(bowl1: Array, bowl2: Array) -> bool:
		# Group ingredients
		var groups1 = _group_bowl(bowl1)
		var groups2 = _group_bowl(bowl2)
		if groups1 == null or groups2 == null: # invalid bowl
			return false

		# Count groups
		var count1 = {}
		for group in groups1:
			count1[str(group)] = count1.get(str(group), 0) + 1
		var count2 = {}
		for group in groups2:
			count2[str(group)] = count2.get(str(group), 0) + 1

		return count1 == count2

	# Check if two bowls contain equivalent ingredients
	func matches(interactable, storage):
		# Wrong interactable or item
		if interactable != interactable_name or storage["item"] != input_inventory["item"]:
			return false

		# Not a bowl, dont need to check ingredients
		if storage["item"] != "Bowl":
			return true
		
		# If bowl, check if equivalent ingredients
		if bowls_equivalent(storage["bowl"], input_inventory["bowl"]):
			return true

# Register a new recipe
func new_recipe(interactable_name, input_inventory, output_inventory):
	for recipe in recipes:
		if recipe.matches(interactable_name, input_inventory):
				return
	recipes.append(Recipe.new(interactable_name, input_inventory, output_inventory))

# Find a registered recipe
func find_recipe(interactable, storage):
	for recipe in recipes:
		if recipe.matches(interactable, storage):
			return recipe
	return null
