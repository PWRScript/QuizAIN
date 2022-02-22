extends PopupDialog


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var scene_mainmenu : Control = $"/root/Game/MainMenu"
onready var scene_game: Node2D = $"/root/Game/Game"

onready var server_port: SpinBox =  $"/root/Game/MainMenu/ClientControl/Port" 
onready var server_host: LineEdit =  $"/root/Game/MainMenu/ClientControl/Host" 
onready var scene_loader: Control = $"/root/Game/LoadingScreen"

onready var menu = $Menu
onready var close = $Close
onready var info = $Information2

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	close.connect("pressed", self,"close_press")
	menu.connect("pressed", self,"main_menu")
	

func _server_disconnected():
	info.text = "Foste desconectado do servidor"
	popup()
	
func _connected_fail():
	if server_host.text == "":
		server_host.text = "127.0.0.1"
	info.text = "Não foi possivel estabelecer conexão com o servidor\nVerifica se a firewall não está a bloquear a porta '" + str(server_port.value) + "/UDP'\nO servidor está a ser executado no anfitrião '" + server_host.text + "'"
	popup()

func network_disconnect():
	
	var d = get_tree().network_peer
	if d != null:
		d.close_connection()

func main_menu():
	network_disconnect()
	scene_loader.visible = false
	scene_game.visible = false
	scene_mainmenu.visible = true
	hide()

func close_press():
	network_disconnect()
	get_tree().quit(0)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
