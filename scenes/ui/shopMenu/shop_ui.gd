extends Control

@onready var buy: PanelContainer = $Pages/Buy
@onready var sell: PanelContainer = $Pages/Sell
@onready var items: Panel = $Pages/Items
@export var item_list: VBoxContainer
@export var sell_value: Label 
@export var Sell_All: AnimatedButton 
@export var MoneyParticle:RigidBody2D
const basePosMoneyParticlePos:Vector2 = Vector2(920, 510)
@onready var cashParticleText: Label = $MoneyParticle/Cash
@export var timer: Timer
var money_tween: Tween
@export var buttons: HBoxContainer
@export var back0: AnimatedButton
@export var back1: AnimatedButton
@export var UPGRADE_OBJECT:PackedScene
@export var sellMaterialScene:PackedScene
@export var BuyItem:PackedScene
@export var upgradesList: VBoxContainer
@export var trait_upgrades: VBoxContainer
@export var itemsList: VBoxContainer

func _ready() -> void:
	back0.pressed.connect(go_back)
	back1.pressed.connect(go_back)
	var temp_trait_upgrades_list:Array;
	for id in Upgrades.ALL:
		var upgradeItem:UpgradeObjUI= UPGRADE_OBJECT.instantiate()
		upgradeItem.id = id
		if Upgrades.ALL[id]["max_level"] == 1:
			if Upgrades.get_level(id) == 0:
				temp_trait_upgrades_list.append(upgradeItem)
		else: 
			upgradesList.add_child(upgradeItem)
	temp_trait_upgrades_list.shuffle()
	for i in range(3):
		trait_upgrades.add_child(temp_trait_upgrades_list[i])
	
	
	for id in Upgrades.Items:
		var Item:BuyingObjUI = BuyItem.instantiate()
		Item.itemName = str(id["name"])
		Item.description = str(id["desc"])
		Item.cost = str(id["cost"])
		itemsList.add_child(Item)
		
func _on_buy_pressed() -> void:
	sell.hide()
	items.hide()
	buy.show()
	buttons.hide()


func updateSellItemList() -> void:
	for item in Inventory.items:
		var itemObj:ItemObjUI= sellMaterialScene.instantiate()
		itemObj.itemCount = Inventory.items[item]
		itemObj.itemName = str(item)
		itemObj.sellAmount = Global.SELL_PRICES.get(item, 0)
		itemObj.parent = self
		item_list.add_child(itemObj)



func _on_sell_pressed() -> void:
	sell.show()
	items.hide()
	buy.hide()
	buttons.hide()
	updateSellItemList()
	
func _on_items_pressed() -> void:
	items.show()
	sell.hide()
	buy.hide()
	buttons.hide()


func go_back() -> void:
	sell.hide()
	buy.hide()
	buttons.show()
	

func spawnMoneyParticle(sell_value: int) -> void:
	#reset
	if money_tween:
		money_tween.kill()
	MoneyParticle.show()
	MoneyParticle.position = basePosMoneyParticlePos
	MoneyParticle.scale = Vector2.ZERO
	MoneyParticle.rotation = deg_to_rad(randf_range(-10, 10))
	MoneyParticle.modulate.a = 1.0

	money_tween = create_tween()

	#pop in with overshoot
	money_tween.tween_property(MoneyParticle, "scale", Vector2.ONE, 0.35) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	#count up the number
	money_tween.parallel().tween_method(_set_cash_text, 0.0, float(sell_value), 0.7) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	#float up fast then slow
	money_tween.parallel().tween_property(MoneyParticle, "position:y", basePosMoneyParticlePos.y - 120, 1.2) \
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

	#wobble back straight
	money_tween.parallel().tween_property(MoneyParticle, "rotation", 0.0, 0.9) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	#fade out and shrink
	money_tween.tween_property(MoneyParticle, "modulate:a", 0.0, 0.4).set_delay(0.3)
	money_tween.parallel().tween_property(MoneyParticle, "scale", Vector2(0.8, 0.8), 0.4)

	#done
	money_tween.tween_callback(MoneyParticle.hide)


func _set_cash_text(value: float) -> void:
	cashParticleText.text = str(value) + "$"
