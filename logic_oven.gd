extends Node2D

@export var sprite_texture: Texture2D = null
var states: Array = []
var interactable = " Oven"

signal show_message(message: String, time: float)
signal wait(time: float, post_callback: Callable)
signal show_timer()
signal hide_timer()

func _ready():
	sprite_texture = Icons.interactables["Oven"]
	states = [
		Callable(self, "_take_unprocessed"),
		Callable(self, "_return_processed")
	]

	# Valid recipes
	var cont = Inventory.continue_marker
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Cookie Dough", cont, "", ""]}, {"item": "Plain Cookies", "bowl": ["", "", "", ""]})
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Cookie Dough", cont, "Sugar", ""]}, {"item": "Sugar Cookies", "bowl": ["", "", "", ""]})
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Cookie Dough", cont, "Chocolate", ""]}, {"item": "Chocolate Chip Cookies", "bowl": ["", "", "", ""]})
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Cookie Dough", cont, "Butter", ""]}, {"item": "Butter Cookies", "bowl": ["", "", "", ""]})
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Cookie Dough", cont, "Cheese", ""]}, {"item": "Cheese Cookies", "bowl": ["", "", "", ""]})
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Cookie Dough", cont, "Nuts", ""]}, {"item": "Mixed Nut Cookies", "bowl": ["", "", "", ""]})
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Cookie Dough", cont, "Cocoa", "Sugar"]}, {"item": "Chocolate Crinkles", "bowl": ["", "", "", ""]})
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Cookie Dough", cont, "Ube", "Sugar"]}, {"item": "Ube Crinkles", "bowl": ["", "", "", ""]})
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Risen Dough", cont, cont, cont]}, {"item": "Plain Bread", "bowl": ["", "", "", ""]})
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Risen Dough (Banana)", cont, cont, cont]}, {"item": "Banana Bread", "bowl": ["", "", "", ""]})
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Risen Dough (Egg)", cont, cont, cont]}, {"item": "Egg Bread", "bowl": ["", "", "", ""]})
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Risen Dough (Coconut)", cont, cont, cont]}, {"item": "Coco Bread", "bowl": ["", "", "", ""]})
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Risen Dough (Cheese)", cont, cont, cont]}, {"item": "Cheese Pandesal", "bowl": ["", "", "", ""]})
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Risen Dough (Ube)", cont, cont, cont]}, {"item": "Ube Bread", "bowl": ["", "", "", ""]})

func get_sprite_texture():
	return sprite_texture

func get_states():
	return states

var process_time = 10.0
var storage = Inventory.get_empty()

func _take_unprocessed():
	if not Inventory.has_item():
		emit_signal("show_message", "You're not holding anything!", 3.0)
		return 0
	storage = Inventory.get_inventory()
	Inventory.set_inventory(Inventory.get_empty())
	emit_signal("wait", process_time, Callable(self, "_on_processed"))
	emit_signal("show_timer")
	return 1

func _on_processed():
	pass

func _return_processed():
	var output_inventory
	var recipe = Recipes.find_recipe(interactable, storage)
	if recipe:
		output_inventory = recipe.get_output()
	else:
		output_inventory = Inventory.get_mush()
	if Inventory.has_item():
		emit_signal("show_message", "You're already holding something!", 3.0)
		return 1
	emit_signal("hide_timer")
	Inventory.set_inventory(output_inventory)
	return 0
