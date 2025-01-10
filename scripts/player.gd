extends CharacterBody2D
class_name Player

const SPEED = 100.0
const ACCEL = 0.7
const FRICTION = 0.9
		

@onready var anim_player := $AnimationPlayer
@onready var sprite := $Sprite2D

@export var player_id := 1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id) # Give client authority over inputs

func _apply_movement(delta: float):
	var h_dir: float = %InputSynchronizer.h_dir
	var v_dir: float = %InputSynchronizer.v_dir
	var dir = Vector2(h_dir, v_dir)
	
	if h_dir < 0:
		sprite.flip_h = true
	if h_dir > 0:
		sprite.flip_h = false
	
	if dir != Vector2.ZERO:
		if velocity.length() > 99:
			anim_player.play("run")
		velocity = velocity.lerp(dir*SPEED, ACCEL)
	else:
		if velocity.length() < 20:
			anim_player.play("idle")
		velocity = velocity.lerp(dir*SPEED, FRICTION)
	
	move_and_slide()

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_apply_movement(delta)
