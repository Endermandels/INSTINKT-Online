extends Control
class_name DebugInfo

@export var player: Player
@export var stats: Stats
@export var hud_commands: HUDCommands

@onready var position_label := $VBoxContainer/Position
@onready var stink_intensity_label := $VBoxContainer/StinkIntensity

func _ready():
	hide()
	hud_commands.connect("toggle_debug", _on_hud_commands_debug)

func _on_hud_commands_debug():
	visible = not visible

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	position_label.text = str(player.global_position)
	stink_intensity_label.text = str(snapped(stats.stink_intensity, 0.01))
