extends YSort


var start_position

onready var world = get_parent().get_parent()
onready var tilemap = $"../TileMap_Ground"
onready var castle = $"../Castle"
onready var chapel = $"../Chapel"


func _ready():
	randomize()
	
	var castle_to_chapel:Vector2 = chapel.start_position - castle.start_position
	
	start_position = castle.start_position + 1.1 * castle_to_chapel.rotated(0.6)
	position = tilemap.map_to_world(start_position)

func is_close_to_village(position):
	return (start_position - position).length() < 10
