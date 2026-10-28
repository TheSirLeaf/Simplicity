extends RefCounted
class_name ChunkData

var key: String = ""
var face: int = 0
var chunk_x: int = 0
var chunk_y: int = 0
var tiles: Array[int] = []
var heightmap: Array[float] = []
var mega_structures: Array[Dictionary] = []
var entities: Array[Dictionary] = []
var dirty: bool = false
var last_accessed: float = 0

func _init(_key: String = "", _face: int = 0, _cx: int = 0, _cy: int = 0) -> void:
	key = _key
	face = _face
	chunk_x = _cx
	chunk_y = _cy
	tiles.resize(PlanetMath.CHUNK_SIZE * PlanetMath.CHUNK_SIZE)
	tiles.fill(0)

func get_tile(tx: int, ty: int) -> int:
	if tx < 0 or tx >= PlanetMath.CHUNK_SIZE or ty < 0 or ty >= PlanetMath.CHUNK_SIZE:
		return 0
	return tiles[ty * PlanetMath.CHUNK_SIZE + tx]

func set_tile(tx: int, ty: int, tile_id: int) -> void:
	if tx < 0 or tx >= PlanetMath.CHUNK_SIZE or ty < 0 or ty >= PlanetMath.CHUNK_SIZE:
		return
	var idx = ty * PlanetMath.CHUNK_SIZE + tx
	if tiles[idx] != tile_id:
		tiles[idx] = tile_id
		dirty = true

func get_height(tx: int, ty: int) -> float:
	if tx < 0 or tx >= PlanetMath.CHUNK_SIZE or ty < 0 or ty >= PlanetMath.CHUNK_SIZE:
		return 0.0
	return heightmap[ty * PlanetMath.CHUNK_SIZE + tx]

func set_height(tx: int, ty: int, h: float) -> void:
	if tx < 0 or tx >= PlanetMath.CHUNK_SIZE or ty < 0 or ty >= PlanetMath.CHUNK_SIZE:
		return
	var idx = ty * PlanetMath.CHUNK_SIZE + tx
	if heightmap[idx] != h:
		heightmap[idx] = h
		dirty = true

func add_mega_structure_segment(segment: Dictionary) -> void:
	mega_structures.append(segment)

func add_entity(entity: Dictionary) -> void:
	entities.append(entity)

func clear_entities() -> void:
	entities.clear()

func to_dict() -> Dictionary:
	return {
		"key": key,
		"face": face,
		"chunk_x": chunk_x,
		"chunk_y": chunk_y,
		"tiles": tiles,
		"heightmap": heightmap,
		"entities": entities
	}

static func from_dict(data: Dictionary) -> ChunkData:
	var chunk = ChunkData.new(data["key"], data["face"], data["chunk_x"], data["chunk_y"])
	chunk.tiles = data["tiles"]
	chunk.heightmap = data["heightmap"]
	chunk.entities = data["entities"]
	return chunk