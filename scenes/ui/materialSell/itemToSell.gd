class_name ItemObjUI
extends PanelContainer

var itemName:String;
var itemCount:float
var sellAmount:float;
var parent:Control
@onready var sellButton: AnimatedButton = $HBox/Sell

func _ready() -> void:
	sellButton.pressed.connect(sell)
	$HBox/ItemName.text = str(itemName)
	$HBox/Count.text = "%.2f" % itemCount + "g  X " + "%.0f" % sellAmount

func sell() -> void:
	Inventory.cash += roundi(itemCount * sellAmount)
	Inventory.remove(itemName,itemCount)
	self.parent.spawnMoneyParticle(itemCount * sellAmount)

	self.queue_free()
	return
