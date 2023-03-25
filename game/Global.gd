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
onready var game_score = 0
onready var no_of_deals = 0
var game_time_left
onready var first_100_beeches = 0
