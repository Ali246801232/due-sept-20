extends Node

signal frozen
signal unfrozen

@export var is_frozen: bool:
	set(value):
		if value != is_frozen:
			is_frozen = value
			emit_signal("frozen" if is_frozen else "unfrozen")
