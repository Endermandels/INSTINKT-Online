extends Control
class_name DebugInfo

@export var player: Player
@export var stats: Stats
@export var hud_commands: HUDCommands
@export var spray_timer: Timer

@onready var position_label := $VBoxContainer/Position
@onready var stink_intensity_label := $VBoxContainer/StinkIntensity
@onready var pid_label := $VBoxContainer/PID
@onready var stink_time_left_label := $VBoxContainer/SprayTimeLeft

func _ready():
	hide()
	hud_commands.connect("toggle_debug", _on_hud_commands_debug)

func _on_hud_commands_debug():
	visible = not visible

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	position_label.text = 'position: ' + str(Vector2(player.global_position / 1000).snappedf(0.01))
	pid_label.text = 'pid: ' + player.name
	stink_intensity_label.text = 'stink: ' + str(snapped(stats.stink_intensity, 0.01))
	stink_time_left_label.text = 'stink time: ' + str(snapped(spray_timer.time_left, 0.01))
