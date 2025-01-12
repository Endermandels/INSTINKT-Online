extends Control
class_name HUD

signal chat_opened
signal chat_closed

@onready var chat := $Chat

func set_player_id(player_id: int):
	chat.player_id = player_id

func _ready() -> void:
	chat.connect("chat_opened", chat_opened.emit)
	chat.connect("chat_closed", chat_closed.emit)
