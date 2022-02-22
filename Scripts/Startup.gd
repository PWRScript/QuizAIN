extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var progress_bar: ProgressBar = $LoadingScreen/ProgressBar 
onready var progress_text: Label = $LoadingScreen/DetailedText


onready var loading_screen: Control = $LoadingScreen
onready var main_menu_screen: Control = $MainMenu
onready var game_screen: Node2D = $Game
# Called when the node enters the scene tree for the first time.
func _ready():
	progress_text.text = "Iniciando Recursos..."
	Globals.game_data = Globals.Game.new()
	progress_bar.value = 20
	
	main_menu_screen.show()
	loading_screen.hide()
	
	
	
	
	
	
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
