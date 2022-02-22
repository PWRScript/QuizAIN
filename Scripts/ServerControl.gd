extends Control

onready var serverButton: Button = $"/root/Game/MainMenu/ServerControl/Button" 
onready var server_port:SpinBox =  $"/root/Game/MainMenu/ServerControl/Port" 
onready var server_players:ItemList = $"/root/Game/MainMenu/ServerControl/OnlinePlayers" 
onready var server_kick:Button =  $"/root/Game/MainMenu/ServerControl/ButtonKick" 

onready var client_host : LineEdit = $"/root/Game/MainMenu/ClientControl/Host" 
onready var client_port : SpinBox = $"/root/Game/MainMenu/ClientControl/Port" 
onready var client_username : LineEdit = $"/root/Game/MainMenu/ClientControl/Username" 
onready var clientButton: Button = $"/root/Game/MainMenu/ClientControl/Connect" 

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func regen_players():
	
	server_players.clear()
	for player in Globals.game_data.players:
		if player.username != null:
			server_players.add_item(String(player.network_id) + " (" + player.username  + ")",null, true )
		else:
			server_players.add_item(String(player.network_id) + " (null)",null, true )

func _bye():
	# POR CADA JOGADOR
	
	for selected_player in server_players.get_selected_items():
		for connected_player in Globals.game_data.players:
			if server_players.get_item_text(selected_player).begins_with(str(connected_player.network_id)):
				
				get_tree().network_peer.disconnect_peer(connected_player.network_id)
				break
			
	
	
	regen_players()
# Called when the node enters the scene tree for the first time.
func _ready():
	serverButton.connect("toggled", self,"server_toggle")
	server_kick.connect("pressed",self, "_bye")

func _player_connected(id):
	print("[SERVER-CONNECT] Player " + str(id) + " connected")
	Globals.game_data.addPlayer(id)
	regen_players()
	
func _player_disconnected(id):
	print("[SERVER-DISCONNECT] Player " + str(id) + "successfully connected")
	Globals.game_data.removePlayerByID(id)
	regen_players()
	
func server_toggle(p: bool):
	var peer = get_tree().network_peer
	if p:
		# Start server
		serverButton.disabled = true
		
		server_port.editable = false
		
		client_host.editable = false
		client_port.editable = false
		client_username.editable = false
		clientButton.disabled = true
		
		serverButton.text = "Iniciando Servidor..."
		if peer != null:
			peer.close_connection()
			get_tree().network_peer = null
		
		if peer == null:
			peer = NetworkedMultiplayerENet.new()
			var status = peer.create_server(server_port.value)
			if status:
				serverButton.pressed = false
				server_port.value = server_port.value + 1 if server_port.value < server_port.max_value else 1025
				return
			
			get_tree().network_peer = peer
			
		
		
		get_tree().connect("network_peer_connected", self, "_player_connected")
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
			
		server_kick.disabled = false
			
			
		
		serverButton.text = "Parar Servidor"
		
		serverButton.disabled = false
	else:
		
		serverButton.disabled = true
		serverButton.text = "Parando Servidor..."
		server_kick.disabled = true
		if peer != null:
			peer.close_connection()
		get_tree().network_peer = null
		
		get_tree().disconnect("network_peer_connected", self, "_player_connected")
		get_tree().disconnect("network_peer_disconnected", self, "_player_disconnected")
		
		serverButton.text = "Iniciar Servidor"
		
		server_port.editable = true
		server_players.clear()
		
		client_host.editable = true
		client_port.editable = true
		client_username.editable = true
		clientButton.disabled = false
		
		
		serverButton.disabled = false
		
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
