extends Node2D

onready var playerBoard = $playerBoard


func _on_button_pressed():
	playerBoard.new()
