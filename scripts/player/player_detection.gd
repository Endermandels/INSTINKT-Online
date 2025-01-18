extends Area2D
class_name PlayerDetection

@onready var collision_shape := $CollisionShape2D

var players = []

func _ready() -> void:
	self.connect("body_entered", _on_body_entered)
	self.connect("body_exited", _on_body_exited)

func _on_body_entered(body: Player):
	if body != get_parent():
		players.append(body)

func _on_body_exited(body: Player):
	players.erase(body)
