class_name OxygenGauge
extends Control
# WARNING: AI GENERATED UI
#colors
const BG := Color(0.07, 0.07, 0.08, 0.85)
const TEXT := Color(0.92, 0.91, 0.88)
const MUTED := Color(0.55, 0.55, 0.55)
const OFF := Color(1, 1, 1, 0.08)
const FILL := Color(0.78, 0.86, 0.9)
const RED := Color(0.9, 0.25, 0.2)

#settings
const LOW := 0.25        #blink below 25%
const SEGMENTS := 36
const THICKNESS := 6.0

var oxygen := 0.0
var max_oxygen := 1.0
var alert := 0.0         #0 normal, 1 full red


func _ready() -> void:
	custom_minimum_size = Vector2(120, 120)
	size = custom_minimum_size


func _process(_delta: float) -> void:
	oxygen = Inventory.oxygen
	max_oxygen = Inventory.oxygenTankSize
	alert = _get_alert(oxygen / max_oxygen)
	queue_redraw()


#red warning
func _get_alert(ratio: float) -> float:
	var t := Time.get_ticks_msec() / 1000.0

	#empty fast on off
	if ratio <= 0.0:
		return 1.0 if fmod(t, 0.25) < 0.125 else 0.0

	#low slow pulse
	if ratio < LOW:
		return (sin(t * 6.0) + 1.0) / 2.0

	return 0.0


func _draw() -> void:
	var ratio := oxygen / max_oxygen
	var center := size / 2.0
	var half := minf(size.x, size.y) / 2.0
	var ring := half - 12.0

	#background
	draw_circle(center, half, BG)

	#segments
	var step := TAU / SEGMENTS
	var on_color := FILL.lerp(RED, alert)
	var off_color := OFF.lerp(Color(RED, 0.35), alert) if ratio <= 0.0 else OFF

	for i in SEGMENTS:
		var start := -PI / 2.0 + i * step
		var color := on_color if i < ratio * SEGMENTS else off_color
		draw_arc(center, ring, start, start + step * 0.7, 6, color, THICKNESS, true)

	#text
	var font := get_theme_default_font()
	var left := center.x - half
	var width := half * 2.0

	draw_string(font, Vector2(left, center.y - 14), "O2",
		HORIZONTAL_ALIGNMENT_CENTER, width, 11, MUTED)
	draw_string(font, Vector2(left, center.y + 10), str(ceili(oxygen)),
		HORIZONTAL_ALIGNMENT_CENTER, width, 28, TEXT.lerp(RED, alert))
	draw_string(font, Vector2(left, center.y + 26), "/ %d" % int(max_oxygen),
		HORIZONTAL_ALIGNMENT_CENTER, width, 11, MUTED)
