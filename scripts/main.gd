extends Node2D

@onready var player = $Player
@onready var kitchen = $Kitchen
@onready var interactables = $Interactables
@onready var day_manager = $DayManager
@onready var game_over_gui = $GUI/GameOverLayer/GameOver

var game_over_message = ""

signal last_day()
signal ending_cutscene()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Reset.connect("resetted", Callable(self, "_on_resetted"))
	connect("last_day", Callable(self, "_on_last_day"))
	connect("ending_cutscene", Callable(self, "_on_ending_cutscene"))
	Dialogue.connect("show_game_over", Callable(self, "_on_show_game_over"))

	Freeze.is_frozen = false
	#player.visible = false
	#kitchen.visible = false
	Dialogue.load_sequences()
	#Dialogue.run_sequence("dialogue_intro")
	#await Freeze.unfrozen
	player.visible = true
	kitchen.visible = true
	Freeze.is_frozen = true
	day_manager.day_index = -1
	day_manager.next_day()
	Inventory.set_inventory(Inventory.get_empty())
	player.position = Vector2(0.0, 0.0)


func _on_resetted(day):
	Dialogue.end()
	Freeze.is_frozen = true
	await game_over_gui.tween_finished
	day_manager.day_index = day - 1
	day_manager.next_day()
	Inventory.set_inventory(Inventory.get_empty())
	player.position = Vector2(0.0, 0.0)

func _on_show_game_over(message):
	game_over_message = message
	game_over_gui.show_game_over(message)

func _on_last_day():
	pass

func _on_ending_cutscene():
	pass
