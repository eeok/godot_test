#une véritable boucherie

#bug: quand en model sélection et qu'on pointe vers en dehors la grille, affiche seulement premier
#logique ok.... regarder le fonctions d'affichages

#todo 
#	-enlever les nombres magiques ,
 
#	-variable direct pour les enfants de gridcontainer au lieu d'appeler get_children a chaque fois

#	-truc de l'inference de type chelou : y'a pas comme en en python l'operateur // pour etre sur 
#                                         d'avoir un entier (et ça pourrait merder)

#	-moins de var, + de const quand possible

#	-et tout le reste::^))

extends Control

#I) ATTRIBUTS
#____________________________________
#constantes
const highlight_size = Vector2(58, 58)

#noeuds enfants
onready var highlight = $ColorRect
onready var container = $GridContainer

#attributs de la classe specifique a la logique du jeu
var hovered_node: ColorRect = null #carrés pointé par la souris
var selected = [] #les carrés sélectionnés par le joueur
var last_hovered : ColorRect = null
var selecting = false #le joueur est en mode sélection
var switched = false #la selection courante a été "switchée/flippée/swappée" (jsp comment faire un truc simple pour calculer le highlight)
					 #true si la selection est en miroir par rapport au debut, false sinon
#_______________________________________


#II) FONCTIONS OVERRIDEES HERITEE DE NODE
#	ces fonction peuvent être appelées une ou plusieurs fois,
#	ce sont des fonction de bases de godot, tout noeud en hérite
#	le moment ou sont appelées ces fonction peut dépendre n'est pas géré par nous,
#	c'est géré par le moteur, un des interets d'utiliser un moteur de jeu
#_______________________________________


#appellée quand le noeud est "pret" (après initialisation, la fonction _init de node)
func _ready():
	highlight.hide()

#-----
#event handling (appelée quand un des évenement est déclenché)
	#cas 1 : bouger la souris (savoir si elle se trouve sur une case)
	#cas 2 : click de souris
func _input(event):
	#move mouse
	if event is InputEventMouseMotion:
		var local_pos = get_local_mouse_position()
		hovered_node = get_node_pos(local_pos)

	#click
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT :
			if event.pressed:
				switched = false
				if hovered_node != null:
					selecting = true
					selected.clear()
			elif not event.pressed:
				selecting = false

		elif event.button_index == BUTTON_RIGHT:
			selecting = false
			if selected.size() <= 2:
				selected.clear()
			elif event.pressed:
				switched = not switched
				flip()


#-----
#_physic_process est appelée environ 1 fois par seconde
func _physics_process(_delta):
	#changer la selection
	if selecting and hovered_node != null:
		if not selected:
			selected.append(hovered_node)
		elif aligned(selected[0]):	
			var boxxx = self.selected[0]
			#var direction = get_direction()
			selected.clear()
			selected.append(boxxx)
			if hovered_node != selected[0]:
				add_colorrect()


				
#-----
#_process est appelée environ une fois par frame 
#par defaut un projet godot tourne en 60 fps
#modifie la logique et l'ui
func _process(_delta):
	#1)sélection
	if selected:
		highlight.show()
		new_highlight()

	#2)pas de selection mais il faut dessiner le highlight sur la case pointée si il y'en a une
	elif hovered_node != null and not selected and not selecting:
		#remettre la taillr d'origine
		highlight.color = Color("e6e6fa")
		highlight.show()	

		#!!!!! get_custom_minimum_size et non get_minimum_size(
		highlight.set_position(hovered_node.get_position() + hovered_node.get_rect().size / 2 - highlight_size / 2)
		
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
			var dest_index = selected[selected.size() - 1 - i].get_index()
			container.move_child(selected[i], dest_index)
			container.move_child(selected[selected.size() - 1 - i], temp_index)

#-----
#s'assure de la sélection
#part de selected[0] et ajoute tout les carrée à cette sélection jusqu'au carré pointé par la souris
#le gros en jeu c'est qu'on utilise un gridcontainer, qui est une 
#structure de données a une dimension (pas un tableau 2d)
func add_colorrect() -> void:
	if(selected and hovered_node != null):
		var i = selected[0].get_index()
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
		
		var current_pos = i + leap
		while current_pos != end_pos:
			
			var node = container.get_child(current_pos)
			selected.append(node)
			current_pos += leap
		selected.append(hovered_node)

#-----
# Get the ColorRect node at the given local mouse position, or null if none is found.
func get_node_pos(pos: Vector2) -> ColorRect:
	for node in container.get_children():
		if node is ColorRect and node.get_rect().has_point(pos):
			return node
	return null

#-----

#appelée par la fonction _process pour mettre a jour l'affichage de la surbrillance
#calcule le coin supérieur gauche et la taille(largeur,longueur) du colorrect qui sert de visualisation 
#pour la sélection, et met a jour ce colorrect(coordonées et couleurs)
#fonction non-100%safe, ne vérifie pas les trucs critiques (si selected n'est pas vide et hoverred_node existe)
func new_highlight() -> void:
	var dir = get_direction(selected[selected.size()-1])
	var magie : Vector2
	var magie_noire : Vector2 = Vector2()
	var topsquare = selected[0]

	#changer la couleur selon la taille de la selection  
	if(selected.size() in [1,2]): 
			#si un seul, revient aux dimension d'origines  
		if selected.size() == 1:
			highlight.set_size(highlight_size)
		highlight.color = Color("ff7070")#rouge
	else:
		highlight.color = Color("ee82ee")#mauve
	

		
	#si plusieurs dans la selection
	#prendre en compte switched
	#si gauche ou haut, le topleft doit se calculer selon hovered_node
	#sinon le premier rectangle reste l'endroit pour le topleft
	if selected.size() > 1:
		#dans ce cas, un sélection de 2 horizontalement
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
	highlight.set_position((topsquare.get_position() + topsquare.get_global_rect().size / 2 - highlight.get_global_rect().size / 2) + magie)





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
	
