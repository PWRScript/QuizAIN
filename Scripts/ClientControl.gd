extends Control

onready var serverButton: Button = $"/root/Game/MainMenu/ServerControl/Button" 
onready var server_port:SpinBox =  $"/root/Game/MainMenu/ServerControl/Port" 
onready var server_players:ItemList = $"/root/Game/MainMenu/ServerControl/OnlinePlayers" 

onready var client_host : LineEdit = $"/root/Game/MainMenu/ClientControl/Host" 
onready var client_port : SpinBox = $"/root/Game/MainMenu/ClientControl/Port" 
onready var client_username : LineEdit = $"/root/Game/MainMenu/ClientControl/Username" 
onready var clientButton: Button = $"/root/Game/MainMenu/ClientControl/Connect"
onready var errorpopup: PopupDialog = $"/root/Game/ErrorDialog" 

onready var errorpopup_info1: Label = $"/root/Game/ErrorDialog/Information" 
onready var errorpopup_info2: Label = $"/root/Game/ErrorDialog/Information2" 


onready var progress_bar: ProgressBar = $"/root/Game/LoadingScreen/ProgressBar" 
onready var progress_text: Label = $"/root/Game/LoadingScreen/DetailedText"

onready var scene_loader : Control = $"/root/Game/LoadingScreen"
onready var scene_mainmenu : Control = $"/root/Game/MainMenu"
onready var scene_game: Node2D = $"/root/Game/Game"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	clientButton.connect("pressed", self,"server_connect")
	
	get_tree().connect("connected_to_server", self, "_connected_ok")

func server_connect():
	# 
	scene_game.visible = false
	scene_mainmenu.visible = false
	scene_loader.visible = true
	
	
	progress_bar.value = 0
	progress_text.text = "Removendo Conexões Antigas..."
	var peer = get_tree().network_peer
	if peer != null:
		peer.close_connection()
		get_tree().network_peer = null
	
	progress_bar.value = 25
	progress_text.text = "Contactando o Anfitrião..."
	peer = NetworkedMultiplayerENet.new()
	var status = peer.create_client(client_host.text, client_port.value)
	if status:
		errorpopup_info1.text = "Ocorreu um erro"
		errorpopup_info2.text = "Não foi possível contactar o Anfitrião\nVerifica se introduziste corretamente o Endereço IP/Hostname"
		
		errorpopup.popup()
		return
	
	progress_bar.value = 50
	progress_text.text = "Conectando ao Servidor..."
	get_tree().network_peer = peer

func _connected_ok():
	
	scene_game.visible = true
	scene_loader.visible = false
	scene_mainmenu.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
