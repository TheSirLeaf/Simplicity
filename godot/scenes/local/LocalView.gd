extends Node2D
class_name LocalView

@onready var chunk_grid: TileMap = %ChunkGrid
@onready var mega_layer: Node2D = %MegaStructureLayer
@onready var portal_markers: Node2D = %PortalMarkers
@onready var player: CharacterBody2D = %Player
@onready var camera2d: Camera2D = %Camera2D
@onready var info_label: Label = %UI/InfoPanel/InfoLabel
@onready var minimap: TextureRect = %UI/Minimap

var chunk_loader: ChunkLoader
var global_mega: GlobalMegaStructures

var current_face: int = 0
var current_cx: int = 0
var current_cy: int = 0
var current_chunk: ChunkData = null

const CHUNK_SIZE = PlanetMath.CHUNK_SIZE
const TILE_SIZE = PlanetMath.TILE_SIZE
const PIXELS_PER_TILE = 16

var BIOME_COLORS: Dictionary = {
	0: Color(0.2, 0.2, 0.2),
	1: Color(0.2, 0.7, 0.2),
	2: Color(0.5, 0.5, 0.3),
	3: Color(0.9, 0.9, 1.0),
	4: Color(0.8, 0.8, 0.9),
	5: Color(0.8, 0.5, 0.2),
	6: Color(0.3, 0.3, 0.7)
}

var move_speed: float = 5.0
var target_tile: Vector2i = Vector2i.ZERO
var moving: bool = false

func _ready() -> void:
	chunk_loader = ChunkLoader
	global_mega = GlobalMegaStructures
	
	PlanetMath._ensure_initialized()
	
	chunk_grid.tile_set = _create_tileset()
	chunk_grid.clear()
	
	player.global_position = Vector2(CHUNK_SIZE / 2, CHUNK_SIZE / 2) * PIXELS_PER_TILE
	target_tile = Vector2i(player.global_position / PIXELS_PER_TILE)
	
	camera2d.limit_left = 0
	camera2d.limit_top = 0
	camera2d.limit_right = CHUNK_SIZE * PIXELS_PER_TILE
	camera2d.limit_bottom = CHUNK_SIZE * PIXELS_PER_TILE
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _create_tileset() -> TileSet:
	var tileset = TileSet.new()
	
	var atlas_source = TileSetAtlasSource.new()
	var atlas_texture = load("res://resources/textures/tile_atlas.png")
	atlas_source.texture = atlas_texture
	atlas_source.tile_size = Vector2i(16, 16)
	atlas_source.margins = Vector2i(0, 0)
	atlas_source.separation = Vector2i(0, 0)
	atlas_source.texture_region_size = Vector2i(16, 16)
	
	tileset.add_source(atlas_source, 0)
	
	for biome in range(7):
		for variation in range(4):
			var atlas_coords = Vector2i(variation, biome)
			var chunk_tile_id = biome * 10 + variation
			
			tileset.create_tile(chunk_tile_id, 0, atlas_coords, Vector2i(1, 1))
	
	return tileset

func initialize(face: int, cx: int, cy: int, local_uv: Vector2) -> void:
	current_face = face
	current_cx = cx
	current_cy = cy
	
	current_chunk = chunk_loader.get_chunk(face, cx, cy)
	
	_render_chunk()
	_render_mega_structures()
	
	if local_uv != Vector2.ZERO:
		var tile_pos = Vector2i(int(local_uv.x * CHUNK_SIZE), int(local_uv.y * CHUNK_SIZE))
		tile_pos.x = clamp(tile_pos.x, 0, CHUNK_SIZE - 1)
		tile_pos.y = clamp(tile_pos.y, 0, CHUNK_SIZE - 1)
		player.global_position = (tile_pos + Vector2(0.5, 0.5)) * PIXELS_PER_TILE
		target_tile = tile_pos
	
	_update_minimap()

func _render_chunk() -> void:
	if not current_chunk:
		return
	
	chunk_grid.clear()
	
	for y in range(CHUNK_SIZE):
		for x in range(CHUNK_SIZE):
			var tile_id = current_chunk.get_tile(x, y)
			if tile_id > 0:
				chunk_grid.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0), tile_id)

func _render_mega_structures() -> void:
	for child in mega_layer.get_children():
		child.queue_free()
	for child in portal_markers.get_children():
		child.queue_free()
	
	if not current_chunk:
		return
	
	for mega_seg in current_chunk.mega_structures:
		var polyline = mega_seg["polyline"]
		var portals = mega_seg["portals"]
		var type_info = mega_seg["type_info"]
		var global_id = mega_seg["global_id"]
		
		if not polyline or polyline.size() < 2:
			continue
		
		var polygon = Polygon2D.new()
		polygon.polygon = _build_polygon_from_polyline(polyline, type_info["width_tiles"])
		polygon.color = type_info["color"]
		polygon.z_index = 10
		mega_layer.add_child(polygon)
		
		for portal in portals:
			var marker = Sprite2D.new()
			marker.position = portal["local_uv"] * Vector2(CHUNK_SIZE, CHUNK_SIZE) * PIXELS_PER_TILE
			marker.scale = Vector2(2.0, 2.0)
			marker.modulate = Color(1, 1, 0, 0.8)
			marker.z_index = 15
			portal_markers.add_child(marker)
			
			var label = Label.new()
			label.text = "⬢"
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.position = Vector2(0, -20)
			label.z_index = 16
			marker.add_child(label)

