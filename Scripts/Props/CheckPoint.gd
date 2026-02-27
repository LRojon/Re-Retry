extends AnimatedSprite2D
class_name CheckPoint

enum	 CheckPointType {
	Starting,
	Check,
	Reverse,
	End
}

@export var type: CheckPointType = CheckPointType.Check

@onready var spawn_point = $SpawnPoint
@onready var trigger_zone = $TriggerZone

var activated: bool = false

func _ready() -> void:
	
	match type:
		CheckPointType.Check:
			play("Closed" if not activated else "Opened")
		CheckPointType.Starting:
			play("Starting")
	
	trigger_zone.body_entered.connect(_on_body_enter_trigger_zone)


func _on_body_enter_trigger_zone(body: Node2D):
	if body is Player:
		# Feature: Ajout d'un timer pour difficulté
		body.spawning_point = spawn_point.global_position
		if type == CheckPointType.Check and not activated:
			print("play animation")
			play("ClosedToOpened")
			await animation_finished
			play("Opened")
		activated = true
