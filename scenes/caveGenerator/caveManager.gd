class_name CaveManager
extends Node

#generates the cave and its ores, and draws them
#mining is in MiningBlocksManager

#=== settings ==================================================================

@export var round_top_y := -100      # fully round above this
@export var rigid_bottom_y := 60     # fully rigid below this


const HALF_SIZE := 100  #map is 200x200
const NONE := Vector2i(-1, -1)  #"no tile"

#atlas source id of each ore png in the ore tileset (check in the TileSet editor)
const ORE_SOURCES := {
	"iron": 0,
	"gold": 1,
	"amethyst": 2,
	"ruby": 3,
	"osmium":4,
}

#crystals grow out of walls (2x2 png, one tile per direction)
#every other ore png has the same layout as the rock png, so ore tile = rock tile
const CRYSTALS := ["amethyst", "ruby"]

#ore spawning: every ore has its own noise, it spawns where the noise is above "amount"
#  amount: higher = rarer
#  frequency: higher = smaller, more scattered patches
#checked top to bottom and the first match wins, so rare ores go first
const ORE_SPAWNS := [
	{"ore": "osmium", "amount": 0.6, "frequency": 0.12},
	{"ore": "ruby", "amount": 0.86, "frequency": 0.027},
	{"ore": "amethyst", "amount": 0.83, "frequency": 0.027},
	{"ore": "gold", "amount": 0.65, "frequency": 0.105},
	{"ore": "iron", "amount": 0.40, "frequency": 0.08},
]

#non-crystal ores only spawn this deep in the rock (caveNoise value, rock starts at 0)
const ORE_MIN_DEPTH := 0.1

#rock tiles (in CaveTilemap.png)
const FULL_ROCK := Vector2i(1, 1)
const CRYSTAL_BLOCKED := [  #crystals cant grow on these
	Vector2i(0, 4), Vector2i(1, 4), Vector2i(1, 1),
	Vector2i(0, 5), Vector2i(1, 5),
]

#crystal tile (in the crystal png) by direction away from the wall
const CRYSTAL_TILES := {
	Vector2i(0, -1): Vector2i(1, 0),
	Vector2i(0, 1): Vector2i(0, 1),
	Vector2i(-1, 0): Vector2i(0, 0),
	Vector2i(1, 0): Vector2i(1, 1),
}

#=== nodes =====================================================================

@export var caveNoise: NoiseTexture2D
@export var caveTilemap: TileMapLayer
@export var oreTilemap: TileMapLayer
@export var transport: StaticBody2D

#=== state =====================================================================

#which cell has which ore (cell -> "gold", "amethyst"...). no entry = plain rock
var ores := {}

#ore -> its spawn noise (made in _make_ore_noises)
var ore_noises := {}


func _ready() -> void:
	generateCaveSystem()


#=== generation ================================================================

func generateCaveSystem() -> void:
	#random seed so every run generates a different cave
	randomize()
	caveNoise.noise.seed = randi()
	_make_ore_noises()

	#rock
	var rock: Array[Vector2i] = []
	for x in range(-HALF_SIZE, HALF_SIZE):
		for y in range(-HALF_SIZE, HALF_SIZE):
			if caveNoise.noise.get_noise_2d(x, y) > 0:
				rock.append(Vector2i(x, y))
	caveTilemap.set_cells_terrain_connect(rock, 0, 0)

	#crater first so ores match the final shape
	explode(transport.global_position, 10)

	#ores
	for cell in rock:
		if caveTilemap.get_cell_source_id(cell) == -1:
			continue
		var ore := _pick_ore(cell)
		if ore != "":
			ores[cell] = ore
			_update_ore(cell)

	#debug: how many of each ore spawned (use this to tune ORE_SPAWNS)
	var counts := {}
	for cell in ores:
		counts[ores[cell]] = counts.get(ores[cell], 0) + 1
	print("ores spawned: ", counts)


#one random noise per ore
func _make_ore_noises() -> void:
	for spawn in ORE_SPAWNS:
		var noise := FastNoiseLite.new()
		noise.seed = randi()
		noise.frequency = spawn.frequency
		if spawn.ore in CRYSTALS:
			#thin lines, so crystals come in small clusters
			noise.noise_type = FastNoiseLite.TYPE_PERLIN
			noise.fractal_type = FastNoiseLite.FRACTAL_RIDGED
			noise.fractal_octaves = 9
		else:
			noise.fractal_octaves = 7
		ore_noises[spawn.ore] = noise


#which ore spawns on this rock cell, or "" for plain rock
func _pick_ore(cell: Vector2i) -> String:
	for spawn in ORE_SPAWNS:
		var ore: String = spawn.ore
		var noise: FastNoiseLite = ore_noises[ore]
		if noise.get_noise_2d(cell.x, cell.y) <= spawn.amount:
			continue

		if ore in CRYSTALS:
			#needs a wall to grow out of
			if _crystal_tile(cell) == NONE:
				continue
		elif caveNoise.noise.get_noise_2d(cell.x, cell.y) < ORE_MIN_DEPTH:
			continue

		return ore

	return ""


#removes rock in a circle (outer ring is ragged)
func explode(global_pos: Vector2, radius: int) -> void:
	var center := caveTilemap.local_to_map(caveTilemap.to_local(global_pos))
	var cells: Array[Vector2i] = []

	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var dist := x * x + y * y
			if dist > radius * radius:
				continue
			#outer ring 50% chance to survive
			if dist > (radius - 1) * (radius - 1) and randf() < 0.5:
				continue
			var cell := center + Vector2i(x, y)
			if caveTilemap.get_cell_source_id(cell) != -1:
				cells.append(cell)

	remove_cells(cells)


#=== drawing ===================================================================

#removes rock, then redraws ores around it (autotiling changes nearby rock shapes)
func remove_cells(cells: Array[Vector2i]) -> void:
	if cells.is_empty():
		return

	caveTilemap.set_cells_terrain_connect(cells, 0, -1, false)

	var nearby := {}
	for cell in cells:
		for x in range(-2, 3):
			for y in range(-2, 3):
				var c := cell + Vector2i(x, y)
				if not ores.has(c):
					continue
							# crystals: only the ones you actually mined
				if ores[c] in CRYSTALS and not c in cells:
					continue
				nearby[c] = true
	for c in nearby:
		_update_ore(c)

#draws the ore on this cell, or removes it if it cant be there anymore
func _update_ore(cell: Vector2i) -> void:
	var ore: String = ores[cell]
	var tile := _ore_tile(cell, ore)
	

	if tile == NONE:
		ores.erase(cell)
		oreTilemap.erase_cell(cell)
	else:
		oreTilemap.set_cell(cell, ORE_SOURCES[ore], tile)


#which tile of the ore png to draw on this cell, or NONE
func _ore_tile(cell: Vector2i, ore: String) -> Vector2i:
	#rock is gone, so the ore is gone
	if caveTilemap.get_cell_source_id(cell) == -1:
		return NONE

	if ore in CRYSTALS:
		return _crystal_tile(cell)

	#same shape as the rock under it
	return caveTilemap.get_cell_atlas_coords(cell)


#crystal tile facing away from a wall, or NONE
func _crystal_tile(cell: Vector2i) -> Vector2i:
	if caveTilemap.get_cell_atlas_coords(cell) in CRYSTAL_BLOCKED:
		return NONE

	for neighbour in caveTilemap.get_surrounding_cells(cell):
		if caveTilemap.get_cell_atlas_coords(neighbour) == FULL_ROCK:
			var dir := cell - neighbour
			if CRYSTAL_TILES.has(dir):
				return CRYSTAL_TILES[dir]

	return NONE