func _build_polygon_from_polyline(polyline: Array[Vector2], width_tiles: float) -> Array[Vector2]:
	var result = []
	var width_px = width_tiles * PIXELS_PER_TILE
	
	if polyline.size() < 2:
		return result
	
	var points_px = []
	for p in polyline:
		points_px.append(p * Vector2(CHUNK_SIZE, CHUNK_SIZE) * PIXELS_PER_TILE)
	
	for i in range(points_px.size() - 1):
		var a = points_px[i]
		var b = points_px[i + 1]
		var dir = (b - a).normalized()
		var perp = Vector2(-dir.y, dir.x) * (width_px * 0.5)
		
		result.append(a + perp)
		result.append(b + perp)
	
	for i in range(points_px.size() - 1, 0, -1):
		var a = points_px[i]
		var b = points_px[i - 1]
		var dir = (b - a).normalized()
		var perp = Vector2(-dir.y, dir.x) * (width_px * 0.5)
		
		result.append(a - perp)
		result.append(b - perp)
	
	return result

func _update_minimap() -> void:
	var img = Image.create(CHUNK_SIZE, CHUNK_SIZE, false, Image.Format.RGBA8)
	
	if current_chunk:
		for y in range(CHUNK_SIZE):
			for x in range(CHUNK_SIZE):
				var tile_id = current_chunk.get_tile(x, y)
				var biome = tile_id / 10
				var color = BIOME_COLORS.get(biome, Color(0.5, 0.5, 0.5))
				img.set_pixel(x, y, color)
	
	if current_chunk:
		for mega_seg in current_chunk.mega_structures:
			var polyline = mega_seg["polyline"]
			if polyline:
				for p in polyline:
					var px = int(p.x * CHUNK_SIZE)
					var py = int(p.y * CHUNK_SIZE)
					if px >= 0 and px < CHUNK_SIZE and py >= 0 and py < CHUNK_SIZE:
						img.set_pixel(px, py, Color(1, 1, 0, 1))
	
	var texture = ImageTexture.create_from_image(img)
	minimap.texture = texture

func _process(delta: float) -> void:
	_handle_movement(delta)
	_update_info()
	_handle_chunk_transition()

func _handle_movement(delta: float) -> void:
	var direction = Vector2.ZERO
	if Input.is_action_pressed("local_move_up"):
		direction.y -= 1
	if Input.is_action_pressed("local_move_down"):
		direction.y += 1
	if Input.is_action_pressed("local_move_left"):
		direction.x -= 1
	if Input.is_action_pressed("local_move_right"):
		direction.x += 1
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		var velocity = direction * move_speed * TILE_SIZE * PIXELS_PER_TILE * delta
		player.global_position += velocity
		
		player.global_position.x = clamp(player.global_position.x, 0, CHUNK_SIZE * PIXELS_PER_TILE)
		player.global_position.y = clamp(player.global_position.y, 0, CHUNK_SIZE * PIXELS_PER_TILE)
		
		moving = true
	else:
		moving = false

func _handle_chunk_transition() -> void:
	var player_tile = Vector2i(
		int(player.global_position.x / PIXELS_PER_TILE),
		int(player.global_position.y / PIXELS_PER_TILE)
	)
	
	player_tile.x = clamp(player_tile.x, 0, CHUNK_SIZE - 1)
	player_tile.y = clamp(player_tile.y, 0, CHUNK_SIZE - 1)
	
	var at_edge = false
	var edge_dir = 0
	
	if player_tile.x >= CHUNK_SIZE - 2:
		at_edge = true
		edge_dir = 0
	elif player_tile.y >= CHUNK_SIZE - 2:
		at_edge = true
		edge_dir = 1
	elif player_tile.x <= 1:
		at_edge = true
		edge_dir = 2
	elif player_tile.y <= 1:
		at_edge = true
		edge_dir = 3
	
	if at_edge:
		var nbr = PlanetMath.get_neighbor(current_face, edge_dir)
		var nface = nbr["face"]
		
		var ncx = current_cx
		var ncy = current_cy
		match edge_dir:
			0: ncx += 1
			1: ncy += 1
			2: ncx -= 1
			3: ncy -= 1
		
		if ncx >= 0 and ncx < PlanetMath.face_chunks_x and ncy >= 0 and ncy < PlanetMath.face_chunks_y:
			chunk_loader.get_chunk(nface, ncx, ncy)

func _update_info() -> void:
	var player_tile = Vector2i(
		int(player.global_position.x / PIXELS_PER_TILE),
		int(player.global_position.y / PIXELS_PER_TILE)
	)
	
	var tile_info = ""
	if current_chunk:
		var tile_id = current_chunk.get_tile(player_tile.x, player_tile.y)
		var biome = tile_id / 10
		tile_info = "Tile: (%d, %d) | ID: %d | Biome: %d" % [player_tile.x, player_tile.y, tile_id, biome]
	
	var mega_info = ""
	if current_chunk and current_chunk.mega_structures.size() > 0:
		for ms in current_chunk.mega_structures:
			mega_info += "\nMega: %s (ID: %d) | Portais: %d" % [ms["type_info"]["name"], ms["global_id"], ms["portals"].size()]
	
	info_label.text = "Face: %d | Chunk: (%d, %d)\n%s%s\n\n[WASD] Mover\n[Scroll] Zoom Camera\n[ESC] Voltar ao orbital" % [
		current_face, current_cx, current_cy, tile_info, mega_info
	]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera2d.zoom *= Vector2(0.9, 0.9)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera2d.zoom *= Vector2(1.1, 1.1)
	
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		queue_free()