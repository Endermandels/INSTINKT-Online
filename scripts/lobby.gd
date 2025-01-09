extends Node2D
class_name Lobby

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

const PORT = 4000
const IP_ADDRESS = "localhost"

@onready var host := $Host
@onready var join := $Join

func _ready():
	host.connect("pressed", _on_host_pressed)
	join.connect("pressed", _on_join_pressed)

func _on_join_pressed():
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func _on_host_pressed():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()

func _add_player(id=1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
