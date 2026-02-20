extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for node in get_children():
		if node is Player:
			node.spawning_point
	
	$CanvasLayer/Reset.connect("button_up", 
		func(): 
			get_tree().reload_current_scene()
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()
