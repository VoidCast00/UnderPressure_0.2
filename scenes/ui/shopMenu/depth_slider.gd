extends Control

@export var v_slider: VSlider
@export var label: Label
@export var animated_button: AnimatedButton
@export var game_manager: Node


func _ready() -> void:
	animated_button.pressed.connect(confirm)

func _process(delta: float) -> void:
	label.text = "Depth: " + str(v_slider.value) + "m"

#save the depth, then dive
func confirm():
	Global.depthLevel = v_slider.value
	hide()
	Global.loading_text.get_children()[1].text = "Loading..."
	Global.loading_text.show()
	#signal (not game_manager directly) so Upgrades also knows a new dive started
	Global.loadWaterEnviroment.emit()
