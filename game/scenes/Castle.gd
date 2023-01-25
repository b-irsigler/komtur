extends StaticBody2D


const CASTLE_RADIUS = 15

onready var world = get_parent()
onready var start_position = Vector2(world.map_width / 2 - 2, world.map_height / 2 - 6)
onready var tilemap = $"../TileMap_Ground"
onready var sprite = $Castle2


func _ready():
	position = tilemap.map_to_world(start_position)


func is_close_to_castle(character_position):
	return (start_position - character_position).length() < CASTLE_RADIUS


func is_character_close_to_castle(character_position):
	return tilemap.world_to_map(position - character_position).length() < CASTLE_RADIUS


func is_within_castle(character_position):
	return sprite.get_rect().has_point(character_position)

func is_on_berhegen(character_position, border_width):
	var temp = abs(character_position.x - start_position.x) < border_width
	temp = temp and abs(character_position.y - start_position.y) < border_width
	return temp
