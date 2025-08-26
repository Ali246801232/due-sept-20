extends TextureProgressBar

@onready var parent: Area2D = get_parent()
@onready var waiting_timer: Timer = parent.get_node("WaitingTimer")

var total_time: float = 0.0
var active: bool = false

func _ready() -> void:
	parent.connect("wait_started", Callable(self, "_on_wait_started"))
	parent.connect("wait_ended", Callable(self, "_on_wait_ended"))

	visible = false
	value = 0


func _process(delta: float) -> void:
	if active:
		# Godot timers count down, so progress = 1 - (time_left / total_time)
		value = (total_time - waiting_timer.time_left) / total_time * max_value


func _on_wait_started(wait_time: float) -> void:
	total_time = wait_time
	value = 0
	visible = true
	active = true


func _on_wait_ended() -> void:
	active = false
	visible = false
	value = 0
