extends Node
class_name MultiplayerInput

var h_dir: float = 0.0 # horizontal direction
var v_dir: float = 0.0 # vertical direction

@export var chat_box: ChatBox

func _ready():
	NetworkTime.before_tick_loop.connect(_gather)
	
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		# Don't allow processing of other peers from this peer (usually server)
		set_process(false)
		set_physics_process(false)
	
	h_dir = Input.get_axis("ui_left", "ui_right")
	v_dir = Input.get_axis("ui_up", "ui_down")

func _gather():
	# Align with the synchronized network tick loop
	# should only run on client end
	if not is_multiplayer_authority():
		return
	
	if not chat_box.visible:
		h_dir = Input.get_axis("ui_left", "ui_right")
		v_dir = Input.get_axis("ui_up", "ui_down")
	else:
		h_dir = 0
		v_dir = 0
