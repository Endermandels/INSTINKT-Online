extends Node2D
class_name Spray

@onready var sprite := $Sprite2D

@export var input: MultiplayerInput

func _ready():
	sprite.hide()

func _process_spray(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	if input.use_special:
		show_spray.rpc(input.mouse_pos)

@rpc("any_peer", "call_local", "reliable")
func show_spray(mouse_pos):
	sprite.look_at(mouse_pos)
	sprite.show()

func _rollback_tick(delta: float, tick: float, is_fresh: bool):
	_process_spray(delta)
