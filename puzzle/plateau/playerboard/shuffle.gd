#j'aurais pas du utiliser ça.........s
#askip tilemap aurait été plus approprié
extends GridContainer

onready var children = get_children()

func shuffle():
	children.shuffle()

	# Re-add the children in their shuffled order
	for child in children:
		remove_child(child)
		add_child(child)

func _ready():
	#génère  une nouvelle seed
	randomize()

	shuffle()
