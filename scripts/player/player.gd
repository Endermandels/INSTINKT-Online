extends CharacterBody2D
class_name Player


@export var MAX_SPEED = 100.0
const ACCEL = 0.7
const FRICTION = 0.9

var username: String = ""

var misting = false

@export var social_distancing = 100
@export var stink_push_intensity = 0.7
@export var sprayed_slowness = 80
@export var camera_zoom_max = 5
@export var camera_zoom_min = 0.5

@onready var anim_player := $AnimationPlayer
@onready var sprite := $Sprite2D
@onready var camera := $Camera2D
@onready var rollback_synchronizer := $RollbackSynchronizer
@onready var spray := $Spray
@onready var stats := $Stats
@onready var spray_hurtbox := $SprayHurtbox
@onready var player_detection := $PlayerDetection
@onready var step_sound := $ProximitySFX/Step
@onready var step_cooldown_timer := $Timers/StepCooldown
@onready var username_label := $HUD/Username/Label
@onready var hud_commands := $HUD/HUDCommands
@onready var hud := $HUD
@onready var collision := $CollisionShape2D

# Giving Client Authority
@export var chat: Chat
@export var spray_fx: SprayFX
@export var debug_info: DebugInfo
@export var input: MultiplayerInput
@export var player_id := 1:
	set(id):
		player_id = id
		input.set_multiplayer_authority(id) # Give client authority over inputs
		chat.set_multiplayer_authority(id) # Give client authority over chat
		spray_fx.set_multiplayer_authority(id) # etc.
		debug_info.set_multiplayer_authority(id)

func _ready() -> void:
	if multiplayer.get_unique_id() == player_id:
		# Only this player should have an active camera
		camera.make_current()
		step_cooldown_timer.connect("timeout", _on_step_cooldown_timer_timeout.rpc)
		hud_commands.connect("zoom_camera", _on_hud_commands_zoom_camera)
		hud_commands.connect("set_speed", _on_hud_commands_set_speed)
		hud_commands.connect("toggle_collision", _on_hud_commands_toggle_collision.rpc_id.bind(1))
	else:
		# All other players should not be active in the same client
		camera.enabled = false
	
	rollback_synchronizer.process_settings() # Call after establishing authority

func update_username(updated_username: String):
	if not updated_username:
		username_label.hide()
		return
	username = updated_username
	username_label.text = updated_username

func _apply_animations(delta: float):
	# Do nothing while spraying
	if anim_player.current_animation.contains("spray"):
		return
	
	var h_dir := input.h_dir
	
	if h_dir < 0:
		sprite.flip_h = true
		spray.position.x = 4
	elif h_dir > 0:
		sprite.flip_h = false
		spray.position.x = -4
	
	if velocity.length() > 30:
		anim_player.play("run")
	elif velocity.length() < 20:
		anim_player.play("idle")

	if input.use_long_spray:
		anim_player.play("spray")
	elif input.use_shotgun_spray:
		anim_player.play("shotgun_spray")
	elif input.use_mist_spray and not misting:
		anim_player.play("mist_spray", -1, 3, false)
		misting = true
	
	# Allow player to move while holding down mist
	if not input.use_mist_spray:
		misting = false

func _rollback_tick(delta: float, tick: float, is_fresh: bool):
	if input.teleport_pos != Vector2.ZERO:
		global_position = input.teleport_pos
		input.teleport_pos = Vector2.ZERO
	_apply_movement(delta)

func _apply_movement(delta: float):
	var h_dir = input.h_dir
	var v_dir = input.v_dir
	var dir := Vector2(h_dir, v_dir)
	
	# Run away from the one who sprayed
	# Run away from stinky
	for player in player_detection.players:
		if player.stats.stink_intensity < 0.5:
			continue 
		if global_position.distance_to(player.global_position) < social_distancing:
			dir -= global_position.direction_to(player.global_position) * stink_push_intensity
	
	# Do not move while playing the spray animation
	if anim_player.current_animation.contains("spray") and anim_player.current_animation != "mist_spray":
		dir = Vector2.ZERO
	
	if dir != Vector2.ZERO:
		# Slow sprayed players down
		var adjusted_speed = MAX_SPEED - (stats.stink_intensity**3)*sprayed_slowness
		velocity = velocity.lerp(dir*adjusted_speed, ACCEL)
		if step_cooldown_timer.is_stopped():
			step_cooldown_timer.start()
	else:
		step_cooldown_timer.stop()
		velocity = velocity.lerp(Vector2.ZERO, FRICTION)
	
	velocity *= NetworkTime.physics_factor # Correct velocity based on synced network tick loop
	move_and_slide()
	velocity /= NetworkTime.physics_factor # Revert velocity back to original (smooth movement)

@rpc("any_peer", "call_local", "unreliable")
func _on_step_cooldown_timer_timeout():
	step_sound.pitch_scale = randf_range(1,1.2)
	step_sound.play()

func _on_hud_commands_zoom_camera(amount: float):
	if amount <= 0:
		return
	camera.zoom = Vector2(amount, amount)
	hud.scale = Vector2(camera_zoom_min/amount, camera_zoom_min/amount)

func _on_hud_commands_set_speed(new_speed: float):
	_set_speed.rpc_id(1, new_speed)

@rpc("any_peer", "call_local", "reliable")
func _set_speed(new_speed: float):
	MAX_SPEED = new_speed

@rpc("any_peer", "call_local", "reliable")
func _on_hud_commands_toggle_collision():
	collision.set_deferred("disabled", not collision.disabled)

func _zoom_camera():
	if Input.is_action_just_released("MWU"):
		camera.zoom = camera.zoom * 1.1
		camera.zoom = camera.zoom.clampf(camera_zoom_min, camera_zoom_max)
		hud.scale = Vector2(camera_zoom_min/camera.zoom.x, camera_zoom_min/camera.zoom.y)
	if Input.is_action_just_released("MWD"):
		camera.zoom = camera.zoom / 1.1
		camera.zoom = camera.zoom.clampf(camera_zoom_min, camera_zoom_max)
		hud.scale = Vector2(camera_zoom_min/camera.zoom.x, camera_zoom_min/camera.zoom.y)

func _process(delta: float) -> void:
	if not multiplayer.is_server() or MultiplayerManager.host_mode_enabled:
		# For All Players on Screen
		_apply_animations(delta)
		_zoom_camera()
