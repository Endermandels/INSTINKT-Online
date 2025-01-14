extends Node
class_name MultiplayerInput

# Synced
var h_dir: float = 0.0 # horizontal direction
var v_dir: float = 0.0 # vertical direction

# Client-side
@export var chat: Chat

var pause_input = false

func _ready():
	NetworkTime.before_tick_loop.connect(_gather)
	
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		# Don't allow processing of other peers from this peer (usually server)
		set_process(false)
		set_physics_process(false)
	
	chat.connect("chat_opened", _on_chat_opened)
	chat.connect("chat_closed", _on_chat_closed)
	
	h_dir = Input.get_axis("ui_left", "ui_right")
	v_dir = Input.get_axis("ui_up", "ui_down")

func _on_chat_opened():
	pause_input = true

func _on_chat_closed():
	pause_input = false

func _gather():
	# Align with the synchronized network tick loop
	# should only run on client end
	if not is_multiplayer_authority():
		return
	
	if pause_input:
		h_dir = 0
		v_dir = 0
		return
	
	h_dir = Input.get_axis("ui_left", "ui_right")
	v_dir = Input.get_axis("ui_up", "ui_down")
