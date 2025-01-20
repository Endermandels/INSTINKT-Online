extends Node2D
class_name Lobby

@onready var host := $MultiplayerHUD/Panel/VBoxContainer/Host
@onready var join := $MultiplayerHUD/Panel/VBoxContainer/Join
@onready var ip_address_text := $MultiplayerHUD/Panel/IPAddress
@onready var multiplayer_hud := $MultiplayerHUD
@onready var floor_tile_map := $Floor
@onready var floor2_tile_map := $Floor2
@onready var decoration_tile_map := $Decoration
@onready var shadows_tile_map := $"Y-Sorted/Shadows"
@onready var small_objects_tile_map := $"Y-Sorted/SmallObjects"
@onready var tree_layer_1_tile_map := $"Y-Sorted/TreeLayer1"
@onready var tree_layer_2_tile_map := $"Y-Sorted/TreeLayer2"
@onready var tree_layer_3_tile_map := $"Y-Sorted/TreeLayer3"
@onready var username := $MultiplayerHUD/Panel/Username

func _set_tile_map_layer_visibility(visibility: bool):
	floor_tile_map.visible = visibility
	floor2_tile_map.visible = visibility
	decoration_tile_map.visible = visibility
	shadows_tile_map.visible = visibility
	small_objects_tile_map.visible = visibility
	tree_layer_1_tile_map.visible = visibility
	tree_layer_2_tile_map.visible = visibility
	tree_layer_3_tile_map.visible = visibility

func _ready():
	_set_tile_map_layer_visibility(false)
	multiplayer_hud.show()
	host.connect("pressed", _on_host_pressed)
	join.connect("pressed", _on_join_pressed)

func _on_join_pressed():
	if ip_address_text.text == "":
		ip_address_text.text = "localhost"
	MultiplayerManager.join_host(ip_address_text.text, username.text)
	multiplayer_hud.hide()
	_set_tile_map_layer_visibility(true)

func _on_host_pressed():
	MultiplayerManager.become_host(username.text)
	multiplayer_hud.hide()
	_set_tile_map_layer_visibility(true)
