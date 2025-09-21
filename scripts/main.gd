extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Freeze.is_frozen = false
	Dialogue.load_sequences()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
