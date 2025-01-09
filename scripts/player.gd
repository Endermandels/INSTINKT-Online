extends CharacterBody2D
class_name Player

const SPEED = 50.0
const ACCEL = 1.0
const FRICTION = 1.0

func _physics_process(delta: float) -> void:
	var h_dir := Input.get_axis("ui_left", "ui_right")
	var v_dir := Input.get_axis("ui_up", "ui_down")
	var dir = Vector2(h_dir, v_dir)
	if dir != Vector2.ZERO:
		velocity = velocity.lerp(dir*SPEED, ACCEL)
	else:
		velocity = velocity.lerp(dir*SPEED, FRICTION)
	move_and_slide()
