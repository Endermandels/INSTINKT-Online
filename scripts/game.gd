extends Node2D
class_name Lobby

@onready var host := $MultiplayerHUD/Panel/VBoxContainer/Host
@onready var join := $MultiplayerHUD/Panel/VBoxContainer/Join
@onready var ip_address_text := $MultiplayerHUD/Panel/IPAddress
@onready var multiplayer_hud := $MultiplayerHUD
@onready var floor_tile_map := $Floor
@onready var floor2_tile_map := $Floor2
@onready var floor3_tile_map := $Floor3
@onready var floor4_tile_map := $Floor4
@onready var shadows_tile_map := $"Shadows"
@onready var decoration_tile_map := $"Y-Sorted/Decoration"
@onready var small_objects_tile_map := $"Y-Sorted/SmallObjects"
@onready var tree_layer_1_tile_map := $"Y-Sorted/TreeLayer1"
@onready var tree_layer_2_tile_map := $"Y-Sorted/TreeLayer2"
@onready var tree_layer_3_tile_map := $"Y-Sorted/TreeLayer3"
@onready var username := $MultiplayerHUD/Panel/Username
@onready var connection_failed_label := $MultiplayerHUD/Panel/ConnectionFailed

var tween: Tween = null

func _set_tile_map_layer_visibility(visibility: bool):
	floor_tile_map.visible = visibility
	floor2_tile_map.visible = visibility
	floor3_tile_map.visible = visibility
	floor4_tile_map.visible = visibility
	decoration_tile_map.visible = visibility
	shadows_tile_map.visible = visibility
	small_objects_tile_map.visible = visibility
	tree_layer_1_tile_map.visible = visibility
	tree_layer_2_tile_map.visible = visibility
	tree_layer_3_tile_map.visible = visibility

func _ready():
	_set_tile_map_layer_visibility(false)
	MultiplayerManager.connection_failed.connect(_on_multiplayer_manager_connection_failed)
	multiplayer_hud.show()
	connection_failed_label.modulate.a = 0
	host.connect("pressed", _on_host_pressed)
	join.connect("pressed", _on_join_pressed)

func _on_join_pressed():
	if ip_address_text.text == "":
		ip_address_text.text = "localhost"
	if not MultiplayerManager.join_host(ip_address_text.text, username.text):
		_connection_failed()
		return
	multiplayer_hud.hide()
	_set_tile_map_layer_visibility(true)

func _on_host_pressed():
	if not MultiplayerManager.become_host(username.text):
		_connection_failed()
		return
	multiplayer_hud.hide()
	_set_tile_map_layer_visibility(true)

func _connection_failed():
	print("connection failed")
	_set_tile_map_layer_visibility(false)
	multiplayer_hud.show()
	if tween:
		tween.kill()
	connection_failed_label.modulate.a = 1
	tween = get_tree().create_tween()
	tween.tween_property(connection_failed_label, "modulate:a", 0, 2)

func _on_multiplayer_manager_connection_failed():
	_connection_failed()
