extends Area2D
class_name MistArea2D

@export var player: Player

@onready var spray_area_timer := $SprayAreaTimer

func _ready() -> void:
	spray_area_timer.connect("timeout", _on_spray_area_timer_timeout)
	spray_area_timer.start()

func _on_spray_area_timer_timeout():
	queue_free()

func _search_for_hurtboxes():
	# when monitoring, check for the closest spray hurtboxes and spray them
	# spray all targets in area
	var closest_hurtboxes = [] # list of tuples containing hurtbox and distance
	
	for hurtbox: SprayHurtbox in get_overlapping_areas():
		if hurtbox.get_parent() == player:
			continue
		closest_hurtboxes.append(hurtbox)
	
	if len(closest_hurtboxes) > 0:
		for hurtbox in closest_hurtboxes:
			hurtbox.get_sprayed.rpc(3)

func _process(delta: float) -> void:
	_search_for_hurtboxes()
