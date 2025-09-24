extends Sprite2D

@onready var credits_text = $CreditsText
var fade_tween: Tween
var scroll_tween: Tween

func _ready():
	visible = false
	modulate.a = 0.0
	credits_text.global_position = Vector2(0, 0)
	

func show_credits():
	visible = true
	modulate.a = 0.0
	await get_tree().create_timer(2.0).timeout
	if fade_tween and fade_tween.is_running():
		fade_tween.stop()
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 1.0, 1.0)
	await fade_tween.finished
	scroll_tween = create_tween()
	var text_initial_pos = credits_text.global_position
	scroll_tween.tween_property(credits_text, "global_position", credits_text.global_position + Vector2(0, -2000.00), 20.0)
	
