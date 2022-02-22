extends KinematicBody2D

export (int) var run_speed = 195
export (int) var jump_speed = -200
export (int) var gravity = 500

var velocity = Vector2()
var jumping = false
onready var _animated_sprite : AnimatedSprite = $Sprite
var last_m = "none"


func get_input():
	velocity.x = 0
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_select')
	

	if jump: #and is_on_floor():
		if last_m == "right" or last_m == "none":
			_animated_sprite.play("gh")
			_animated_sprite.flip_h = false
			
		elif last_m == "left":
			_animated_sprite.play("gh")
			_animated_sprite.flip_h = true
		jumping = true
		velocity.y = jump_speed
		
		
	if right:
		velocity.x += run_speed
		_animated_sprite.play("anim_move")
		_animated_sprite.flip_h = false
		last_m = "right"
	elif left:
		velocity.x -= run_speed
		
		_animated_sprite.play("anim_move")
		_animated_sprite.flip_h = true
		last_m = "left"
	else:
		_animated_sprite.play("anim_stickman")
	
	#rpc("update_position", get_tree().get_network_unique_id(), position.x, position.y)
		
remote func update_position(id: int, pos_x: float, pos_y: float):
	var sender : int = get_tree().get_rpc_sender_id()
	if sender == 1:
		Globals.game_data.getPlayerByID(id).setPosition(pos_x,pos_y)
	elif sender == id:
		Globals.game_data.getPlayerByID(id).setPosition(pos_x,pos_y)

func _physics_process(delta):
	if is_network_master():
		get_input()
		velocity.y += gravity * delta
		if jumping and is_on_floor():
			jumping = false
		velocity = move_and_slide(velocity, Vector2(0, -1))
