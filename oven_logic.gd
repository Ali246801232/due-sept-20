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
		Callable(self, "put_item_in_oven"),
		Callable(self, "take_item_from_oven")
	]

var storage: Array

func put_item_in_oven():
	emit_signal("show_message", "Player puts raw item in oven", 3.0)
	emit_signal("wait", 5.0, Callable(self, "_on_wait_finished"))
	emit_signal("show_timer")
	return 1

func _on_wait_finished():
	emit_signal("show_message", "Oven is done.", 3.0)

func take_item_from_oven():
	emit_signal("hide_timer")
	emit_signal("show_message", "Player takes cooked item from oven", 3.0)
	return 0
