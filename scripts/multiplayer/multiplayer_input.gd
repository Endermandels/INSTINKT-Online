extends Node2D
class_name MultiplayerInput

# Synced
var h_dir: float = 0.0 # horizontal direction
var v_dir: float = 0.0 # vertical direction
var use_long_spray: bool = false
var use_shotgun_spray: bool = false
var mouse_pos: Vector2 = Vector2.ZERO
var teleport_pos: Vector2 = Vector2.ZERO

# Client-side
@export var chat: Chat
@export var hud_commands: HUDCommands

var pause_input = false

func _ready():
	NetworkTime.before_tick_loop.connect(_gather)
	
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		# Don't allow processing of other peers from this peer (usually server)
		set_process(false)
		set_physics_process(false)
	
	chat.connect("chat_opened", _on_chat_opened)
	chat.connect("chat_closed", _on_chat_closed)
	hud_commands.connect("teleport", _on_hud_commands_teleport)

	h_dir = Input.get_axis("ui_left", "ui_right")
	v_dir = Input.get_axis("ui_up", "ui_down")
	use_long_spray = Input.is_action_just_pressed("long_spray")
	use_shotgun_spray = Input.is_action_just_pressed("shotgun_spray")

func _on_chat_opened():
	pause_input = true

func _on_chat_closed():
	pause_input = false

func _on_hud_commands_teleport(x: float, y: float):
	teleport_pos = Vector2(x, y)

func _gather():
	# Align with the synchronized network tick loop
	# should only run on client end
	if not is_multiplayer_authority():
		return
	
	# Allow people to spray while chatting :P
	use_long_spray = Input.is_action_pressed("long_spray")
	use_shotgun_spray = Input.is_action_pressed("shotgun_spray")
	if use_long_spray or use_shotgun_spray:
		mouse_pos = get_global_mouse_position()
	
	
	# Do not allow player to move while chatting
	if pause_input:
		h_dir = 0
		v_dir = 0
		return
	
	h_dir = Input.get_axis("ui_left", "ui_right")
	v_dir = Input.get_axis("ui_up", "ui_down")
