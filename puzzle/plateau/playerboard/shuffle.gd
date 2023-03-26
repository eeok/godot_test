#j'aurais pas du utiliser ça.........s
#askip tilemap aurait été plus approprié
extends GridContainer

func _ready():
# Get all children of the GridContainer
	var children = get_children()

	# Shuffle the children randomly
	randomize()
	children.shuffle()

	# Re-add the children in their shuffled order
	for child in children:
		remove_child(child)
		add_child(child)
