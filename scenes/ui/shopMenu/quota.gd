extends Control

@export var label: Label
@onready var max: AnimatedButton = $HBoxContainer/Max
@onready var _100: AnimatedButton = $"HBoxContainer/100"
@onready var _50: AnimatedButton = $"HBoxContainer/50"

func _ready() -> void:
	max.pressed.connect(maxButtonPressed)
	_100.pressed.connect(_100ButtonPressed)
	_50.pressed.connect(_50ButtonPressed)

func _process(delta: float) -> void:
	if(Global.quota - Global.quotaCompletedAmount <= 0):
		label.text = "Quota was payed (but not for long...)"
	else:
		label.text = "Quota: " + str(Global.quota - Global.quotaCompletedAmount)
		
func maxButtonPressed():
	if(Inventory.cash < Global.quota - Global.quotaCompletedAmount):
		Global.quotaCompletedAmount += Inventory.cash
		Inventory.cash = 0
	else:
		Inventory.cash = Inventory.cash - (Global.quota - Global.quotaCompletedAmount)
		Global.quotaCompletedAmount = Global.quota
		
func _50ButtonPressed():
	if(Inventory.cash >= 50):
		if(50 < Global.quota - Global.quotaCompletedAmount):
			Inventory.cash -= 50
			Global.quotaCompletedAmount += 50
		else:
			Inventory.cash = Inventory.cash - (Global.quota - Global.quotaCompletedAmount)
			Global.quotaCompletedAmount = Global.quota
			
func _100ButtonPressed():
	if(Inventory.cash >= 100):
		if(50 < Global.quota - Global.quotaCompletedAmount):
			Inventory.cash -= 100
			Global.quotaCompletedAmount += 100
		else:
			Inventory.cash = Inventory.cash - (Global.quota - Global.quotaCompletedAmount)
			Global.quotaCompletedAmount = Global.quota
		
		
	
