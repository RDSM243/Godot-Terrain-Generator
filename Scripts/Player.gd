extends "res://Scripts/Templates/Mob.gd"

var direction = Vector2.ZERO

onready var world_tiles = GameManager.world.get_node("Tiles")

func _ready():
	GameManager.playerNode = self
	pass

func _input(event):
	if Input.is_action_pressed("Exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("Reload") && !GameManager.isConsoleVisible:
		GameManager.regenerate_world()
	pass
	
func _physics_process(delta):
	move()
	pass

func move():
	if !GameManager.isConsoleVisible:
		direction.x = (Input.get_action_strength("move_right")-Input.get_action_strength("move_left"))
		direction.y = (Input.get_action_strength("move_down")-Input.get_action_strength("move_up"))
		direction = direction.normalized()
	else:
		direction = Vector2.ZERO
	
	if direction.x != 0 || direction.y != 0:
		$AnimatedSprite.play("walk")
		if direction.x > 0 : $AnimatedSprite.flip_h = false
		elif direction.x < 0 : $AnimatedSprite.flip_h = true
	else: $AnimatedSprite.play("idle")
		
	
	motion.x = (direction.x*speed)
	motion.y = (direction.y*speed)
	pass

func get_pos_in_map():
	return world_tiles.world_to_map(position)
	pass
