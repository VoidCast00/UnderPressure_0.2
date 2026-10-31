extends Node2D
var playerInside:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
@export var press_e: Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action") and playerInside:
		Global.loadShopEnviroment.emit()
		Inventory.oxygen = Inventory.oxygenTankSize
		


func _on_enter_body_exited(body: Player) -> void:
	playerInside = false
	press_e.visible = false


func _on_enter_body_entered(body: Player) -> void:
	playerInside = true
	press_e.visible = true
