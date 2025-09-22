extends Node2D

@onready var player = $Player
@onready var kitchen = $Kitchen
@onready var interactables = $Interactables
@onready var day_manager = $DayManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Reset.connect("resetted", Callable(self, "_on_resetted"))
	Freeze.is_frozen = false
	player.visible = false
	kitchen.visible = false
	Dialogue.load_sequences()
	Dialogue.run_sequence("dialogue_intro")
	await Freeze.unfrozen
	player.visible = true
	kitchen.visible = true
	_on_resetted(-1)


func _on_resetted(day):
	day_manager.day_index = day
	day_manager.next_day()
	Inventory.set_inventory(Inventory.get_empty())
	player.position = Vector2(0.0, 0.0)
