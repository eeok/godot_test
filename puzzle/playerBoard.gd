#ça pique les yeux

extends Control

#I) ATTRIBUTS
#____________________________________
#constantes
const MIN_HIGHLIGHT_SIZE = Vector2(58, 58)
const MIN_CELL_SIZE = Vector2(54,54)
const PURPLISH = Color("ee82ee")
const REDISH = Color("ff7070")
const GRAYISH = Color("e6e6fa")

#noeuds enfants
onready var highlight = $ColorRect
onready var container = $GridContainer
onready var squares = container.get_children()

#attributs de la classe specifique a la logique du jeu
var hovered_node: ColorRect = null #carrés pointé par la souris
var selected = [] #les carrés sélectionnés par le joueur
var selecting = false #le joueur est en mode sélection
#_______________________________________


#II) FONCTIONS OVERRIDEES HERITEE DE NODE
#	ces fonction peuvent être appelées une ou plusieurs fois,
#	ce sont des fonction de bases de godot, tout noeud en hérite
#	le moment ou sont appelées ces fonction peut dépendre n'est pas géré par nous,
#	c'est géré par le moteur, un des interets d'utiliser un moteur de jeu
#_______________________________________


#appellée quand le noeud est "pret" (après la fonction _init de node)
func _ready():
	highlight.hide()

#-----
#event handling (appelée quand un des évenement est déclenché)
func _input(event):
	#move mouse
	if event is InputEventMouseMotion:
		hovered_node = get_node_at_pos(get_local_mouse_position())

	#click
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if hovered_node != null:
				selecting = true
				selected.clear()

		elif event.button_index == BUTTON_LEFT and not event.pressed:
			selecting = false

		elif event.button_index == BUTTON_RIGHT and event.pressed:
			selecting = false
			#supprime la selection si click gauche et 2 ou moins sélectionnés
			if selected.size() <= 2:
				selected.clear()
				highlight.set_size(MIN_HIGHLIGHT_SIZE)
			else:
				flip()


#-----
#logique de la sélection
#_physic_process est appelée environ 1 fois par seconde
func _physics_process(_delta):
	if selecting and hovered_node != null:

		#en sélection, mais rien dans selected
		if not selected:
			selected.append(hovered_node)

		#en sélection, et le carré pointé est aligné
		elif aligned(selected[0]):	
			var boxxx = self.selected[0]
			selected.clear()
			selected.append(boxxx)
			if hovered_node != selected[0]:
				add_colorrect()


				
#-----
#_process est appelée environ une fois par frame 
func _process(_delta):
	#1)sélection
	if selected:
		highlight.show()
		new_highlight()

	#2)pas de selection mais il faut dessiner le highlight sur la case pointée si il y'en a une
	elif hovered_node != null:
		highlight.color = GRAYISH
		highlight.show()	

		#!!!!! get_custom_minimum_size et non get_minimum_size
		highlight.set_position(hovered_node.get_position() + MIN_CELL_SIZE/2 - MIN_HIGHLIGHT_SIZE/2)
		
	#3)ni sélection ni pointé
	else:
		highlight.hide()
				
#_______________________________________


#III) FONCTIONS CUSTOM
#	utiles aux jeu
#_________________________________________


#mécanique de jeu fondamentale
#regarde dans la sélection et "swap" leur emplacement dans la gridcontainer
#!!!!!!!!!!!!!!!!! container.move_child au lieu de set_position comme un fou
func flip() -> void:
	if selected.size() > 2:
		for i in range(selected.size() / 2):
			var temp_index = selected[i].get_index()
			var dest_index = selected[selected.size() -1 -i].get_index()
			container.move_child(selected[i], dest_index)
			container.move_child(selected[selected.size() -1 -i], temp_index)

#-----
#s'assure de la sélection
#part de selected[0] et ajoute tout les carrée à cette sélection jusqu'au carré pointé par la souris
#le truc c'est qu'on utilise un gridcontainer, qui est une 
#structure de données a une dimension (pas un tableau 2d)
func add_colorrect() -> void:
	if(selected and hovered_node != null):
		var end_pos = hovered_node.get_index()
		var dir = get_direction(hovered_node)
		var leap = 0
		
		#au dessus, c'est 5 en moins de l'index actuel
		if dir == "up":
			leap = -5		
		#en dessous, c'est 5 en plus de l'index actuel
		elif dir == "down":
			leap = 5
		elif dir == "left":
			leap = -1
		elif dir == "right":
			leap = 1
		
		var start = selected[0].get_index() + leap
		for current_pos in range(start, end_pos, leap):
			selected.append(container.get_child(current_pos))
		selected.append(hovered_node)

#-----
#appelée par la fonction _process pour mettre a jour l'affichage de la surbrillance
func new_highlight() -> void:
	var dir = get_direction(selected[selected.size()-1])
	var magie : Vector2

	#changer la couleur selon la taille de la selection  
	if(selected.size() in [1,2]): 
			#si un seul, revient aux dimension d'origines  
		if selected.size() == 1:
			highlight.set_size(MIN_HIGHLIGHT_SIZE)
		highlight.color = REDISH
	else:
		highlight.color = PURPLISH
			
	#si plusieurs dans la selection
	if selected.size() > 1:
		var new_highlight_size: Vector2 = highlight.get_rect().size

		if(dir != "null"):
			if dir in ["up", "down"]:
				if(dir=="up"):
					magie = Vector2(0, -29*selected.size() + 29)
				else:
					magie = Vector2(0, 29*selected.size() - 29)

				new_highlight_size = Vector2(58, 58*selected.size())
			else:
				if dir == "right":
					magie = Vector2((29*(selected.size())) - 29, 0)
					
				else:
					magie = Vector2(-29*selected.size() + 29, 0)

				new_highlight_size = Vector2(58*selected.size(), 58)
		highlight.set_size(new_highlight_size)
	
	#dans tout les cas change la position
	highlight.set_position((selected[0].get_position() + selected[0].get_global_rect().size / 2 - highlight.get_global_rect().size / 2) + magie)


#-----
# Get the ColorRect node at the given local mouse position, or null if none is found.
func get_node_at_pos(pos: Vector2) -> ColorRect:
	for node in squares:
		if node is ColorRect and node.get_rect().has_point(pos):
			return node
	return null

#-----
#compare le premier carré de la sélection et le carré pointé
#retourne la direction du premier carré par rapport au carré pointé
func get_direction(rectangle: ColorRect) -> String:
	if selected and rectangle != null:
		if selected[0].get_rect().position.x == rectangle.get_rect().position.x:
			if selected[0].get_rect().position.y > rectangle.get_rect().position.y:
				return "up"
			elif selected[0].get_rect().position.y < rectangle.get_rect().position.y:
				return "down"
		if selected[0].get_rect().position.y ==rectangle.get_rect().position.y:
			if selected[0].get_rect().position.x > rectangle.get_rect().position.x:
				return "left"
			elif selected[0].get_rect().position.x < rectangle.get_rect().position.x:
				return "right"
	return "null"

#-----
#compare un rectangle au rectangle pointé par la souris
#retourne vrai si aligné horizontalement ou verticalement ou si rectangle == hovered_node
func aligned(rectangle: ColorRect)-> bool: 
	if hovered_node != null and hovered_node is ColorRect:
		var hovered_node_pos = hovered_node.get_global_position()
		var rectangle_pos = rectangle.get_global_position()
		if hovered_node_pos.y == rectangle_pos.y or hovered_node_pos.x == rectangle_pos.x:
			return true
		
	return false
	
	
