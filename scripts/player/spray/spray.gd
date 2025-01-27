extends Node2D
class_name Spray

@export var input: MultiplayerInput
@export var player: Player

@onready var long_spray := $LongSpray
@onready var shotgun_spray := $ShotgunSpray
@onready var mist_spray := $MistSpray

signal released # When the player sprays

func _look_at_mouse():
	var dir = global_position.direction_to(input.mouse_pos)
	rotation = dir.angle()

func show_spray():
	_look_at_mouse()
	long_spray.show_spray()
	released.emit()

func show_shotgun_spray():
	_look_at_mouse()
	shotgun_spray.show_spray()
	released.emit()

func show_mist_spray():
	_look_at_mouse()
	mist_spray.show_spray()
	released.emit()

func _process(delta: float) -> void:
	if player.misting:
		_look_at_mouse()
		mist_spray.show_spray()
	else:
		mist_spray.hide_spray()
