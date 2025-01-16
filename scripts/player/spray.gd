extends Node2D
class_name Spray

@onready var sprite := $Sprite2D
@onready var area := $Sprite2D/Area2D

@export var input: MultiplayerInput
@export var spray_fade_duration: float = 0.5

var tween: Tween

signal released # When the spray leaves the player

func _ready():
	area.monitoring = false
	area.connect("area_entered", _on_area_entered)
	sprite.hide()

func _look_at_mouse():
	sprite.look_at(input.mouse_pos)
	sprite.rotation_degrees = wrapf(sprite.rotation_degrees, 0.0, 360.0) # keeps degrees within 0-360
	if sprite.rotation_degrees < 180:
		sprite.z_index = 2
	else:
		sprite.z_index = 0

func _reset_sprite():
	sprite.modulate.a = 1
	area.monitoring = true # Used to enable the area for collision detection

func _tween_sprite():
	if tween:
		tween.kill()
	
	tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate:a", 0, spray_fade_duration)
	tween.connect("finished", _on_tween_finished)

func show_spray():
	_look_at_mouse()
	_reset_sprite()
	sprite.show()
	_tween_sprite()
	released.emit()

func _on_tween_finished():
	sprite.hide()
	area.monitoring = false

func _on_area_entered(area: Area2D):
	if area.get_parent() != get_parent():
		area.get_sprayed()
