extends Node2D
class_name Spray

@onready var sprite := $Sprite2D

@export var input: MultiplayerInput

signal released # When the spray leaves the player

func _ready():
	sprite.hide()

func show_spray():
	sprite.look_at(input.mouse_pos)
	sprite.rotation_degrees = wrapf(sprite.rotation_degrees, 0.0, 360.0) # keeps degrees within 0-360
	if sprite.rotation_degrees < 180:
		sprite.z_index = 2
	else:
		sprite.z_index = 0
	sprite.show()
	released.emit()
