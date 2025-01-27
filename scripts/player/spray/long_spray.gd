extends Node2D
class_name LongSpray

@onready var spray_particles := $GPUParticles2D
@onready var spray_area_timer := $SprayAreaTimer
@onready var area := $Area2D

@export var splash_radius: int = 10
@export var spray_sound: AudioStreamPlayer2D
@export var player: Player

func _ready():
	area.monitoring = false
	spray_particles.emitting = false
	spray_area_timer.connect("timeout", _on_spray_area_timer_timeout)

func _on_spray_area_timer_timeout():
	area.monitoring = false

func show_spray():
	area.monitoring = true # Used to enable the area for collision detection
	spray_particles.emitting = true
	spray_area_timer.start()
	_play_spray_sound.rpc()

@rpc("any_peer", "call_local", "reliable")
func _play_spray_sound():
	spray_sound.play()

func _search_for_hurtboxes():
	# when monitoring, check for the closest spray hurtboxes and spray them
	if not area.monitoring:
		return
	
	# only spray the closest target
	var closest_hurtboxes = [] # list of tuples containing hurtbox and distance
	var closest_dist = 9999999999
	
	for hurtbox: SprayHurtbox in area.get_overlapping_areas():
		if hurtbox.get_parent() == player:
			continue
		
		# found target
		var dist = player.global_position.distance_to(hurtbox.get_parent().global_position)
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
