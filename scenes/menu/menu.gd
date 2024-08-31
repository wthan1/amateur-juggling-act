extends Control

func _ready():
	position.x=(-720 if global.active else 0)
	
	sensitivity.value=global.sensitivity
	
	if OS.has_feature("web"): $exit.queue_free()

func _physics_process(_delta):
	position.x=lerp(position.x,-720.0 if global.active else 0.0,.1)

@onready var sensitivity=$sensetivity/control
func _on_control_drag_ended(_value_changed): global.sensitivity=sensitivity.value

func _on_exit_pressed(): get_tree().quit()

func _on_start_pressed(): global.active=true
