extends Node2D
class_name Lobby

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

const PORT = 4000
const IP_ADDRESS = "localhost"

@onready var host := $MultiplayerHUD/Panel/VBoxContainer/Host
@onready var join := $MultiplayerHUD/Panel/VBoxContainer/Join
@onready var multiplayer_hud := $MultiplayerHUD
@onready var tile_map := $TileMapLayer

func _ready():
	tile_map.hide()
	host.connect("pressed", _on_host_pressed)
	join.connect("pressed", _on_join_pressed)

func _on_join_pressed():
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer_hud.hide()
	tile_map.show()

func _on_host_pressed():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()

func _add_player(id=1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	multiplayer_hud.hide()
	tile_map.show()
