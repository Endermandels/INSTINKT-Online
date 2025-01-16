extends Node
class_name SprayHurtbox

@export var stats: Stats
@export var sprite: Sprite2D

@onready var timer := $SprayTimer
@onready var particles := $GPUParticles2D

var tween: Tween

func _ready():
	timer.connect("timeout", _on_timer_timeout)
	particles.emitting = false

func get_sprayed():
	stats.stinky = true
	if tween:
		tween.kill()
	sprite.modulate.b = 0
	particles.emitting = true
	timer.start()

func _on_timer_timeout():
	tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate:b", 1, 1)
	particles.emitting = false
