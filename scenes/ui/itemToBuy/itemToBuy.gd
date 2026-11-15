class_name BuyingObjUI
extends PanelContainer

@export var name1: Label
@export var desc: Label

var itemName:String;
var description:String;
var sellAmount:float;
@export var sellButton: AnimatedButton

func _ready() -> void:
	sellButton.pressed.connect(pay)
	name1.text = str(itemName)
	desc.text = str(description)
	sellButton.text = "Buy: cost " + str(sellAmount)
	
func pay():
	if(Inventory.cash - sellAmount >= 0):
		Inventory.cash -= sellAmount
	
