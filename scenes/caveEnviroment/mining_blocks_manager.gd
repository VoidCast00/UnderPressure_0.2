class_name MiningBlocksManager
extends Node


#the player calls startMining() / stopMining()
#this counts the mining time, then breaks the block and gives the ore

#seconds to mine each material
const MINING_TIMES := {
	"rock": 0.3,
	"iron": 0.8,
	"gold": 1.2,
	"amethyst": 1.0,
	"ruby": 1.6,
	"osmium": 2.5,
}

#crack overlay while mining (one png per stage, 32x32, redraw them if you want)
const CRACK_STAGES := [
	"res://scenes/caveGenerator/crack/crack_0.png",
	"res://scenes/caveGenerator/crack/crack_1.png",
	"res://scenes/caveGenerator/crack/crack_2.png",
	"res://scenes/caveGenerator/crack/crack_3.png",
	"res://scenes/caveGenerator/crack/crack_4.png",
]
const CRACK_SHADER := "res://scenes/caveEnviroment/crack_mask.gdshader"

@export var cave: CaveManager

#break sounds (empty slot = no sound)


@export var block_break: AudioStreamPlayer
@export var iron_break: AudioStreamPlayer
@export var gold_break: AudioStreamPlayer
@export var amethist_break: AudioStreamPlayer
@export var ruby_break: AudioStreamPlayer
@export var osmium_break: AudioStreamPlayer

@export var cpu_particles_2d: CPUParticles2D
@export var after_break_par: CPUParticles2D

@onready var break_sounds := {
	"rock": block_break,
	"iron": iron_break,
	"gold": gold_break,
	"amethyst": amethist_break,
	"ruby": ruby_break,
	"osmium":osmium_break,
}

var is_mining := false
var mining_cell := Vector2i.ZERO
var mining_type := ""
var mining_timer := 0.0

#crack sprite on top of the block being mined (made in _ready)
var crack: Sprite2D
var crack_textures: Array[Texture2D] = []


func _ready() -> void:
	for path in CRACK_STAGES:
		crack_textures.append(load(path))

	var mat := ShaderMaterial.new()
	mat.shader = load(CRACK_SHADER)

	crack = Sprite2D.new()
	crack.material = mat
	crack.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	crack.z_index = 2  #above the ore tilemap (z 1)
	crack.hide()
	#child of the cave tilemap so it moves/scales with it
	cave.caveTilemap.add_child.call_deferred(crack)


func _process(delta: float) -> void:
	if not is_mining:
		return

	mining_timer += delta
	var duration: float = MINING_TIMES.get(mining_type, 1.0) / Upgrades.mining_speed()

	#crack stage from mining progress
	var stage := mini(int(mining_timer / duration * crack_textures.size()), crack_textures.size() - 1)
	crack.texture = crack_textures[stage]

	if mining_timer < duration:
		return

	#block is mined
	Global.mined.emit(mining_type)
	
	var sound: AudioStreamPlayer = break_sounds.get(mining_type)
	if sound:
		sound.pitch_scale = randf_range(0.8,1.2)
		sound.play()

	cave.remove_cells([mining_cell])
	stopMining()


#start (or keep) mining the block at this global position
func startMining(global_pos: Vector2) -> void:
	var cell := cave.caveTilemap.local_to_map(cave.caveTilemap.to_local(global_pos))

	#already mining this cell
	if is_mining and cell == mining_cell:
		return

	#nothing there
	if cave.caveTilemap.get_cell_source_id(cell) == -1:
		stopMining()
		return

	mining_cell = cell
	mining_type = cave.ores.get(cell, "rock")
	mining_timer = 0.0
	is_mining = true
	cpu_particles_2d.global_position = global_pos
	cpu_particles_2d.emitting = true
	_show_crack(cell)


func stopMining() -> void:
	crack.hide()
	cpu_particles_2d.emitting = false
	breakPar(cpu_particles_2d.global_position)
	is_mining = false
	mining_cell = Vector2i.ZERO
	mining_type = ""
	mining_timer = 0.0


func breakPar(position: Vector2) -> void:
	after_break_par.global_position = position
	after_break_par.emitting = true


#=== crack overlay =============================================================

#puts the crack on this cell and tells the shader the tile shape to cut it to
func _show_crack(cell: Vector2i) -> void:
	var mat := crack.material as ShaderMaterial
	_set_crack_mask(mat, "rock", cave.caveTilemap, cell)

	var has_ore := cave.oreTilemap.get_cell_source_id(cell) != -1
	mat.set_shader_parameter("has_ore", has_ore)
	if has_ore:
		_set_crack_mask(mat, "ore", cave.oreTilemap, cell)

	crack.position = cave.caveTilemap.map_to_local(cell)
	crack.texture = crack_textures[0]
	crack.show()


#where this cell's tile is inside its png (works for rock, ores and 2x2 crystals)
func _set_crack_mask(mat: ShaderMaterial, prefix: String, layer: TileMapLayer, cell: Vector2i) -> void:
	var source := layer.tile_set.get_source(layer.get_cell_source_id(cell)) as TileSetAtlasSource
	var tex_size := Vector2(source.texture.get_size())
	var rect := Rect2(source.get_tile_texture_region(layer.get_cell_atlas_coords(cell)))
	mat.set_shader_parameter(prefix + "_tex", source.texture)
	mat.set_shader_parameter(prefix + "_region", Vector4(
		rect.position.x / tex_size.x, rect.position.y / tex_size.y,
		rect.size.x / tex_size.x, rect.size.y / tex_size.y))
