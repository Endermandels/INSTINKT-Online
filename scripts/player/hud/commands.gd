extends Node
class_name HUDCommands

@export var chat: Chat

signal clear_stink
signal get_sprayed
signal debug
signal teleport(x: float, y: float)
signal zoom_camera(amount: float)
signal set_speed(new_speed: float)

func tp(args: Array[String]):
	teleport.emit(float(args[1]), float(args[2]))

func zoom(args: Array[String]):
	zoom_camera.emit(float(args[1]))

func speed(args: Array[String]):
	set_speed.emit(float(args[1]))

var COMMANDS = {
	'clear': clear_stink.emit
	, 'cl': clear_stink.emit
	
	, 'debug': debug.emit
	, 'db': debug.emit
	
	, 'zoom': zoom
	, 'zm': zoom
	
	, 'speed': speed
	, 'sd': speed
	
	, 'spray': get_sprayed.emit
	, 'sp': get_sprayed.emit
	
	, 'tp': tp
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
