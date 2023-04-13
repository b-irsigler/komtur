extends Node

#global nodes
#CAUTION: have to be assigned in the nodes ready function
var camera: Node
var christine: Node
var castle: Node
var gui: Node
var lifebar: Node
var blur : CanvasBlur

#global dicts
var COLOR = {
	"Yellow" : Color(1,.84,0,1)
}

#global variables
onready var game_score:int = 0
onready var no_of_deals:int = 0
onready var deal_offered: bool = false
var game_time_left
onready var first_100_beeches = 0
onready var beech_count = 0
onready var beech_inventory = 0
