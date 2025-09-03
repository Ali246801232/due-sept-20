extends Sprite2D

@onready var label: Label = $Label
@onready var timer: Timer = $Timer

var fade_tween: Tween
var fade_duration = 0.2

func _ready():
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	label.text = ""
	visible = false
	modulate.a = 0.0

func show_message(message: String, time: float):
	label.text = message
	visible = true
	
	if fade_tween and fade_tween.is_running():
		fade_tween.stop()
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 1.0, fade_duration)

	if timer.is_stopped() == false:
		timer.stop()
	timer.start(time)

func _on_timer_timeout():
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	
	await fade_tween.finished
	label.text = ""
	visible = false
