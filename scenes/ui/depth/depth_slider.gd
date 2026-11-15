extends Control

#pick how deep to dive, then confirm (shown by the game manager from the shop)

@export var v_slider: VSlider
@export var label: Label
@export var animated_button: AnimatedButton


func _ready() -> void:
	animated_button.pressed.connect(confirm)
	v_slider.value_changed.connect(_update_label)
	_update_label(v_slider.value)


func _update_label(value: float) -> void:
	label.text = "Depth: %dm" % value


#save the depth, then dive (game manager handles hiding this + the loading screen)
func confirm() -> void:
	Global.depthLevel = v_slider.value
	#signal (not game_manager directly) so anything else can know a new dive started
	Global.loadWaterEnviroment.emit()
