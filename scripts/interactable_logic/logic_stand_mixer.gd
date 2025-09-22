extends Node2D

@export var sprite_texture: Texture2D = null
var states: Array = []
var interactable = "Stand Mixer"

signal show_message(message: String, time: float)
signal wait(time: float, post_callback: Callable)
signal show_timer()
signal hide_timer()

func _ready():
	Reset.connect("resetted", Callable(self, "_on_resetted"))

	sprite_texture = Icons.interactables["Stand Mixer"]
	states = [
		Callable(self, "_take_unprocessed"),
		Callable(self, "_return_processed")
	]

	# Valid recipes
	var cont = Inventory.continue_marker
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Flour", "Butter", "Milk", "Sugar"]}, {"item": "Bowl", "bowl": ["Cookie Dough", cont, "", ""]})
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["Flour", "Butter", "Water", "Sugar"]}, {"item": "Bowl", "bowl": ["Bread Dough", cont, cont, ""]})
	Recipes.new_recipe(interactable, {"item": "Bowl", "bowl": ["", "", "", ""]}, {"item": "Bowl", "bowl": ["", "", "", ""]})

func get_sprite_texture():
	return sprite_texture

func get_states():
	return states

var process_time = 2.0
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
	storage = Inventory.get_empty()
	return 0

func _on_resetted(day):
	storage = []
