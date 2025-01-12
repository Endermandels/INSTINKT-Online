extends LineEdit
class_name ChatBox

var player_id = 0

func _ready():
	hide()
	self.connect("text_submitted", _on_chat_box_text_submitted)

func _handle_toggle():
	if Input.is_action_just_pressed("chat", true):
		visible = not visible
		if visible:
			call_deferred("grab_focus")

func _on_chat_box_text_submitted(submitted_string: String):
	print(submitted_string)
	clear()

func _process(delta: float) -> void:
	if not multiplayer.is_server() or MultiplayerManager.host_mode_enabled and \
			multiplayer.get_unique_id() == player_id:
		# Current Player only
		_handle_toggle()
