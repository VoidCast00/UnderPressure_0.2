class_name BuyingObjUI
extends Control

var itemName:String;
var description:String;
var sellAmount:float;
@export var sellButton: AnimatedButton

func _ready() -> void:
	sellButton.pressed.connect(pay)
	$Panel/Name.text = str(itemName)
	$Panel/Desc.text = str(description)
	
func pay():
	if(Inventory.cash - sellAmount >= 0):
		Inventory.cash -= sellAmount
	
