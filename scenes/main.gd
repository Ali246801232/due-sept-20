extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DayManager/CustomerSlot0.set_customer("Ali")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
