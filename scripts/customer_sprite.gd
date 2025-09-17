extends Sprite2D

@onready var tween = create_tween()

func animate_spawn():
	visible = true

func animate_despawn():
	visible = false
