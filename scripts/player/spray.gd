extends Node2D
class_name Spray

@onready var sprite := $Sprite2D

@export var input: MultiplayerInput

signal released # When the spray leaves the player

func _ready():
	sprite.hide()

func show_spray():
	sprite.look_at(input.mouse_pos)
	sprite.show()
	released.emit()
