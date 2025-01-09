extends Node2D
class_name Lobby

@onready var host := $MultiplayerHUD/Panel/VBoxContainer/Host
@onready var join := $MultiplayerHUD/Panel/VBoxContainer/Join
@onready var multiplayer_hud := $MultiplayerHUD
@onready var tile_map := $TileMapLayer

func _ready():
	tile_map.hide()
	host.connect("pressed", _on_host_pressed)
	join.connect("pressed", _on_join_pressed)

func _on_join_pressed():
	MultiplayerManager.join_host()
	multiplayer_hud.hide()
	tile_map.show()

func _on_host_pressed():
	MultiplayerManager.become_host()
	multiplayer_hud.hide()
	tile_map.show()
