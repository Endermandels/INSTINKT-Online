extends CharacterBody2D
class_name Player

const SPEED = 100.0
const ACCEL = 0.7
const FRICTION = 0.9
		

@onready var anim_player := $AnimationPlayer
@onready var sprite := $Sprite2D
@onready var camera := $Camera2D
@onready var rollback_synchronizer := $RollbackSynchronizer
@onready var spray := $Spray

# Giving Client Authority
@export var chat: Chat
@export var input: MultiplayerInput
@export var player_id := 1:
	set(id):
		player_id = id
		input.set_multiplayer_authority(id) # Give client authority over inputs
		chat.set_multiplayer_authority(id) # Give client authority over chat

func _ready() -> void:
	if multiplayer.get_unique_id() == player_id:
		# Only this player should have an active camera
		camera.make_current()
	else:
		# All other players should not be active in the same client
		camera.enabled = false
	
	rollback_synchronizer.process_settings() # Call after establishing authority

func _apply_animations(delta: float):
	# Do nothing while spraying
	if anim_player.current_animation == "spray":
		return
	
	var h_dir := input.h_dir
	
	if h_dir < 0:
		sprite.flip_h = true
		spray.position.x = 4
	elif h_dir > 0:
		sprite.flip_h = false
		spray.position.x = -4
	
	if velocity.length() > 99:
		anim_player.play("run")
	elif velocity.length() < 20:
		anim_player.play("idle")

	if input.use_special:
		anim_player.play("spray")

func _rollback_tick(delta: float, tick: float, is_fresh: bool):
	_apply_movement(delta)

func _apply_movement(delta: float):
	var h_dir = input.h_dir
	var v_dir = input.v_dir
	var dir := Vector2(h_dir, v_dir)
	
	# Do not move while playing the spray animation
	if anim_player.current_animation == "spray":
		dir = Vector2.ZERO
	
	if dir != Vector2.ZERO:
		velocity = velocity.lerp(dir*SPEED, ACCEL)
	else:
		velocity = velocity.lerp(dir*SPEED, FRICTION)
	
	velocity *= NetworkTime.physics_factor # Correct velocity based on synced network tick loop
	move_and_slide()
	velocity /= NetworkTime.physics_factor # Revert velocity back to original (smooth movement)

func _process(delta: float) -> void:
	if not multiplayer.is_server() or MultiplayerManager.host_mode_enabled:
		# For All Players on Screen
		_apply_animations(delta)
