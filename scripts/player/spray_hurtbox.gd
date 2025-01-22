extends Area2D
class_name SprayHurtbox

@export var stats: Stats
@export var sprite: Sprite2D
@export var hud_commands: HUDCommands

@onready var timer := $SprayTimer
@onready var particles := $GPUParticles2D

var tween: Tween

signal sprayed
signal effects_resolved # When the spray dissapates

func _ready():
	timer.connect("timeout", _on_timer_timeout.rpc)
	hud_commands.connect("clear_stink", _on_hud_commands_clear_stink)
	particles.emitting = false

func _process(delta: float) -> void:
	if stats.stink_intensity > 0:
		_apply_spray_effects() # sync spray effects
	
	if is_multiplayer_authority():
		stats.stink_intensity = timer.time_left / timer.wait_time

func _apply_spray_effects():
	sprite.modulate.b = 0
	particles.emitting = true

@rpc("any_peer", "call_local", "reliable")
func get_sprayed(spraying_player: Player):
	if tween:
		tween.kill()
	_apply_spray_effects()
	sprayed.emit()
	timer.start()

@rpc("any_peer", "call_local", "reliable")
func _on_timer_timeout():
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate:b", 1, 1)
	particles.emitting = false
	stats.stink_intensity = 0
	effects_resolved.emit()

func _on_hud_commands_clear_stink():
	timer.stop()
	timer.timeout.emit()
