extends Node


onready var world = get_parent()
onready var tilemap = $TileMap_Ground
onready var castle = $Castle
onready var chapel = $Chapel
onready var fogscreen = preload("res://resources/assets/vfx/ScreenFog.tscn")

var temperature = {}
var moisture = {}
var altitude = {}
var biome = {}
var open_simplex_noise = OpenSimplexNoise.new()
var objects = {}
var tiles = {"grass_1": 0, "grass_2": 1, "green_grass" : 2, "stone_1" : 3, 
	"stone_2" : 4, "stone_3" : 5, "forest_ground_1" : 6, "forest_ground_2" : 7, 
	"forest_ground_3" : 8, "barren" : 9, "border" : 10}
var object_tiles = {
	"tree_beech": preload("res://scenes/tree_beech.tscn"), 
	"tree_pine": preload("res://scenes/tree_pine.tscn"), 
	"tree_firs": preload("res://scenes/tree_firs.tscn")
}
var biome_data = {
	"grass": {"grass_1": 0.5, "grass_2": 0.5},
	"green_grass": {"green_grass": 1},
	"forest": {"forest_ground_1": 0.4, "forest_ground_2": 0.3, "forest_ground_3": 0.3},
	"light_forest": {"forest_ground_1": 0.4, "forest_ground_2": 0.3, "forest_ground_3": 0.3},
	"stone": {"grass_1": 0.3, "grass_2": 0.25, "stone_1": 0.15, "stone_2": 0.15, "stone_3": 0.15},
	"map_border" : {"border": 1}
}
var object_data = {
	"grass": {"tree_beech": 0.005, "tree_pine": 0.005},
	"green_grass": {},
	"forest": {"tree_beech": 0.13, "tree_pine": 0.19, "tree_firs": 0.19},
	"light_forest": {"tree_beech": 0.05, "tree_pine": 0.1, "tree_firs": 0.1},
	"stone": {"tree_firs": 0.01}, 
	"map_border" : {}
}

func _ready():
	generate_new_game()

func generate_map(per, oct):
	open_simplex_noise.seed = randi()
	open_simplex_noise.period = per
	open_simplex_noise.octaves = oct
	var grid_name = {}
	for x in world.map_width:
		for y in world.map_height:
			var rand := 2*(abs(open_simplex_noise.get_noise_2d(x,y)))
			grid_name[Vector2(x,y)] = rand
	return grid_name


func generate_new_game():
	temperature = generate_map(300, 5)
	moisture = generate_map(300, 5)
	altitude = generate_map(50, 5)
	set_tile(world.map_width, world.map_height)


func set_tile(width, height):
	for x in width:
		for y in height:
			var pos = Vector2(x, y)
			var alt = altitude[pos]
			var temp = temperature[pos]
			var moist = moisture[pos]
			
			if is_border(pos, 10):
				biome[pos] = "map_border"
				tilemap.set_cellv(pos, tiles[random_tile(biome_data,"map_border")])
				continue
			
			if castle.is_close_to_castle(pos):
				biome[pos] = "grass"
				tilemap.set_cellv(pos, tiles[random_tile(biome_data,"grass")])
				continue
			
			if chapel.is_close_to_chapel(pos):
				biome[pos] = "green_grass"
				tilemap.set_cellv(pos, tiles[random_tile(biome_data,"green_grass")])
				continue
				
			if alt > 0.8:
				biome[pos] = "stone"
				tilemap.set_cellv(pos, tiles[random_tile(biome_data,"stone")])
			elif between(alt, 0, 0.6):
				if between(moist, 0, 0.95) and between(temp, 0, 0.4):
					biome[pos] = "grass"
					tilemap.set_cellv(pos, tiles[random_tile(biome_data,"grass")])
				elif between(moist, 0.2, 0.5) and temp > 0.4:
					biome[pos] = "light_forest"
					tilemap.set_cellv(pos, tiles[random_tile(biome_data,"light_forest")])
				elif between(moist, 0.5, 0.95) and temp > 0.4:
					biome[pos] = "forest"
					tilemap.set_cellv(pos, tiles[random_tile(biome_data,"forest")])
				else:
					biome[pos] = "green_grass"
					tilemap.set_cellv(pos, tiles[random_tile(biome_data,"green_grass")])
			elif between(alt, 0.6, 0.8):
				biome[pos] = "light_forest"
				tilemap.set_cellv(pos, tiles[random_tile(biome_data,"light_forest")])
			else:
				biome[pos] = "grass"
				tilemap.set_cellv(pos, tiles[random_tile(biome_data,"grass")])
			
			if castle.is_on_berhegen(pos,10):
				biome[pos] = "stone"
				tilemap.set_cellv(pos, tiles[random_tile(biome_data,"map_border")])
				continue
			
	set_objects()
	set_fog()


func set_objects():
	objects = {}
	var count_beech = 0
	var count_pine = 0
	var count_firs = 0
	for pos in biome:
		var current_biome = biome[pos]
		var random_object = random_tile(object_data, current_biome)
		objects[pos] = random_object
		if random_object != null:
			if castle.is_within_castle(pos):
				tile_to_scene(random_object, pos)
		match random_object:
			"tree_beech": count_beech += 1
			"tree_pine": count_pine += 1
			"tree_firs": count_firs += 1
	print("Buchen: ", count_beech, ", Pinienkerne: ", count_pine, ", Fichten: ", count_firs)


func set_fog():
	var fog_sw = fogscreen.instance()
	fog_sw.rect_position = tilemap.map_to_world(Vector2(0,world.map_height))+Vector2(0,-1200)
	fog_sw.rect_size.x = 15000
	fog_sw.rect_rotation = 26.6
	var fog_nw = fogscreen.instance()
	fog_nw.rect_position = tilemap.map_to_world(Vector2(0,0))+Vector2(450,-1450)
	fog_nw.rect_size.x = 15000
	fog_nw.rect_rotation = 153.4
	var fog_se = fogscreen.instance()
	fog_se.rect_position = tilemap.map_to_world(Vector2(world.map_width,0))+Vector2(0,-1200)
	fog_se.rect_size.x = 15000
	fog_se.rect_rotation = -153.4
	var fog_ne = fogscreen.instance()
	fog_ne.rect_position = tilemap.map_to_world(Vector2(world.map_width,world.map_height))+Vector2(0,-1200)
	fog_ne.rect_size.x = 15000
	fog_ne.rect_rotation = -26.6
	world.call_deferred("add_child", fog_sw)
	world.call_deferred("add_child", fog_nw)
	world.call_deferred("add_child", fog_se)
	world.call_deferred("add_child", fog_ne)


func is_border(position, border_width):
	var temp = position.x == border_width
	temp = temp or position.x == world.map_width - border_width
	temp = temp or position.y == border_width
	temp = temp or position.y == world.map_height - border_width
	return temp


func between(val, start, end):
	if start <= val and val < end:
		return true


func random_tile(data, thisbiome):
	var current_biome = data[thisbiome]
	var rand_num = rand_range(0,1)
	var running_total = 0
	for tile in current_biome:
		running_total = running_total + current_biome[tile]
		if rand_num <= running_total:
			return tile
			
			
func tile_to_scene(random_object, pos):
	var instance = object_tiles[str(random_object)].instance()
	instance.position = tilemap.map_to_world(pos) + Vector2(4, 4)
	add_child(instance)
	return instance
