extends CanvasLayer

@onready var fade_black: Sprite2D = $FadeBlack
@onready var transition_text: Label = $TransitionText
var fade_tween: Tween
var text_tween: Tween

var day_texts = [
	"Day 1",
	"Day 2",
	"Day 3",
	"Day 4",
	"Day 5",
	""
]

func _ready() -> void:
	fade_black.visible = false
	transition_text.visible = false
	fade_black.modulate.a = 0.0
	transition_text.modulate.a = 0.0

func fade_to_black():
	fade_black.visible = true
	transition_text.visible = true
	fade_black.modulate.a = 1.0
	transition_text.modulate.a = 1.0


func fade_from_black():
	fade_black.visible = true
	transition_text.visible = true
	fade_black.modulate.a = 1.0
	transition_text.modulate.a = 1.0
	if fade_tween and fade_tween.is_running():
		fade_tween.stop()
	fade_tween = create_tween()
	fade_tween.tween_property(fade_black, "modulate:a", 0.0, 1.0)
	text_tween = create_tween()
	text_tween.tween_property(transition_text, "modulate:a", 0.0, 1.0)
	await text_tween.finished
	fade_black.visible = false
	transition_text.visible = false


func transition_day(day):
	if day > day_texts.size():
		return
	transition_text.text = day_texts[day]
	fade_to_black()
	await get_tree().create_timer(2.0).timeout
	fade_from_black()
