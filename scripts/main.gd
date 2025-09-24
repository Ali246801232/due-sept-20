extends Node2D

@onready var player = $Player
@onready var kitchen = $Kitchen
@onready var interactables = $Interactables
@onready var day_manager = $DayManager
@onready var game_over_gui = $GUI/GameOverLayer/GameOver
@onready var credits_gui = $GUI/CreditsLayer/CreditsBackground
@onready var music_player = $MusicPlayer

var game_over_message = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Reset.connect("resetted", Callable(self, "_on_resetted"))
	day_manager.connect("last_day", Callable(self, "_on_last_day"))
	day_manager.connect("ending_cutscene", Callable(self, "_on_ending_cutscene"))
	Dialogue.connect("show_game_over", Callable(self, "_on_show_game_over"))

	Freeze.is_frozen = false
	player.visible = false
	kitchen.visible = false
	Dialogue.load_sequences()
	Dialogue.run_sequence("dialogue_intro")
	await Freeze.unfrozen
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
	day_manager.get_node("DayTransition").transition_day(5)
	$Interactables/Fridge/Logic.last_day_state()
	Dialogue.run_sequence("dialogue_day6_start")

func _on_ending_cutscene():
	Dialogue.run_sequence("ending_cutscene")
	Freeze.is_frozen = true
	music_player.volume_db = -15.0
	music_player.stream = load("res://assets/audio/credits_music.wav")
	music_player.play()
	credits_gui.show_credits()
