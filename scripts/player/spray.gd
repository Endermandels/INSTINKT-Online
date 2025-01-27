extends Node2D
class_name Spray

@export var input: MultiplayerInput

@onready var long_spray := $LongSpray
@onready var shotgun_spray := $ShotgunSpray

signal released # When the player sprays

func _look_at_mouse():
	var dir = global_position.direction_to(input.mouse_pos)
	rotation = dir.angle()
	if dir.y > 0:
		z_index = 2
	else:
		z_index = 0

# Long spray
func show_spray():
	_look_at_mouse()
	long_spray.show_spray()
	released.emit()

func show_shotgun_spray():
	_look_at_mouse()
	shotgun_spray.show_spray()
	released.emit()
