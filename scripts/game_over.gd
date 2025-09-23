extends Sprite2D

@onready var game_over_text = $GameOverText
@onready var message = $Message
var fade_tween: Tween
signal tween_finished()

func _ready():
	message.text = ""
	visible = false
	modulate.a = 0.0

func show_game_over(game_over_text):
	visible = true
	modulate.a = 1.0
	message.text = game_over_text
	await get_tree().create_timer(2.0).timeout
	if fade_tween and fade_tween.is_running():
		fade_tween.stop()
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await fade_tween.finished
	visible = false
	emit_signal("tween_finished")
