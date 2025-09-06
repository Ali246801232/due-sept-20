extends Timer

@onready var timer_display: TextureProgressBar = $TimerDisplay

func _process(_delta):
	if timer_display.visible and wait_time > 0:
		timer_display.value = (wait_time - time_left) / wait_time * timer_display.max_value

func wait(time: float, post_callback):
	wait_time = time
	start()
	if post_callback:
		timeout.connect(post_callback, CONNECT_ONE_SHOT)
