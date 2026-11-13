class_name MiningBlocksManager
extends Node

#the player calls startMining() / stopMining()
#this counts the mining time, then breaks the block and gives the ore

#seconds to mine each material
const MINING_TIMES := {
	"rock": 0.3,
	"iron": 2.0,
	"gold": 1.5,
	"amethyst": 1.0,
	"ruby": 1.8,
}

@export var cave: CaveManager

#break sounds (empty slot = no sound)
@export var block_break: AudioStreamPlayer
@export var iron_break: AudioStreamPlayer
@export var gold_break: AudioStreamPlayer
@export var amethist_break: AudioStreamPlayer
@export var ruby_break: AudioStreamPlayer

@export var cpu_particles_2d: CPUParticles2D
@export var after_break_par: CPUParticles2D

@onready var break_sounds := {
	"rock": block_break,
	"iron": iron_break,
	"gold": gold_break,
	"amethyst": amethist_break,
	"ruby": ruby_break,
}

var is_mining := false
var mining_cell := Vector2i.ZERO
var mining_type := ""
var mining_timer := 0.0


func _process(delta: float) -> void:
	if not is_mining:
		return

	mining_timer += delta
	if mining_timer < MINING_TIMES.get(mining_type, 1.0) / Upgrades.mining_speed():
		return

	#block is mined
	Global.mined.emit(mining_type)
	var sound: AudioStreamPlayer = break_sounds.get(mining_type)
	if sound:
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


func stopMining() -> void:
	cpu_particles_2d.emitting = false
	breakPar(cpu_particles_2d.global_position)
	is_mining = false
	mining_cell = Vector2i.ZERO
	mining_type = ""
	mining_timer = 0.0


func breakPar(position: Vector2) -> void:
	after_break_par.global_position = position
	after_break_par.emitting = true
