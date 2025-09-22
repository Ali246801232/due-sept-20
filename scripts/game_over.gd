extends Sprite2D

@onready var game_over_text = $GameOverText
@onready var message = $Message

func _ready():
	visible = false
	message.visible_ratio = 0.0
	message.text = ""

# TODO:
func game_over(day):
	#Reset.reset(day)
	pass
