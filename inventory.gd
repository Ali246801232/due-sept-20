extends Node2D

signal update_inventory

var current_item = ""

var holding_bowl: bool = false
var bowl_size: int = 4
var current_bowl: Array = []

func _ready():
	current_bowl.resize(bowl_size)
	current_bowl.fill("")

func is_bowl_empty():
	if not holding_bowl:
		return true
	for ingredient in current_bowl:
		if ingredient != "":
			return false
	return true

func is_bowl_full():
	if not holding_bowl:
		return false
	for ingredient in current_bowl:
		if ingredient == "":
			return false
	return true


func has_item():
	if current_item != "":
		return true

func add_ingredient(ingredient):
	if not holding_bowl:
		return
	for i in range(bowl_size):
		if current_bowl[i] == "":
			current_bowl[i] = ingredient
			emit_signal("update_inventory")
			return

func remove_ingredients():
	if not holding_bowl:
		return
	var bowl = current_bowl
	for i in range(bowl_size):
		current_bowl[i] = ""
	emit_signal("update_inventory")
	return bowl.duplicate()

func add_item(item):
	if item == "bowl":
		holding_bowl = true
	current_item = item
	emit_signal("update_inventory")

func remove_item():
	if current_item == "bowl":
		holding_bowl = false
	var item = current_item
	current_item = ""
	emit_signal("update_inventory")
	return item

func get_inventory():
	return {
		"item": current_item,
		"bowl": current_bowl.duplicate()
	}
