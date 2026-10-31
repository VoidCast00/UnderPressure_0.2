extends Node

@export var rainy_particles: CPUParticles2D
@onready var music: AudioStreamPlayer = $Music

@onready var shop_ambience: AudioStreamPlayer = $ShopAmbience
@onready var surface_background_export: Sprite2D = $"../Backround/SurfaceBackgroundExport"

var randomWeather;


const backgroundTextureSunny := preload("res://assets/surface/Surface_Background_export.png")
const backgroundTextureRainy := preload("res://assets/background/Surface_Background_Rain.png")

const musicSunny := preload("res://assets/audio/music/beachTrackSunny.mp3")
const musicRainy := preload("res://assets/audio/music/soundtrack smutne pocasie.mp3")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomWeather = randi_range(1,2)
	if(randomWeather == 1):
		surface_background_export.texture = backgroundTextureSunny
		music.stream = musicSunny
		music.play()
		shop_ambience.play()
	if(randomWeather == 2):
		surface_background_export.texture = backgroundTextureRainy
		music.stream = musicRainy
		music.play()
		shop_ambience.play()
		rainy_particles.emitting = true




		
