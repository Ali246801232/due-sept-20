extends Node

signal resetted(day)

func reset(day):
	emit_signal("resetted", day)
