extends CharacterBody2D
class_name Player

const SPEED = 100.0
const ACCEL = 0.7
const FRICTION = 0.9

@export var player_id := 1:
	set(id):
		player_id = id

@onready var anim_player := $AnimationPlayer
@onready var sprite := $Sprite2D

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		var h_dir := Input.get_axis("ui_left", "ui_right")
		var v_dir := Input.get_axis("ui_up", "ui_down")
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
