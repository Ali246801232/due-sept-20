extends Node

@export var sprite_texture: Texture2D

signal show_message(message: String, time: float)
signal wait(time: float, post_callback: Callable)
signal show_timer()
signal hide_timer()

func get_sprite_texture():
	sprite_texture = load("res://sprites/test_interactable.png")
	return sprite_texture

func get_states():
	return [
		Callable(self, "take_bowl")
	]

func take_bowl():
	var inventory = Inventory.get_inventory()
	if Inventory.holding_bowl and not Inventory.is_bowl_full():
		Inventory.add_ingredient("Some ingredient")
	return 0
