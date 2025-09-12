extends Sprite2D

@onready var label: Label = $Label
@onready var timer: Timer = $Timer

func _ready():
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

	label.text = ""
	visible = false

func show_message(message: String, time: float):
	label.text = message
	visible = true

	if timer.is_stopped() == false:
		timer.stop()
	timer.start(time)

func _on_timer_timeout():
	label.text = ""
	visible = false
