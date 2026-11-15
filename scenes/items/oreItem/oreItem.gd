class_name OreItem
extends RigidBody2D

const MAGNET_SPEED := 300.0
const MAGNET_ACCEL := 1500.0
@onready var texture: Sprite2D = $Texture

var oreType: String = ""
var magnet: bool = false
var playerRefrence: Player

func _ready() -> void:
	match oreType:
		"iron":
			texture.texture = preload("res://scenes/items/oreItem/IronOreItem.png")
		"gold":
			texture.texture = preload("res://scenes/items/oreItem/GoldOreItem.png")
		"osmium":
			texture.texture = preload("res://scenes/items/oreItem/OsmiumOreItem.png")
		

func _physics_process(delta: float) -> void:
	if magnet and is_instance_valid(playerRefrence):
		var dir := (playerRefrence.global_position - global_position).normalized()
		linear_velocity = linear_velocity.move_toward(dir * MAGNET_SPEED, MAGNET_ACCEL * delta)

func _on_pick_up_range_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.itemPickedUp.emit(oreType)
		queue_free()

func _on_magnet_range_body_entered(body: Node2D) -> void:
	if body is Player:
		magnet = true
		playerRefrence = body
