extends Node

signal resetted(day)

var current_day

func reset():
	emit_signal("resetted", current_day)
