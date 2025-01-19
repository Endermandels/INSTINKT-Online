extends Node2D
class_name Lobby

@onready var host := $MultiplayerHUD/Panel/VBoxContainer/Host
@onready var join := $MultiplayerHUD/Panel/VBoxContainer/Join
@onready var ip_address_text := $MultiplayerHUD/Panel/IPAddress
@onready var multiplayer_hud := $MultiplayerHUD
@onready var tile_map := $TileMapLayer
@onready var username := $MultiplayerHUD/Panel/Username
@onready var players := $Players

func _ready():
	tile_map.hide()
	host.connect("pressed", _on_host_pressed)
	join.connect("pressed", _on_join_pressed)

func _on_join_pressed():
	if ip_address_text.text == "":
		ip_address_text.text = "localhost"
	MultiplayerManager.join_host(ip_address_text.text, username.text)
	multiplayer_hud.hide()
	tile_map.show()

func _on_host_pressed():
	MultiplayerManager.become_host(username.text)
	multiplayer_hud.hide()
	tile_map.show()
