extends GridContainer

func shuffle():
	get_children().shuffle()

#_ready me parait plus safe que _init, pour s'assurer que tout les noeuds  
#enfants ont déja été initialisés
func _ready():
	shuffle()
