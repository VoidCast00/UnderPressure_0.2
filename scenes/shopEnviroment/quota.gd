extends Node2D

var playerInside := false
@export var press_e: Label
@onready var quota_ui: Control;

func _ready() -> void:
	quota_ui = Global.quota_ui
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		playerInside = true
		press_e.show()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		playerInside = false
		press_e.hide()
		quota_ui.visible = false
		
		
func _process(delta: float) -> void:
	if quota_ui.visible == true  and Input.is_action_just_pressed("action"):
		quota_ui.visible = false
	else:
		if Input.is_action_just_pressed("action") and playerInside:
			quota_ui.visible = true
	
