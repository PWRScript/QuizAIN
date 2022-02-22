extends Node



onready var player_model = preload("res://Scenes/Player.tscn")
onready var player_script = preload("res://Scripts/PlayerController.gd")

class Answer:
	var id: int
	var type: String = "text"
	var content_text: String
	var acceptable: bool = false

	func _init(ID: int, ContentText: String, Acceptable: bool= false, Typeq: String = "text"):
		id = ID
		type = Typeq
		content_text = ContentText
		acceptable = Acceptable

class Player:
	var network_id: int = 1
	var username = null
	
	var node: KinematicBody2D = null
	
	var pos_x: float = 22
	var pos_y: float = 409
	
	func unregisterNode():
		if node != null:
			node.queue_free()
			node = null
	
	
	func registerNode() -> bool:
		if node == null:
			var player_ld = preload("res://Scenes/Player.tscn")
			var script_ld = preload("res://Scripts/PlayerController.gd")
			node = player_ld.instance()
			node.set_network_master(network_id)
			node.name = String(network_id)
			node.set_script(script_ld)
			node.set_process(true)
			node.set_physics_process(true)
			node.position = Vector2(pos_x,pos_y)
			
			return true
		return false
	
	func ensureNode(regen: bool = false) -> KinematicBody2D:
		if regen == true:
			unregisterNode()
		registerNode()
		return node
		
	func setPosition(x = null, y = null):
		if x != null:
			pos_x = x 
		if y != null:
			pos_y = y 
		
		if node != null:
			node.position = Vector2(x,y)

	func _init(NetworkID: int):
		network_id = NetworkID

class Question:
	var id: int
	var question_text: String
	var options: Array

	func _init(ID: int, QuestionText: String, Options: Array):
		id = ID
		question_text = QuestionText
		options = Options

class Game:
	var max_players: int = 32
	var players: Array = []
	var questions: Array = []

	func countPlayers() -> int:
		return len(players)
	
	func registerNodes():
		for player in players:
			player.registerNode()
			
	func unregisterNodes():
		for player in players:
			player.unregisterNode()
	
	func ensureNodes(regen: bool = false):
		var n = []
		for player in players:
			n.append(player.ensureNode(regen))
		return n
			

	func countQuestions() -> int:
		return len(questions)
	
	func getQuestion(id: int) -> Question:
		for question in questions:
			if question.id == id:
				return question
		return null
	
	func isQuestion(id: int) -> bool:
		if getQuestion(id) != null:
			return true
		return false

	func getPlayerByID(id: int) -> Player:
		for player in players:
			if player.network_id == id:
				return player
		return null
		
	func isPlayerByID(id: int) -> bool:
		if getPlayerByID(id) != null:
			return true
		return false
	
	func setPlayerUsername(network_id: int, username: String ) -> Player:
		var player: Player = getPlayerByID(network_id)
		if player == null:
			return null
		player.username = username
		return player
	
	func unsetPlayerUsername(network_id: int) -> Player:
		var player: Player = getPlayerByID(network_id)
		if player == null:
			return null
		player.username = null
		return player	

	func getPlayerByUsername(username: String) -> Player:
		for player in players:
			if player.username == username:
				return player
		return null
			
	func isPlayerByUsername(username: String) -> bool:
		if getPlayerByUsername(username) != null:
			return true
		return false
	
	func ensurePlayer(id: int) -> Player:
		var player: Player = getPlayerByID(id)
		if player == null:
			return addPlayer(id)
		else:
			return player
	
	func addPlayer(network_id: int) -> Player:
		if isPlayerByID(network_id):
			return null
		else:
			var player: Player = Player.new(network_id)
			players.append(player)
			return player
	
	func removePlayerByID(network_id: int) -> bool:
		var player: Player = getPlayerByID(network_id)
		if player == null:
			return false
		player.unregisterNode()
		players.erase(player)
		return true

	func removePlayerByUsername(username: String) -> bool:
		var player: Player = getPlayerByUsername(username)
		if player == null:
			return false
		player.unregisterNode()
		players.erase(player)
		return true
	
	func addQuestion(id: int, question_text: String, options: Array) -> Question:
		if isQuestion(id):
			return null
		else:
			var question: Question = Question.new(id, question_text, options)
			questions.append(question)
			return question
	
	func removeQuestion(id: int) -> bool:
		var player: Question = getQuestion(id)
		if player != null:
			return false
		questions.erase(player)
		return true

var game_data : Game

var current_scene = null



func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
