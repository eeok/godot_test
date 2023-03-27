extends Node2D

onready var playerBoard = $playerBoard
onready var modelSquares = $modelBoard.get_node("GridContainer").get_children()
onready var l = $label


var playSquares = []
var over = false


func _ready():
	l.show()

func _on_button_pressed():
	over = false
	playerBoard.new()

func _physics_process(_delta):
	if not over:
		playSquares = playerBoard.get_node("GridContainer").get_children()
		var ent : int = 0
		for child in playSquares:
			if child is ColorRect:
				if modelSquares[ent].color != child.color:
					break
				ent += 1

		if ent == modelSquares.size():
			over = true



func _process(_delta):
	if over:
		l.show()
	elif l.is_visible_in_tree():
		l.hide()
