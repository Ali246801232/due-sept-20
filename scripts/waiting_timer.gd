extends Timer

@onready var timer_display: TextureProgressBar = $TimerDisplay
var showing: bool = false

func _ready():
	Reset.connect("resetted", Callable(self, "_on_resetted"))
	timer_display.global_position = get_parent().global_position + Vector2(8.0, -42.0)  # idfk man

func _process(_delta):
	if timer_display.visible and wait_time > 0:
		timer_display.value = (wait_time - time_left) / wait_time * timer_display.max_value

func wait(time: float, post_callback):
	wait_time = time
	start()
	if post_callback:
		timeout.connect(post_callback, CONNECT_ONE_SHOT)

func show_timer():
	timer_display.visible = true

func hide_timer():
	timer_display.visible = false

func _on_resetted(day):
	stop()
