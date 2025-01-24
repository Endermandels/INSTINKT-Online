extends Node2D
class_name Spray

@onready var spray_particles := $GPUParticles2D
@onready var spray_area_timer := $SprayAreaTimer
@onready var area := $Area2D

@export var input: MultiplayerInput
@export var fade_duration: float = 0.5
@export var splash_radius: int = 10
@export var spray_sound: AudioStreamPlayer2D


signal released # When the player sprays

func _ready():
	area.monitoring = false
	spray_particles.emitting = false
	self.connect("released", _on_spray_released.rpc)
	spray_area_timer.connect("timeout", _on_spray_area_timer_timeout)

func _look_at_mouse():
	var dir = global_position.direction_to(input.mouse_pos)
	rotation = dir.angle()
	print(rotation)
	if dir.y > 0:
		print("in front")
		spray_particles.z_index = 2
	else:
		spray_particles.z_index = 0

func show_spray():
	_look_at_mouse()
	area.monitoring = true # Used to enable the area for collision detection
	spray_particles.emitting = true
	spray_area_timer.start()
	released.emit()

@rpc("any_peer", "call_local", "reliable")
func _on_spray_released():
	spray_sound.play()

func _on_spray_area_timer_timeout():
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
