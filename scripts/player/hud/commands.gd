extends Node
class_name HUDCommands

@export var chat: Chat

signal clear_stink

var COMMANDS = {
	'clear stink': clear_stink.emit
}

func _ready():
	chat.connect("command_submitted", _on_chat_command_submitted)

func _on_chat_command_submitted(command: String):
	print("Received command: %s" % command)
	if not command in COMMANDS:
		return
	COMMANDS[command].call()
