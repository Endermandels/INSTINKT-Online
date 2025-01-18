extends Node2D
class_name Spray

@onready var sprite := $Sprite2D
@onready var area := $Sprite2D/Area2D

@export var input: MultiplayerInput
@export var fade_duration: float = 0.5
@export var splash_radius: int = 10
@export var spray_sound: AudioStreamPlayer2D

var tween: Tween

signal released # When the player sprays

func _ready():
	area.monitoring = false
	sprite.hide()
	self.connect("released", _on_spray_released.rpc)

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
	tween.tween_property(sprite, "modulate:a", 0, fade_duration)
	tween.connect("finished", _on_tween_finished)

func show_spray():
	_look_at_mouse()
	_reset_sprite()
	sprite.show()
	_tween_sprite()
	released.emit()

@rpc("any_peer", "call_local", "reliable")
func _on_spray_released():
	spray_sound.play()

func _on_tween_finished():
	sprite.hide()
	area.monitoring = false

func _search_for_hurtboxes():
	# when monitoring, check for the closest spray hurtboxes and spray them
	if not area.monitoring:
		return
	
	# only spray the closest target
	var closest_hurtboxes = [] # list of tuples containing hurtbox and distance
	var closest_dist = 9999999999
	
	for hurtbox: SprayHurtbox in area.get_overlapping_areas():
		if hurtbox.get_parent() == get_parent():
			continue
		
		# found target
		var dist = get_parent().global_position.distance_to(hurtbox.get_parent().global_position)
		if dist < closest_dist - splash_radius:
			# much closer
			closest_hurtboxes.clear()
			closest_hurtboxes.append(hurtbox)
			closest_dist = dist
		elif dist < closest_dist + splash_radius:
			# close enough to be sprayed
			closest_hurtboxes.append(hurtbox)
	
	if len(closest_hurtboxes) > 0:
		for hurtbox in closest_hurtboxes:
			hurtbox.get_sprayed.rpc()
		area.monitoring = false # stop scanning after finding a target

func _process(delta: float) -> void:
	_search_for_hurtboxes()
