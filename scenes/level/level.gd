extends Node3D

var last:=0
var queue:=[]

var left:=[]

@onready var player=$player

func _on_delete_body_entered(body):
	if !(body is ball): return
	
	player.counter=0
	
	if (Time.get_ticks_msec()>1000):
		body.fallPlayer.play()
		var leave=body.mesh.duplicate()
		add_child(leave)
		leave.position=body.position
		leave.position.y=.5
		leave.rotation=body.rotation
		left.append(leave)
	
	queue.append(body)

func _physics_process(_delta):
	if ((len(queue)>0) and ((Time.get_ticks_msec()-last)>1000) and global.active):
		if !queue[0].held:
			queue[0].velocity=Vector3(0,0,0)
			queue[0].position=Vector3(0,6,.7)
			queue[0].beenHeld=false
		queue.remove_at(0)
		last=Time.get_ticks_msec()
	
	updateLeft()

func updateLeft():
	var k=0
	for v:Node3D in left:
		v.scale-=Vector3(.004,.004,.004)
		if (v.scale.x<0):
			v.queue_free()
			left.remove_at(k)
			updateLeft()
			return
		
		k+=1
