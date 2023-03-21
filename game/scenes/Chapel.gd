extends StaticBody2D


const CHAPEL_RADIUS = 5

var start_position

onready var world = get_parent().get_parent()
onready var tilemap = $"../TileMap_Ground"
onready var castle = $"../Castle"


func _ready():
	randomize()
	start_position = castle.start_position + 50 * Vector2(rand_range(-1,1), rand_range(-1,1)).normalized()
	position = tilemap.map_to_world(start_position)


func _get_debug():
	return "Pos: %s" % [position.round()]


func is_close_to_chapel(position):
	return (start_position - position).length() < CHAPEL_RADIUS
