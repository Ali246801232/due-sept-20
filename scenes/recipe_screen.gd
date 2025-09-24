extends AnimatedSprite2D  # has pages as animations

@onready var next_button: Button
@onready var prev_button: Button

var pandesal_unlocked: bool
var current_page = -1

var pages = ["page1", "page2", "page3", "page4_locked", "page5_locked", "page6_locked"]
var switch = {"page4_locked": "page4", "page5_locked": "page5", "page6_locked": "page6"}

func _ready():
	next_button = get_parent().get_node("NextButton")
	prev_button = get_parent().get_node("PrevButton")
	next_button.connect("pressed", Callable(self, "next_page"))
	prev_button.connect("pressed", Callable(self, "prev_page"))
	next_button.modulate.a = 0.0
	prev_button.modulate.a = 0.0
	next_page()

func next_page():
	current_page = (current_page + 1) % pages.size()
	play(pages[current_page])

func prev_page():
	current_page = (current_page - 1 + pages.size()) % pages.size()
	play(pages[current_page])

func unlock_pandesal():
	pandesal_unlocked = true
	var current_anim = pages[current_page]

	if switch.has(current_anim):
		pages[current_page] = switch[current_anim]
		play(pages[current_page])

	for i in range(pages.size()):
		if switch.has(pages[i]):
			pages[i] = switch[pages[i]]
