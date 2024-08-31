extends Node3D

var offset:=Vector3(0,0,0):
	set(v):
		var lastOffset=offset
		offset=v
		offset=offset.clamp(Vector3(0,-64,-172),Vector3(0,128,172))
		vel = (offset-lastOffset)

var vel:=Vector3(0,0,0):
	set(v):
		vel=v
		for i in range(numKeepLastVels):
			var look=(abs(i-numKeepLastVels)-1)
			if (look<(numKeepLastVels-1)): lastVels[look]=lastVels[look-1]
			else: lastVels[look]=v
var lastVels:=[]
var numKeepLastVels:=12

var ballOfInterest:
	get:
		if !is_instance_valid(ballOfInterest): return null
		
		if !ballOfInterest.beenHeld: ballOfInterest=null
		
		return ballOfInterest

var lastBlink:=0
var nextBlink:=8000

@onready var eyes:=[
	$head/eyer,
	$head/eyel
]
@onready var pupils:=[
	$head/eyer/pupil,
	$head/eyel/pupil
]
@onready var head=$head

@onready var hands=[
	{
		anim=$handl/AnimationPlayer,
		animSuffix="_l",
		pressed="handl",
		node=$handl,
		offset=$handl/handl,
		controlled=false,
		side=1,
		grabbing=null,
		grab=$handl/grab,
		lastOpen=0
	},
	{
		anim=$handr/AnimationPlayer,
		animSuffix="_r",
		pressed="handr",
		node=$handr,
		offset=$handr/handr,
		controlled=false,
		side=-1,
		grabbing=null,
		grab=$handr/grab,
		lastOpen=0
	}
]

@onready var catches=$catches
@onready var high=$high
var highscore:=0
var counter:=0:
	set(v):
		counter=v
		catches.text=("CATCHES: %d"%counter)
		catches.position.y-=clamp(v,0,20)
		if (v>highscore):
			highscore=v
			high.text=("[right](HIGH: %d)[/right]"%highscore)

func _ready():
	for hand in hands:
		hand.pos=hand.node.global_position
		hand.pos.x=.15
		hand.rot=hand.node.rotation
	
	for v in range(numKeepLastVels):
		lastVels.append(Vector3(0,0,0))

func _input(event):
	if (global.active and (event is InputEventMouseMotion)):
		var relative=(Vector3(0,-event.relative.y,event.relative.x)*global.sensitivity)
		offset+=relative

func _physics_process(_delta):
	position.x=lerp(position.x,0.0 if global.active else 8.0,.1)
	if (position.x>1): offset=Vector3(0,0,0)
	
	var k=0
	for hand in hands:
		var justClosed=(Input.is_action_just_pressed(hand.pressed) and global.active)
		var closed=(Input.is_action_pressed(hand.pressed) and global.active)
		
		hand.node.position.x=lerp(hand.node.position.x,0.0,.4)
		
		if Input.is_action_just_released(hand.pressed): hand.lastOpen=Time.get_ticks_msec()
		
		hand.node.global_position=hand.node.global_position.lerp(hand.pos+(offset*.01),clamp(global.grav*4,0,1))#.4)
		hand.offset.rotation=hand.offset.rotation.lerp(hand.rot-(vel/20*hand.side),.1)
		
		if justClosed:
			for v in hand.grab.get_overlapping_bodies():
				if (!is_instance_valid(hand.grabbing) and (v is ball) and !v.held):
					if (v.beenHeld and ((Time.get_ticks_msec()-hand.lastOpen)>200)): counter+=1
					
					v.heldSide=hand.side
					v.caught()
					
					if (v==ballOfInterest): ballOfInterest=null
					
					v.held=true
					v.beenHeld=true
					hand.grabbing=v
					v.get_parent().remove_child(v)
					hand.node.add_child(v)
					v.scale=Vector3(5,5,5)
					v.position=Vector3(-.6,.6,.2*hand.side)
		if (!closed and is_instance_valid(hand.grabbing)):
			ballOfInterest=hand.grabbing
			
			hand.grabbing.held=false
			var pos=hand.grabbing.global_position
			hand.node.remove_child(hand.grabbing)
			get_parent().add_child(hand.grabbing)
			hand.grabbing.scale=Vector3(1,1,1)
			hand.grabbing.global_position=pos
			var assist=(lastVelsAverage()*Vector3(0,1.6,2)).clamp(Vector3(0,4,-4),Vector3(0,8,4))
			hand.grabbing.velocity=assist
			
			hand.grabbing.threw()
			hand.grabbing=null
		
		var anim="open"
		if closed: anim=("ball" if is_instance_valid(hand.grabbing) else "closed")
		hand.anim.play(anim+hand.animSuffix)
		
		if (k==1): vel=Vector3(0,0,0)
		k+=1
	
	for pupil in pupils:
		var look=(offset*Vector3(0,6,1))
		if is_instance_valid(ballOfInterest):
			look=((ballOfInterest.global_position-global_position)*Vector3(0,270,90))
		pupil.position.x=lerp(pupil.position.x,-look.z/300,.1)
		pupil.position.x=clamp(pupil.position.x,-.54,.54)
		pupil.position.z=lerp(pupil.position.z,look.y/300,.1)
		pupil.position.z=clamp(pupil.position.z,-.9,.9)
	if ((Time.get_ticks_msec()-lastBlink)>nextBlink):
		lastBlink=Time.get_ticks_msec()
		nextBlink=randi_range(6000,1800)
	for eye in eyes:
		eye.visible=(((Time.get_ticks_msec()-lastBlink)>200) and (position.x<3))
	
	head.position.y=(sin(Time.get_ticks_msec()/1200.0)/24)
	
	catches.position.y=lerp(catches.position.y,896.0 if global.active else 960.0,.2)
	high.position.y=lerp(high.position.y,927.0 if global.active else 959.0,.1)

func lastVelsAverage():
	var vec:=Vector3(0,0,0)
	for v in lastVels: vec+=v
	return (vec/numKeepLastVels)
