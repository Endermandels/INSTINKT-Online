extends Control
class_name SprayFX

@export var spray_hurtbox: SprayHurtbox
@export var player_detection: PlayerDetection
@export var stats: Stats
@export var hud_commands: HUDCommands

@onready var sprayed_color_rect := $SprayedColorRect
@onready var stinky_color_rect := $StinkyColorRect
@onready var blur_color_rect := $BlurColorRect
@onready var spray_particles := $GPUParticles2D

var tween: Tween = null

# blur strength
var sprayed_lod: float  = 0
var stink_lod: float = 0

func _ready():
	show()
	sprayed_color_rect.color.a = 0
	stinky_color_rect.color.a = 0
	_blur(0)
	spray_hurtbox.connect("sprayed", _on_spray_hurtbox_sprayed)
	hud_commands.connect("clear_stink", _on_hud_commands_clear_stink)
	spray_particles.emitting = false

func _on_spray_hurtbox_sprayed():
	if not is_multiplayer_authority():
		return
	
	if tween:
		tween.kill()
	
	sprayed_color_rect.color = Color.WHITE
	sprayed_lod = 4
	
	tween = get_tree().create_tween()
	tween.tween_property(sprayed_color_rect, "color", Color(0.89, 0.812, 0, 0.737), 5)
	tween.chain().tween_property(sprayed_color_rect, "color:a", 0, spray_hurtbox.timer.wait_time/4)
	tween.parallel().tween_property(self, "sprayed_lod", 0, spray_hurtbox.timer.wait_time/4)
	spray_particles.emitting = true

func _on_hud_commands_clear_stink():
	if tween:
		tween.kill()
	sprayed_color_rect.color.a = 0
	stinky_color_rect.color.a = 0
	sprayed_lod = 0
	_blur(0)
	spray_particles.emitting = false

func _blur(amount: float):
	blur_color_rect.material.set_shader_parameter("lod",amount)

func _handle_stinky_players():
	stinky_color_rect.color.a = 0
	stink_lod = 0
	for player in player_detection.players:
		if player.stats.stink_intensity > 0:
			var dist = get_parent().global_position.distance_to(player.global_position)
			var closeness = 1 - dist / player_detection.collision_shape.shape.radius
			var intensity = min(player.stats.stink_intensity, closeness)
			stinky_color_rect.color.a = max(
				stinky_color_rect.color.a,
				intensity
			)
			stink_lod = max(stink_lod, intensity*2)

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	_handle_stinky_players()
	_blur(max(sprayed_lod, stink_lod))
