extends Node2D

var players = []

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	get_tree().connect("connected_to_server", self, "_connected_ok")
	


remote func register_player(id):
	# Get the id of the RPC sender.
	var h = get_node_or_null("/root/Game/Game/Players")
	if h != null:
		h.add_child(Globals.game_data.ensurePlayer(id).ensureNode())
	
remote func update_position(id: int, pos_x: float, pos_y: float):
	var sender : int = get_tree().get_rpc_sender_id()
	Globals.game_data.getPlayerByID(id).setPosition(pos_x,pos_y)



func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	
	var h = $Players
	if h != null:
		for node in Globals.game_data.ensureNodes():
			h.add_child(node)
	
	#if get_tree().get_network_unique_id() == 1:
	#	if id != 1:
	#		for i in players:
	#			rpc_id(id, "register_player", i)
	#			
	#	players.append(id)

func _connected_ok():
	rpc("register_player", get_tree().get_network_unique_id())
	register_player(get_tree().get_network_unique_id())
			
	
	
func _player_disconnected(id):
	Globals.game_data.removePlayerByID(id)
