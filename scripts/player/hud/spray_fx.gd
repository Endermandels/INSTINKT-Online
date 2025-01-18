extends Control
class_name SprayFX

@export var spray_hurtbox: SprayHurtbox

@onready var color_rect := $ColorRect

var tween: Tween = null

func _ready():
	show()
	color_rect.color.a = 0
	spray_hurtbox.connect("sprayed", _on_spray_hurtbox_sprayed)
	spray_hurtbox.connect("effects_resolved", _on_spray_hurtbox_effects_resolved)

func _on_spray_hurtbox_sprayed():
	if not is_multiplayer_authority():
		return
	
	if tween:
		tween.kill()
	
	color_rect.color = Color.WHITE
	
	tween = get_tree().create_tween()
	tween.tween_property(color_rect, "color", Color(0.89, 0.812, 0, 0.737), 5)
	tween.connect("finished", _on_tween_finished)

func _on_tween_finished():
	tween = get_tree().create_tween()
	tween.tween_property(color_rect, "color:a", 0.2, 20)

func _on_spray_hurtbox_effects_resolved():
	if not is_multiplayer_authority():
		return
	
	tween = get_tree().create_tween()
	tween.tween_property(color_rect, "color:a", 0, 0.5)
