extends RigidBody2D

##### DECLARATIONS #####

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var deathCollision: Area2D = $DeathCollision
@onready var vx = $UI/Control/VX
@onready var vy = $UI/Control/VY
@onready var r = $UI/Control/R
@onready var a = $UI/Control/A

@export var SPEED = 300.0
var n = 0
##### BUILT-IN #####

func _ready() -> void:
	sprite.speed_scale = 0
	sprite.play("Idle")

func _draw() -> void:
	draw_line(Vector2.ZERO, center_of_mass * 50, Color.BROWN)
	draw_circle(center_of_mass * 50, 2, Color.RED)

func _physics_process(delta: float) -> void:
	queue_redraw()
	#if not is_on_floor():
		#self.linear_velocity += get_gravity()
	#else:
		#self.linear_velocity.y = 0

	if Input.is_action_pressed("Accelerate"):
		var dir = Vector2(
			cos(rotation),
			sin(rotation)
		)
		linear_velocity = dir * SPEED
		angular_velocity = -2
		sprite.speed_scale = sprite.speed_scale + 0.1 if sprite.speed_scale < 1.0 else 1.0
	else:
		angular_velocity = 0
		sprite.speed_scale = sprite.speed_scale - 0.1 if sprite.speed_scale > 0.0 else 0.0
	
	var dir = Vector2(
		cos(sprite.rotation),
		sin(sprite.rotation)
	)
	center_of_mass = dir * 0.5
	
	vx.text = "Vitesse X : " + str(snappedf(linear_velocity.x, 0.01))
	vy.text = "Vitesse Y : " + str(snappedf(linear_velocity.y, 0.01))
	r.text = "Rotation : " + str(snappedf(rotation_degrees, 0.01))
	a.text = "Altitude : " + str(snappedf(int((position.y - 602) / 4) * -1 + 12, 0.01))


##### LOGIC #####

func is_on_floor() -> bool:
	return self.get_contact_count() > 0

##### SIGNAL RESPONSES #####
