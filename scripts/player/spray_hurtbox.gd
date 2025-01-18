extends Area2D
class_name SprayHurtbox

@export var stats: Stats
@export var sprite: Sprite2D

@onready var timer := $SprayTimer
@onready var particles := $GPUParticles2D

var tween: Tween

signal sprayed

func _ready():
	timer.connect("timeout", _on_timer_timeout.rpc)
	particles.emitting = false

func _process(delta: float) -> void:
	if stats.stinky:
		_apply_spray_effects() # sync spray effects

func _apply_spray_effects():
	sprite.modulate.b = 0
	particles.emitting = true

func _apply_hud_effects():
	pass

@rpc("any_peer", "call_local", "reliable")
func get_sprayed():
	stats.stinky = true
	if tween:
		tween.kill()
	_apply_spray_effects()
	sprayed.emit()
	timer.start()

@rpc("any_peer", "call_local", "reliable")
func _on_timer_timeout():
	tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate:b", 1, 1)
	particles.emitting = false
	stats.stinky = false
