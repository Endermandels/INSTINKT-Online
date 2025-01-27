extends Node2D
class_name MistSpray

var mist_area := preload("res://prefabs/mist_area_2d.tscn")

@onready var spray_particles := $GPUParticles2D
@onready var mist_area_spawn_timer := $MistAreaSpawnTimer

@export var spray_sound: AudioStreamPlayer2D
@export var player: Player

func _ready():
	spray_particles.emitting = false

func show_spray():
	if mist_area_spawn_timer.is_stopped():
		mist_area_spawn_timer.start()
		spray_particles.emitting = true
		
		var instance: MistArea2D = mist_area.instantiate()
		instance.player = player
		instance.global_position = global_position
		instance.rotation = get_parent().rotation
		get_tree().root.add_child(instance)
		
		if not spray_sound.playing:
			_play_spray_sound.rpc()

func hide_spray():
	spray_particles.emitting = false
	if spray_sound.playing:
		_stop_spray_sound.rpc()

@rpc("any_peer", "call_local", "reliable")
func _stop_spray_sound():
	spray_sound.stop()

@rpc("any_peer", "call_local", "reliable")
func _play_spray_sound():
	spray_sound.play()
