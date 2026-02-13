extends RigidBody2D

##### DECLARATIONS #####

@onready var deathCollision: Area2D = $DeathCollision
@onready var vx = $UI/Control/VX
@onready var vy = $UI/Control/VY
@onready var r = $UI/Control/R

@export var SPEED = 300.0
var n = 0
##### BUILT-IN #####

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	#if not is_on_floor():
		#self.linear_velocity += get_gravity()
	#else:
		#self.linear_velocity.y = 0

	if Input.is_action_pressed("Accelerate"):
		self.linear_velocity.x += SPEED
	
	vx.text = "Vitesse X : " + str(snappedf(linear_velocity.x, 0.01))
	vy.text = "Vitesse Y : " + str(snappedf(linear_velocity.y, 0.01))
	r.text = "Rotation : " + str(snappedf(rotation_degrees, 0.01))


##### LOGIC #####

func is_on_floor() -> bool:
	return self.get_contact_count() > 0

##### SIGNAL RESPONSES #####
