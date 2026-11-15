class_name LoadingScreen
extends Control

#full screen text between environments ("DAY 1. BEGINS", "Loading...", quota under it)

@onready var title: Label = $Title
@onready var subtitle: Label = $Subtitle


func show_message(title_text: String, subtitle_text := "") -> void:
	title.text = title_text
	subtitle.text = subtitle_text
	show()
