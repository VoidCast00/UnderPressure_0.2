extends Control

@export var v_slider: VSlider
@export var label: Label
@export var animated_button: AnimatedButton


func _process(delta: float) -> void:
	label.text = "Depth: " + str(v_slider.value) + "m"
