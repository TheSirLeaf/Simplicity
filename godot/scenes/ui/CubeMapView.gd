extends Control
class_name CubeMapView

@onready var face_panels: Dictionary = {
	0: %CubeNet/RowMid/Face0,
	1: %CubeNet/RowBottom/Face1,
	2: %CubeNet/RowMid/Face2,
	3: %CubeNet/RowTop/Face3,
	4: %CubeNet/RowMid/Face4,
	5: %CubeNet/RowMid/Face5
}
@onready var info_label: Label = %InfoPanel/InfoLabel

var chunk_loader: ChunkLoader
var selected_face: int = -1
var selected_cx: int = -1
var selected_cy: int = -1
var face_textures: Dictionary = {}

func _ready() -> void:
	chunk_loader = ChunkLoader
	PlanetMath._ensure_initialized()
	
	for face in range(6):
		var panel = face_panels[face]
		if panel:
			var texture_rect = TextureRect.new()
			texture_rect.custom_minimum_size = Vector2(200, 200)
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.mouse_filter = Control.MOUSE_FILTER_PASS
			panel.add_child(texture_rect)
			face_panels[face] = panel
	
	_generate_face_textures()
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _generate_face_textures() -> void:
	var size = 256
	
	for face in range(6):
		var img = Image.create(size, size, false, Image.Format.RGBA8)
		
		var base_colors = [
			Color(0.8, 0.3, 0.3, 0.3),
			Color(0.3, 0.3, 0.8, 0.3),
			Color(0.3, 0.8, 0.3, 0.3),
			Color(0.8, 0.8, 0.3, 0.3),
			Color(0.8, 0.3, 0.8, 0.3),
			Color(0.3, 0.8, 0.8, 0.3)
		]
		
		img.fill(base_colors[face])
		
		var chunks_per_face = PlanetMath.face_chunks_x
		var chunk_px = max(1.0, float(size) / chunks_per_face)
		
		for cx in range(chunks_per_face):
			for cy in range(chunks_per_face):
				var x = int(cx * chunk_px)
				var y = int(cy * chunk_px)
				var w = int(chunk_px)
				var h = int(chunk_px)
				
				var key = PlanetMath.chunk_key(face, cx, cy)
				var loaded = chunk_loader.get_loaded_chunk_keys().has(key)
				
				var color
				if not loaded:
					color = Color(1, 1, 1, 0.1)
				else:
					color = Color(0, 1, 0, 0.3)
				
				for px in range(w):
					if x + px < size:
						img.set_pixel(x + px, y, color)
						img.set_pixel(x + px, y + h - 1, color)
				for py in range(h):
					if y + py < size:
						img.set_pixel(x, y + py, color)
						img.set_pixel(x + w - 1, y + py, color)
				
				if face == selected_face and cx == selected_cx and cy == selected_cy:
					for px in range(w):
						for py in range(h):
							if x + px < size and y + py < size:
								img.set_pixel(x + px, y + py, Color(1, 1, 0, 0.5))
		
		var texture = ImageTexture.create_from_image(img)
		face_textures[face] = texture
		
		var panel = face_panels[face]
		if panel:
			var tex_rect = panel.get_child(0) if panel.get_child_count() > 0 else null
			if tex_rect and tex_rect is TextureRect:
				tex_rect.texture = texture

func update_highlight(face: int, cx: int, cy: int) -> void:
	selected_face = face
	selected_cx = cx
	selected_cy = cy
	_generate_face_textures()
	
	info_label.text = "Face: %d (%s)\nChunk: (%d, %d)\n\nClique num chunk para selecionar\n[ESC] Fechar" % [
		face, _face_name(face), cx, cy
	]

func _face_name(face: int) -> String:
	match face:
		0: return "+X Right"
		1: return "-Y Bottom"
		2: return "-X Left"
		3: return "+Y Top"
		4: return "+Z Front"
		5: return "-Z Back"
		_: return "?"

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		for face in range(6):
			var panel = face_panels[face]
			if panel and _is_point_in_control(event.position, panel):
				var local_pos = event.position - panel.global_position
				var panel_size = panel.size
				var chunks_per_face = PlanetMath.face_chunks_x
				
				var cx = int((local_pos.x / panel_size.x) * chunks_per_face)
				var cy = int((local_pos.y / panel_size.y) * chunks_per_face)
				
				cx = clamp(cx, 0, chunks_per_face - 1)
				cy = clamp(cy, 0, chunks_per_face - 1)
				
				update_highlight(face, cx, cy)
				break

func _is_point_in_control(point: Vector2, control: Control) -> bool:
	var rect = Rect2(control.global_position, control.size)
	return rect.has_point(point)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		queue_free()