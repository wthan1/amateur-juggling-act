extends Node

var grav:=.1
var airFric:=.97
var sensitivity:=.8

var balls:=0

var active:=false:
	set(v):
		active=v
		Input.mouse_mode=(Input.MOUSE_MODE_CAPTURED if active else Input.MOUSE_MODE_VISIBLE)

func _input(_event):
	if Input.is_action_just_pressed("menu"): active=!active

func _notification(what):
	if (what==NOTIFICATION_APPLICATION_FOCUS_OUT): active=false
