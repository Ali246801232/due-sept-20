extends Node2D

@export var sprite_texture: Texture2D = null
var states: Array = []

signal show_message(message: String, time: float)
signal wait(time: float, post_callback: Callable)
signal show_timer()
signal hide_timer()

func _ready():
	Reset.connect("resetted", Callable(self, "_on_resetted"))

	sprite_texture = Icons.interactables["Table"]
	states = [
		Callable(self, "_swap_inventory")
	]

func get_sprite_texture():
	return sprite_texture

func get_process_function():
	return Callable(self, "_display_storage")

func get_states():
	return states

func _display_storage():
	pass

var storage = Inventory.get_empty()

func _swap_inventory():
	var inventory = Inventory.get_inventory()
	Inventory.set_inventory(storage)
	storage = inventory
	return 0

func _on_resetted(day):
	storage = Inventory.get_empty()
