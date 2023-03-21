extends Node2D


export var map_width = 200
export var map_height = 200

#var start_position_castle = Vector2(map_width / 2 - 2, map_height / 2 - 6)
#var start_position_chapel = start_position_castle + 50 * Vector2(rand_range(-1,1), rand_range(-1,1)).normalized()

onready var christine = $WorldGen/Christine
onready var komtur = $WorldGen/Komtur
onready var spinne = $WorldGen/Spinne
onready var castle = $WorldGen/Castle
onready var der_gruene = $WorldGen/DerGruene
onready var gui = $GUI
onready var debug = $GUI/DebugOverlay
onready var chapel = $WorldGen/Chapel
onready var world_gen = $WorldGen
onready var tilemap = $WorldGen/TileMap_Ground


func _ready():
	gui.connect("new_game", self, "_on_Gui_new_game")
	christine.connect("beech_inventory_exceeded", gui, "_on_Christine_beech_inventory_exceeded")
	christine.connect("beech_chopped", gui, "_on_Christine_beech_chopped")
	christine.connect("deal_accepted", der_gruene, "_on_Christine_deal_accepted")
	christine.connect("deal_accepted", spinne, "_on_Christine_deal_accepted")
	christine.connect("deal_denied", der_gruene, "_on_Christine_deal_denied")
	christine.connect("deal_accepted", gui, "_on_Christine_deal_accepted")
	der_gruene.connect("conversation_started", gui, "_on_DerGruene_conversation_started")
	der_gruene.connect("conversation_started", christine, "_on_DerGruene_conversation_started")
	spinne.connect("has_attacked", christine, "_on_Spinne_has_attacked")
	debug.add_stat("Christine", christine, "_get_debug", true)
	debug.add_stat("Komtur", komtur, "_get_debug", true)
	debug.add_stat("Spinne", spinne, "_get_debug", true)
	debug.add_stat("DerGruene", der_gruene, "_get_debug", true)
	debug.add_stat("Chapel", chapel, "_get_debug", true)


func start_new_game():
	get_tree().reload_current_scene()


func _on_Gui_new_game():
	start_new_game()
