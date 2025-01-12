extends Control
class_name Chat

var player_id = 0

@onready var chat_display_label := $ChatDisplayContainer/Label
@onready var chat_box := $ChatBox
@onready var chat_display_timer := $ChatDisplayTimer

var tween: Tween = null

signal chat_opened
signal chat_closed

func _ready():
	chat_box.hide()
	chat_display_label.modulate.a = 0
	chat_box.connect("text_submitted", _on_chat_box_text_submitted)
	chat_display_timer.connect("timeout", _on_chat_display_timer_timeout)

func _handle_toggle():
	if Input.is_action_just_pressed("chat", true):
		chat_box.visible = not chat_box.visible
		if chat_box.visible:
			chat_box.call_deferred("grab_focus")
			chat_opened.emit()
		else:
			chat_closed.emit()

func _on_chat_box_text_submitted(submitted_string: String):
	if submitted_string == "":
		return
	if tween:
		tween.kill()
	chat_display_label.text = submitted_string
	chat_display_label.modulate.a = 1
	chat_display_timer.start()
	chat_box.clear()

func _on_chat_display_timer_timeout():
	tween = get_tree().create_tween()
	tween.tween_property(chat_display_label, "modulate:a", 0, 1)

func _process(delta: float) -> void:
	if not multiplayer.is_server() or MultiplayerManager.host_mode_enabled and \
			multiplayer.get_unique_id() == player_id:
		# Current Player only
		_handle_toggle()
