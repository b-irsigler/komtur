extends StaticBody2D


const CASTLE_RADIUS = 15

onready var world = get_parent()
onready var start_position = Vector2(world.map_width / 2 - 2, world.map_height / 2 - 6)
onready var tilemap = $"../TileMap_Ground"


func _ready():
	position = tilemap.map_to_world(start_position)


func is_close_to_castle(character_position):
	return (start_position - character_position).length() < CASTLE_RADIUS


func is_character_close_to_castle(character_position):
	return tilemap.world_to_map(position - character_position).length() < CASTLE_RADIUS
