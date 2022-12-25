extends Node2D

export var map_width = 200
export var map_height = 200

var start_position_castle = Vector2(map_width / 2 - 2, map_height / 2 - 6)
var start_position_chapel = start_position_castle + 50 * Vector2(rand_range(-1,1), rand_range(-1,1)).normalized()

onready var tilemap = $TileMap_Ground
onready var christine = $Christine
onready var komtur = $Komtur
onready var spinne = $Spinne
onready var castle = $Castle
onready var der_gruene = $DerGruene
onready var debug = $DebugCanvas
onready var gui = $GUI
onready var chapel = $Chapel
onready var world_gen = $WorldGen


func _ready():
	gui.connect("new_game",christine,"_on_Gui_new_game")
	christine.connect("beech_inventory_exceeded", gui, "_on_Christine_beech_inventory_exceeded")
	christine.connect("beech_chopped",gui,"_on_Christine_beech_chopped")
	christine.connect("deal_accepted",der_gruene,"_on_Christine_deal_accepted")
	christine.connect("deal_accepted",spinne,"_on_Christine_deal_accepted")
	christine.connect("deal_accepted",self,"_on_Christine_deal_accepted")
	christine.connect("deal_denied",der_gruene,"_on_Christine_deal_denied")
	christine.connect("deal_accepted",gui,"_on_Christine_deal_accepted")
	der_gruene.connect("conversation_started",gui,"_on_DerGruene_conversation_started")
	der_gruene.connect("conversation_started",christine,"_on_DerGruene_conversation_started")
	spinne.connect("attacked", christine, "_on_Spinne_attacked")
	start_new_game()
	debug.add_stat("Christine", christine, "_get_debug", true)
	debug.add_stat("Komtur", komtur, "_get_debug", true)
	debug.add_stat("Spinne", spinne, "_get_debug", true)
	debug.add_stat("DerGruene", der_gruene, "_get_debug", true)
	debug.add_stat("Chapel", chapel, "_get_debug", true)


func start_new_game():
	world_gen.generate_new_game()
	christine.position = tilemap.map_to_world(christine.start_position)
	komtur.position = tilemap.map_to_world(komtur.start_position)
	castle.position = tilemap.map_to_world(start_position_castle)
	der_gruene.position = tilemap.map_to_world(der_gruene.start_position)
	chapel.position = tilemap.map_to_world(start_position_chapel)


func _input(event):
	if event.is_action_pressed("new_world"):
		get_tree().reload_current_scene()


func _on_gui_new_game():
	get_tree().reload_current_scene()

