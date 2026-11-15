extends Node

#runs the game loop: main menu -> shop -> pick depth -> dive -> shop ...
#swaps environments inside the SubViewport and shows / hides the UI for each step

#environments
@export var sub_viewport: SubViewport
@export var WaterEnviroment: PackedScene
@export var ShopEnviroment: PackedScene

#ui (all inside UI in game.tscn)
@export var main_menu: Control
@export var pause: Control
@export var oxygen_gauge: OxygenGauge
@export var depth: Control
@export var loading: LoadingScreen
@export var lost_quota: Control
@export var death: Control
@export var shop_ui: Control
@export var quota_ui: Control

#current environment
var current_env: Node = null
var is_loading := false


func _ready() -> void:
	#environments look these up through Global
	Global.shop_ui = shop_ui
	Global.quota_ui = quota_ui
	Global.loading_text = loading

	Inventory.oxygenDepleted.connect(killPlayer)
	pause.resume.connect(switchPause)
	Global.loadDepthUI.connect(loadDepthUi)
	Global.loadWaterEnviroment.connect(loadWaterEnviroment)
	Global.loadShopEnviroment.connect(loadShopEnviroment)
	Global.exitGame.connect(exitGame)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("esc"):
		return
	if main_menu.visible:
		return
	switchPause()


#=== game flow =================================================================

func loadDepthUi() -> void:
	main_menu.hide()
	depth.show()


func loadWaterEnviroment() -> void:
	main_menu.hide()
	depth.hide()
	oxygen_gauge.show()
	loading.show_message("Loading...", "Quota: %d" % Global.quota)

	var days_left := Global.deadline - Global.day
	if Global.is_quota_met():
		Global.start_next_quota()
		loading.show_message("Loading...", "Quota: %d" % Global.quota)
		load_env(WaterEnviroment)
	elif days_left == 0:
		loseQuota()
	else:
		Global.day += 1
		load_env(WaterEnviroment)


func loadShopEnviroment() -> void:
	var days_left := Global.deadline - Global.day
	var text := "1. day remeaning" if days_left == 1 else "%d. days remaning" % days_left
	loading.show_message(text, "Quota: %d" % Global.quota)
	main_menu.hide()
	oxygen_gauge.hide()
	await get_tree().create_timer(2.0).timeout
	load_env(ShopEnviroment)


#=== endings ===================================================================

func killPlayer() -> void:
	unload()
	death.show()


func loseQuota() -> void:
	lost_quota.show()
	var sound: AudioStreamPlayer = main_menu.main_menu_soundtrack
	sound.play()
	sound.pitch_scale = 0.8
	unload()


func exitGame() -> void:
	get_tree().quit()


func switchPause() -> void:
	pause.visible = not pause.visible
	get_tree().paused = pause.visible


#=== environments ==============================================================

func unload() -> void:
	if current_env:
		current_env.queue_free()


func load_env(scene: PackedScene) -> void:
	if not scene:
		push_error("no environment scene")
		return
	if is_loading:
		return
	is_loading = true

	loading.show()

	await get_tree().process_frame

	unload()

	#add new
	current_env = scene.instantiate()
	sub_viewport.add_child.call_deferred(current_env)

	#wait until loaded
	await current_env.ready
	await get_tree().process_frame

	loading.hide()
	is_loading = false
