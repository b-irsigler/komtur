extends Node2D

export var width  = 600
export var height  = 200
onready var tilemap = $TileMap_Ground
var temperature = {}
var moisture = {}
var altitude = {}
var biome = {}
var openSimplexNoise = OpenSimplexNoise.new()

var objects = {}


var tiles = {"grass_1": 0, "grass_2": 1, "green_grass" : 2, "stone_1" : 3, "stone_2" : 4, "stone_3" : 5, "forest_ground_1" : 6, "forest_ground_2" : 7, "forest_ground_3" : 8, "barren" : 9}


#var object_tiles = {"tree": preload("res://Tree.tscn"), "cactus": preload("res://Cactus.tscn"), "spruce_tree": preload("res://Spruce_tree.tscn")}


var biome_data = {
	"grass": {"grass_1": 0.5, "grass_2": 0.5},
	"green_grass": {"green_grass": 1},
	"forest": {"forest_ground_1": 0.4, "forest_ground_2": 0.3, "forest_ground_3": 0.3},
	"stone": {"stone_1": 0.4, "stone_2": 0.3, "stone_3": 0.3}, 
	"barren": {"barren": 1},
}

"""
var object_data = {
	"plains": {"tree": 0.03},
	"beach": {"tree": 0.01}, 
	"jungle": {"tree": 0.04},
	"desert": {"cactus": 0.03}, 
	"lake": {},
	"mountain": {"spruce_tree":0.02},
	"snow": {"spruce_tree": 0.02},
	"ocean":{}
}
"""

func generate_map(per, oct):
	openSimplexNoise.seed = randi()
	openSimplexNoise.period = per
	openSimplexNoise.octaves = oct
	var gridName = {}
	for x in width:
		for y in height:
			var rand := 2*(abs(openSimplexNoise.get_noise_2d(x,y)))
			gridName[Vector2(x,y)] = rand
	return gridName


func _ready():
	temperature = generate_map(300, 5)
	moisture = generate_map(300, 5)
	altitude = generate_map(50, 5)
	set_tile(width, height)
	
	
	
func set_tile(width, height):
	for x in width:
		for y in height:
			var pos = Vector2(x, y)
			var alt = altitude[pos]
			var temp = temperature[pos]
			var moist = moisture[pos]
			
			if alt > 0.8:
				biome[pos] = "stone"
				tilemap.set_cellv(pos, tiles[random_tile(biome_data,"stone")])
			#Other Biomes
			elif between(alt, 0, 0.8):
				#plains
				if between(moist, 0, 0.9) and between(temp, 0, 0.6):
					biome[pos] = "grass"
					tilemap.set_cellv(pos, tiles[random_tile(biome_data,"grass")])
				#jungle
				elif between(moist, 0.4, 0.9) and temp > 0.6:
					biome[pos] = "forest"
					tilemap.set_cellv(pos, tiles[random_tile(biome_data,"forest")])
				#desert
				elif temp > 0.6 and moist < 0.4:
					biome[pos] = "barren"
					tilemap.set_cellv(pos, tiles[random_tile(biome_data,"barren")])
				#lakes
				elif moist >= 0.9:
					biome[pos] = "green_grass"
					tilemap.set_cellv(pos, tiles[random_tile(biome_data,"green_grass")])
			#Snow
			else:
				biome[pos] = "grass"
				tilemap.set_cellv(pos, tiles[random_tile(biome_data,"grass")])
"""
	set_objects()
"""


func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()

func between(val, start, end):
	if start <= val and val < end:
		return true
		

func random_tile(data, biome):
	var current_biome = data[biome]
	var rand_num = rand_range(0,1)
	var running_total = 0
	for tile in current_biome:
			running_total = running_total+current_biome[tile]
			if rand_num <= running_total:
				return tile

"""
func set_objects():
	objects = {}
	for pos in biome:
		var current_biome = biome[pos]
		var random_object = random_tile(object_data, current_biome)
		objects[pos] = random_object
		if random_object != null:
			tile_to_scene(random_object, pos)


func tile_to_scene(random_object, pos):
	var instance = object_tiles[str(random_object)].instance()
	instance.position = tilemap.map_to_world(pos) + Vector2(4, 4)
	$YSort.add_child(instance)
"""