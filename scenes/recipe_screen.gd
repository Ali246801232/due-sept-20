extends AnimatedSprite2D

@onready

var pandesal_unlocked: bool

var pages = []

func _ready():
	# setup page spriteframe animation names, and connect buttons to functions
	pass

func next_page():
	# go to next in pages, and loop around
	pass

func previous_page():
	# go to previous in pages, and loop around
	pass

func unlock_pandesal():
	# set pandesal_unlocked to true, and change current page to pandesal page if on locked variant
	pass
