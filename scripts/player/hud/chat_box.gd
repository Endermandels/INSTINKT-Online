extends Control
class_name Chat

@onready var chat_display_label := $ChatDisplayContainer/Label
@onready var chat_box := $ChatBox
@onready var chat_display_timer := $ChatDisplayTimer

var tween: Tween = null

signal chat_opened
signal chat_closed
signal sent_message(message: String)
signal command_submitted(command: String)

func _ready():
	chat_box.hide()
	chat_display_label.modulate.a = 0
	chat_box.connect("text_submitted", _on_chat_box_text_submitted)
	chat_box.connect("text_changed", _on_chat_box_text_changed.rpc)
	chat_display_timer.connect("timeout", _on_chat_display_timer_timeout)
	self.connect("chat_closed", _on_chat_closed.rpc)

func _handle_toggle():
	if Input.is_action_just_pressed("chat", true):
		chat_box.visible = not chat_box.visible
		if chat_box.visible:
			chat_box.call_deferred("grab_focus")
			chat_opened.emit()
		else:
			chat_box.call_deferred("release_focus")
			chat_box.clear()
			chat_closed.emit()

func _on_chat_box_text_submitted(submitted_string: String):
	if submitted_string.strip_edges() == "":
		return
	
	if submitted_string.begins_with("`"):
		command_submitted.emit(submitted_string.right(submitted_string.length()-1))
		return
	
	# Send message to server
	send_message.rpc_id(1, submitted_string.strip_edges())
	chat_box.clear()

@rpc("any_peer", "call_local", "reliable")
func _on_chat_box_text_changed(new_text: String):
	if chat_display_label.modulate.a > 0 and chat_display_label.text != ". . .":
		return
	if tween:
		tween.kill()
		tween = null
	chat_display_label.text = ". . ."
	chat_display_label.modulate.a = 1
	chat_display_timer.start()

@rpc("any_peer", "call_local", "reliable")
func _on_chat_closed():
	if chat_display_label.text == ". . .":
		chat_display_label.modulate.a = 0

@rpc("any_peer", "call_local", "reliable")
func send_message(message: String):
	var sender_id = multiplayer.get_remote_sender_id()
	print("Player %s messaged: %s" % [sender_id, message])
	update_chat_label.rpc(message) # Update the chat message across all clients

@rpc("any_peer", "call_local", "reliable")
func update_chat_label(message: String):
	if message.strip_edges() != "" and message != chat_display_label.text:
		if tween:
			tween.kill()
			tween = null
		chat_display_label.text = message.strip_edges()
		chat_display_label.modulate.a = 1
		chat_display_timer.start()

func _on_chat_display_timer_timeout():
	tween = get_tree().create_tween()
	tween.tween_property(chat_display_label, "modulate:a", 0, 1)

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Current Player only
	_handle_toggle()
