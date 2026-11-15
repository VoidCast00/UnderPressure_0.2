extends CanvasLayer

#everything the player sees while playing: oxygen, cash, inventory (hold the inventory key)

@onready var inventory_ui: PanelContainer = $InventoryUI
@onready var oxygen_gauge: OxygenGauge = $OxygenGauge
@onready var cash: Label = $Cash


func _process(_delta: float) -> void:
	cash.text = "cash: %d" % Inventory.cash

	#holding the key swaps the cash label for the full inventory
	var open := Input.is_action_pressed("inventory")
	inventory_ui.visible = open
	cash.visible = not open
