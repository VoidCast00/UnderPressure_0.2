extends Control

#pay the quota with cash (the paying itself is in Global.pay_quota)

@export var label: Label
@onready var max_button: AnimatedButton = $HBoxContainer/Max
@onready var pay_100: AnimatedButton = $"HBoxContainer/100"
@onready var pay_50: AnimatedButton = $"HBoxContainer/50"


func _ready() -> void:
	max_button.pressed.connect(func(): Global.pay_quota(Inventory.cash))
	pay_100.pressed.connect(_pay_fixed.bind(100))
	pay_50.pressed.connect(_pay_fixed.bind(50))


func _process(_delta: float) -> void:
	if Global.quota_left() <= 0:
		label.text = "Quota was payed (but not for long...)"
	else:
		label.text = "Quota: %d" % Global.quota_left()


#fixed buttons only work if you actually have that much cash
func _pay_fixed(amount: int) -> void:
	if Inventory.cash >= amount:
		Global.pay_quota(amount)
