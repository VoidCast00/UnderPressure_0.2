extends Node

signal loadWaterEnviroment;
signal loadShopEnviroment;
signal exitGame;

signal mined(type:String)

#money you get for selling one of each material
const SELL_PRICES := {
	"rock": 1,
	"iron": 4,
	"amethyst": 6,
	"gold": 10,
	"ruby": 16,
	"osmium":30
}


var quota:int = 190;
var day:int =  0; #for the start to start counting
var deadline:int = 3;  
var quotaCompletedAmount:int = 0;
var depthLevel := 0

var tutorialDone := false

@onready var oxygen_gauge: Control 
@onready var shop_ui: Control 
@onready var loading_text: Control 
@onready var quota_ui: Control
