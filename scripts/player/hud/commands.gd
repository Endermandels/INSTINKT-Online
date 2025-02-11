extends Node
class_name HUDCommands

@export var chat: Chat

signal clear_stink
signal get_sprayed
signal toggle_debug
signal toggle_collision
signal teleport(x: float, y: float)
signal zoom_camera(amount: float)
signal set_speed(new_speed: float)

# No Arguments #

func _toggle_debug(args: Array[String]):
	toggle_debug.emit()

func _toggle_collision(args: Array[String]):
	toggle_collision.emit()

func _clear_stink(args: Array[String]):
	clear_stink.emit()

func _get_sprayed(args: Array[String]):
	get_sprayed.emit()

# Has Arguments #

func _teleport(args: Array[String]):
	if len(args) < 3:
		return
	teleport.emit(float(args[1])*1000, float(args[2])*1000)

func _zoom_camera(args: Array[String]):
	if len(args) < 2:
		return
	zoom_camera.emit(float(args[1]))

func _set_speed(args: Array[String]):
	if len(args) < 2:
		return
	set_speed.emit(float(args[1]))

var COMMANDS = {
	'clear': _clear_stink
	, 'cl': _clear_stink
	
	, 'debug': _toggle_debug
	, 'db': _toggle_debug
	
	, 'zoom': _zoom_camera
	, 'zm': _zoom_camera
	
	, 'speed': _set_speed
	, 'sd': _set_speed
	
	, 'spray': _get_sprayed
	, 'sp': _get_sprayed
	
	, 'teleport': _teleport
	, 'tp': _teleport
	
	, 'collision': _toggle_collision
	, 'coll': _toggle_collision
}

func _ready():
	chat.connect("command_submitted", _on_chat_command_submitted)

func _on_chat_command_submitted(command: String):
	print("Received command: %s" % command)
	var command_args = command.split(" ")
	
	if not command_args[0] in COMMANDS:
		return
	
	COMMANDS[command_args[0]].call(command_args)
