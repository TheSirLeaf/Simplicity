extends RefCounted
class_name ChunkLoader
signal chunk_loaded(chunk_data: ChunkData)
signal chunk_unloaded(chunk_key: String)

var load_radius_chunks: int = 2
var unload_radius_chunks: int = 5
var planet_radius: float = PlanetMath.DEFAULT_PLANET_RADIUS

var loaded_chunks: Dictionary = {}
var chunk_access_time: Dictionary = {}

var global_mega_structures: GlobalMegaStructures
var world_seed: int = 12345

func _ready() -> void:
	global_mega_structures = GlobalMegaStructures
	PlanetMath._ensure_initialized()
	_create_demo_structures()

func _create_demo_structures() -> void:
	global_mega_structures.create_structure("particle_accelerator", {
		"radius": planet_radius,
		"num_segments": 720,
		"center": Vector3(1, 0, 0),
		"normal": Vector3(0, 1, 0)
	})
	global_mega_structures.create_structure("space_elevator", {
		"radius": planet_radius,
		"num_segments": 360,
		"center": Vector3(0, 0, 1),
		"normal": Vector3(1, 0, 0)
	})

func get_chunk(face: int, cx: int, cy: int) -> ChunkData:
	var key = PlanetMath.chunk_key(face, cx, cy)
	
	if key in loaded_chunks:
		chunk_access_time[key] = Time.get_ticks_msec()
		loaded_chunks[key].last_accessed = Time.get_ticks_msec()
		return loaded_chunks[key]
	
	var chunk = _generate_chunk(face, cx, cy)
	
	loaded_chunks[key] = chunk
	chunk_access_time[key] = Time.get_ticks_msec()
	emit_signal("chunk_loaded", chunk)
	
	return chunk

func _generate_chunk(face: int, cx: int, cy: int) -> ChunkData:
	var chunk = ChunkData.new(PlanetMath.chunk_key(face, cx, cy), face, cx, cy)
	
	var seed = _hash_chunk_seed(world_seed, face, cx, cy)
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	
	chunk.heightmap.resize(PlanetMath.CHUNK_SIZE * PlanetMath.CHUNK_SIZE)
	_fill_heightmap(chunk, rng)
	
	_fill_biomes(chunk, face, cx, cy, rng)
	
	var megas = global_mega_structures.get_structures_in_chunk(face, cx, cy)
	for mega in megas:
		var seg = global_mega_structures.get_segment_for_chunk(mega["id"], face, cx, cy)
		if seg:
			chunk.mega_structures.append(seg)
	
	return chunk

func _hash_chunk_seed(base_seed: int, face: int, cx: int, cy: int) -> int:
	var h = base_seed
	h = (h * 31 + face) & 2147483647
	h = (h * 31 + cx) & 2147483647
	h = (h * 31 + cy) & 2147483647
	return h

func _fill_heightmap(chunk: ChunkData, rng: RandomNumberGenerator) -> void:
	for y in range(PlanetMath.CHUNK_SIZE):
		for x in range(PlanetMath.CHUNK_SIZE):
			var idx = y * PlanetMath.CHUNK_SIZE + x
			chunk.heightmap[idx] = (rng.randf() - 0.5) * 0.5
	_blur_heightmap(chunk)

func _blur_heightmap(chunk: ChunkData) -> void:
	var smoothed = chunk.heightmap.duplicate()
	var size = PlanetMath.CHUNK_SIZE
	
	for y in range(1, size - 1):
		for x in range(1, size - 1):
			var idx = y * size + x
			var sum = chunk.heightmap[idx] * 4.0
			sum += chunk.heightmap[(y - 1) * size + x]
			sum += chunk.heightmap[(y + 1) * size + x]
			sum += chunk.heightmap[y * size + (x - 1)]
			sum += chunk.heightmap[y * size + (x + 1)]
			smoothed[idx] = sum / 8.0
	
	chunk.heightmap = smoothed

func _fill_biomes(chunk: ChunkData, face: int, cx: int, cy: int, rng: RandomNumberGenerator) -> void:
	var biome_base = 0
	match face:
		3: biome_base = 3
		1: biome_base = 4
		0, 2, 4, 5: biome_base = 1
	
	for y in range(PlanetMath.CHUNK_SIZE):
		for x in range(PlanetMath.CHUNK_SIZE):
			var idx = y * PlanetMath.CHUNK_SIZE + x
			var variation = rng.randi_range(0, 3)
			chunk.tiles[idx] = biome_base * 10 + variation

func update_streaming(player_pos_3d: Vector3) -> void:
	var fuv = PlanetMath.sphere_to_face_uv(player_pos_3d.normalized())
	var center = PlanetMath.uv_to_chunk(fuv["u"], fuv["v"])
	var cface = fuv["face"]
	var ccx = center["chunk_x"]
	var ccy = center["chunk_y"]
	
	for dx in range(-load_radius_chunks, load_radius_chunks + 1):
		for dy in range(-load_radius_chunks, load_radius_chunks + 1):
			var nx = ccx + dx
			var ny = ccy + dy
			if nx >= 0 and nx < PlanetMath.face_chunks_x and ny >= 0 and ny < PlanetMath.face_chunks_y:
				get_chunk(cface, nx, ny)
	
	var now = Time.get_ticks_msec()
	var to_unload = []
	for key in loaded_chunks:
		var chunk = loaded_chunks[key]
		var parsed = PlanetMath.parse_chunk_key(key)
		if parsed:
			var dist = max(abs(parsed["chunk_x"] - ccx), abs(parsed["chunk_y"] - ccy))
			if dist > unload_radius_chunks and parsed["face"] == cface:
				var last_access = chunk_access_time.get(key, 0)
				if now - last_access > 30000:
					to_unload.append(key)
	
	for key in to_unload:
		var chunk = loaded_chunks[key]
		if chunk.dirty:
			_save_chunk(chunk)
		loaded_chunks.erase(key)
		chunk_access_time.erase(key)
		emit_signal("chunk_unloaded", key)

func _save_chunk(chunk: ChunkData) -> void:
	pass

func load_chunk_from_save(key: String) -> ChunkData:
	return null

func get_loaded_chunk_keys() -> Array[String]:
	return loaded_chunks.keys()

func get_chunk_count() -> int:
	return loaded_chunks.size()