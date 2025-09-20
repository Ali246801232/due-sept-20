extends CanvasLayer

@onready var fade_black: Sprite2D = $FadeBlack
@onready var transition_text: Label = $TransitionText
var tween: Tween

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

func fade_to_black():
	pass

func fade_from_black():
	pass

func show_text(text, time):
	pass

func transition_day(day):
	fade_to_black()
	show_text(transition_text[day], 2.0)
	fade_from_black()
