extends Node
class_name HUDCommands

@export var chat: Chat

signal clear_stink
signal get_sprayed
signal debug
signal teleport(x: float, y: float)
signal zoom_camera(amount: float)

func tp(args: Array[String]):
	teleport.emit(float(args[1]), float(args[2]))

func zoom(args: Array[String]):
	zoom_camera.emit(float(args[1]))

var COMMANDS = {
	'clear_stink': clear_stink.emit
	, 'get_sprayed': get_sprayed.emit
	, 'tp': tp
	, 'zoom': zoom
	, 'debug': debug.emit
}

func _ready():
	chat.connect("command_submitted", _on_chat_command_submitted)

func _on_chat_command_submitted(command: String):
	print("Received command: %s" % command)
	var command_args = command.split(" ")
	if not command_args[0] in COMMANDS:
		return
	if len(command_args) > 1:
		COMMANDS[command_args[0]].call(command_args)
	else:
		COMMANDS[command].call()
