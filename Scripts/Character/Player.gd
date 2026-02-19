extends RigidBody2D

##### DECLARATIONS #####

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var deathCollision: Area2D = $DeathCollision
@onready var vx = $UI/Control/VX
@onready var vy = $UI/Control/VY
@onready var r = $UI/Control/R
@onready var a = $UI/Control/A
@onready var av = $UI/Control/AV

@export var THRUST_FORCE = 2500.0        # Force de poussée
@export var THRUST_ROTATION = 2.0        # Vitesse de rotation en montée (rad/s)
@export var NOSE_DOWN_SPEED = 2.0       # Vitesse à laquelle le nez suit la vélocité en chute
@export var MAX_SPEED = 400.0
@export var ANGULAR_DAMP = 0.5
@export var LIFT_FORCE = 800.0           # Coefficient de portance
@export var DRAG_FORCE = 1.0            # Résistance de l'air (freine la composante perpendiculaire)

##### BUILT-IN #####

func _ready() -> void:
	sprite.speed_scale = 0
	sprite.play("Idle")
	
	#deathCollision.connect("body_shape_entered",
		#func(): print("death")#get_tree().reload_current_scene()
	#)


func _draw() -> void:
	var dir = Vector2(cos(sprite.rotation), sin(sprite.rotation))
	var lift_dir = Vector2(-dir.y, -dir.x) # perpendiculaire à la vitesse
	draw_line(Vector2.ZERO, lift_dir * 1000, Color(1, 0, 0, 0.2), 1)
	
	draw_line(Vector2.ZERO, _get_lift(), Color.RED, 1)
	draw_line(Vector2.ZERO, linear_velocity, Color.YELLOW, 1)

func _physics_process(delta: float) -> void:
	queue_redraw()
	
	if Input.is_action_pressed("Accelerate"):
		sprite.speed_scale = min(sprite.speed_scale + 0.1, 1.0)
		# Thrust force par le joueur
		_accelerate(delta)
	else:
		sprite.speed_scale = max(sprite.speed_scale - 0.1, 0.0)
		# Chute avec le nez qui pique
		_free_fall(delta)

	# Limiter la vitesse max
	if linear_velocity.length() > MAX_SPEED:
		linear_velocity = linear_velocity.normalized() * MAX_SPEED

	# La portance
	_apply_lift()
	
	_apply_lateral_drag()

	# UI debug
	vx.text = "Vitesse X : " + str(snappedf(linear_velocity.x, 0.01))
	vy.text = "Vitesse Y : " + str(snappedf(linear_velocity.y, 0.01))
	r.text = "Rotation : " + str(snappedf(rotation_degrees, 0.01))
	a.text = "Altitude : " + str(snappedf(int((position.y - 602) / 4) * -1 + 12, 0.01))
	av.text = "Angular Velocity : " + str(angular_velocity)

##### LOGIC #####

func _accelerate(_delta: float) -> void:
	# Rotation fixe vers le haut (sens anti-horaire)
	#angular_velocity = 0
	apply_torque_impulse(-THRUST_ROTATION)
	#rotation -= ROTATION_SPEED * delta

	# Poussée dans la direction de l'avion
	var dir = Vector2(cos(rotation), sin(rotation))
	apply_central_force(dir * THRUST_FORCE)


func _free_fall(_delta: float) -> void:
	# Le nez de l'avion s'oriente progressivement vers la vélocité (piqué naturel)
	if linear_velocity.length() > 10.0:
		var target_angle = linear_velocity.angle()
		var angle_diff = target_angle - rotation
		angle_diff = wrapf(angle_diff, -PI, PI)
		
		var target_angular_velocity = angle_diff * NOSE_DOWN_SPEED
		angular_velocity = lerpf(angular_velocity, target_angular_velocity, ANGULAR_DAMP)
	else:
		angular_velocity = 0 #lerpf(angular_velocity, 0.0, ANGULAR_DAMP * 0.5)


func _get_lift() -> Vector2:
	var lift: Vector2 = Vector2.ZERO
	if linear_velocity.length() > 10.0:
		var dir = Vector2(cos(sprite.rotation), sin(sprite.rotation))
		var lift_dir = Vector2(-dir.y, -dir.x) # perpendiculaire à la vitesse
		lift = lift_dir * linear_velocity.length() * LIFT_FORCE
	return lift


func _apply_lift() -> void:
	if linear_velocity.length() > 10.0:
		var lift = _get_lift()
		apply_central_force(lift)


func _apply_lateral_drag() -> void:
	# Empêche le glissement latéral — l'avion ne peut pas "déraper" dans l'air
	var right = Vector2(-sin(rotation), cos(rotation))
	
	# Composante latérale de la vélocité
	var lateral_speed = linear_velocity.dot(right)
	
	# Annuler progressivement cette composante
	apply_central_force(-right * lateral_speed * DRAG_FORCE)


func is_on_floor() -> bool:
	return self.get_contact_count() > 0

##### SIGNAL RESPONSES #####
