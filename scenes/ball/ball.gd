extends CharacterBody3D
class_name ball

var held:=false
var heldSide:=-1
var beenHeld:=false

var bonkReady:=0:
	get:
		var valid=((Time.get_ticks_msec()-bonkReady)>300)
		if valid: bonkReady=Time.get_ticks_msec()
		return valid

@onready var catchPlayer:AudioStreamPlayer3D=$catch
@onready var throwPlayer:AudioStreamPlayer3D=$throw
@onready var fallPlayer:AudioStreamPlayer3D=$fall

@onready var mesh=$mesh

var rotDir:=Vector3(0,0,0)

func _ready():
	if ((global.balls%2)==0):
		var newMat=$mesh/Sphere.get_active_material(0)
		var k=0
		for v in [Color(1,1,1),Color(.52,.4,.1)]:
			newMat=newMat.duplicate(true)
			newMat.albedo_color=v
			$mesh/Sphere.set_surface_override_material(k,newMat)
			k+=1
	
	global.balls+=1

func _physics_process(_delta):
	if held: return
	
	velocity.x=0
	var fall=global.grav
	if (velocity.y>0): fall*=2
	velocity.y-=fall
	velocity.z*=(global.airFric/(global.grav*10))
	
	var col:KinematicCollision3D=get_last_slide_collision()
	if (col and !held and bonkReady):
		var bonk=(col.get_normal().normalized()*4)
		velocity+=bonk
		velocity=velocity.clamp(Vector3(0,-2,-2),Vector3(0,2,2))
		catchPlayer.play()
	
	velocity=velocity.clamp(Vector3(0,-6,-6)*global.grav*10,Vector3(0,6,6)*global.grav*10)
	move_and_slide()
	rotation+=(rotDir/3)

func caught():catchPlayer.play()
func threw():
	throwPlayer.play()
	rotDir=Vector3(randf_range(-.1,.1),randf_range(-.1,.1),randf_range(-.1,.1))
