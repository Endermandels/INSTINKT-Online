extends CharacterBody2D
class_name Player

const SPEED = 100.0
const ACCEL = 0.7
const FRICTION = 0.9
		

@onready var anim_player := $AnimationPlayer
@onready var sprite := $Sprite2D
@onready var camera := $Camera2D

@export var player_id := 1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id) # Give client authority over inputs

var h_dir: float
var v_dir: float

func _ready() -> void:
	if multiplayer.get_unique_id() == player_id:
		# Only this player should have an active camera
		camera.make_current()
	else:
		# All other players should not be active in the same client
		camera.enabled = false

func _apply_animations(delta: float):
	if h_dir < 0:
		sprite.flip_h = true
	elif h_dir > 0:
		sprite.flip_h = false
	
	if velocity.length() > 99:
		anim_player.play("run")
	elif velocity.length() < 20:
		anim_player.play("idle")
	

func _apply_movement(delta: float):
	h_dir = %InputSynchronizer.h_dir
	v_dir = %InputSynchronizer.v_dir
	var dir := Vector2(h_dir, v_dir)
	
	
	if dir != Vector2.ZERO:
		velocity = velocity.lerp(dir*SPEED, ACCEL)
	else:
		velocity = velocity.lerp(dir*SPEED, FRICTION)
	
	move_and_slide()

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_apply_movement(delta)
	
	if not multiplayer.is_server() or MultiplayerManager.host_mode_enabled:
		_apply_animations(delta)
