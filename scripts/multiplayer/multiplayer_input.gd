extends MultiplayerSynchronizer
class_name MultiplayerInput

var h_dir: float # horizontal direction
var v_dir: float # vertical direction

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		# Don't allow processing of other peers from this peer (usually server)
		set_process(false)
		set_physics_process(false)
	
	h_dir = Input.get_axis("ui_left", "ui_right")
	v_dir = Input.get_axis("ui_up", "ui_down")

func _physics_process(delta: float) -> void:
	# should only run on client end
	h_dir = Input.get_axis("ui_left", "ui_right")
	v_dir = Input.get_axis("ui_up", "ui_down")
