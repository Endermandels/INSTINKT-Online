extends Control
class_name DebugInfo

@export var player: Player
@export var hud_commands: HUDCommands

@onready var position_label := $VBoxContainer/Position

func _ready():
	hide()
	hud_commands.connect("debug", _on_hud_commands_debug)

func _on_hud_commands_debug():
	visible = not visible

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	position_label.text = str(player.global_position)
