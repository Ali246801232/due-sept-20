extends Timer

@onready var timer_display: TextureProgressBar = $TimerDisplay

func _ready():
	timer_display.position = get_parent().global_position + Vector2(-30.0, -45.0)  # idfk man

func _process(_delta):
	if timer_display.visible and wait_time > 0:
		timer_display.value = (wait_time - time_left) / wait_time * timer_display.max_value

func show_timer():
	timer_display.visible = true

func hide_timer():
	timer_display.visible = false
