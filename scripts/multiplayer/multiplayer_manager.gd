extends Node

const SERVER_PORT = 4000

var player_scene := preload("res://prefabs/player.tscn")
var _players_spawn_node: Node2D
var host_mode_enabled = false

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server...")
		MultiplayerManager.become_host()

func join_host(server_ip: String = "localhost", username: String = ""):
	print("Joining Host...")
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(server_ip, SERVER_PORT)
	multiplayer.multiplayer_peer = client_peer # establishes that this instance is a client
	
	# Wait until connected to send the username
	multiplayer.connected_to_server.connect(_on_connected_to_server.bind(username))

func _on_connected_to_server(username: String):
	_update_player_username.rpc_id(1, multiplayer.get_unique_id(), username)

@rpc("any_peer", "call_local", "reliable")
func _update_player_username(id: int, username: String):
	if not _players_spawn_node.has_node(str(id)):
		push_error("Player not instantiated")
		return
	_players_spawn_node.get_node(str(id)).update_username(username)

func become_host(username: String = ""):
	print("Becoming Host...")
	
	host_mode_enabled = true
	
	# Only need this on server because that's where players are added to the game
	_players_spawn_node = get_tree().get_current_scene().get_node("Y-Sorted/Players")
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = server_peer # establishes that this instance is a server
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_del_player)
	
	if not OS.has_feature("dedicated_server"):
		_add_player()
		_update_player_username(1, username)

func _add_player(id=1):
	print("Player %s joined the game!" % id)
	
	var player = player_scene.instantiate()
	player.player_id = id
	player.name = str(id)
	
	_players_spawn_node.add_child(player, true)

func _del_player(id: int):
	print("Player %s left the game!" % id)
	
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()
