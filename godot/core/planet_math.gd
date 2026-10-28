extends RefCounted
class_name PlanetMath

## Constantes do Cube-Sphere
const FACE_COUNT = 6
const CHUNK_SIZE = 256
const TILE_SIZE = 1.0
const DEFAULT_PLANET_RADIUS = 6371000.0

var face_chunks_x: int = 0
var face_chunks_y: int = 0
var _initialized: bool = false

func _ready() -> void:
	if not _initialized:
		_initialize_chunks(DEFAULT_PLANET_RADIUS)
		_initialized = true

func _initialize_chunks(radius: float) -> void:
	var face_width = PI * radius / 2.0
	face_chunks_x = max(1, ceil(face_width / CHUNK_SIZE))
	face_chunks_y = face_chunks_x
	print("PlanetMath initialized: face_chunks = ", face_chunks_x, "x", face_chunks_y)

func _ensure_initialized() -> void:
	if not _initialized:
		_initialize_chunks(DEFAULT_PLANET_RADIUS)
		_initialized = true

## 1. ESFERA -> FACE + UV
func sphere_to_face_uv(v: Vector3) -> Dictionary:
	_ensure_initialized()
	var nv = v.normalized()
	var abs_x = abs(nv.x)
	var abs_y = abs(nv.y)
	var abs_z = abs(nv.z)
	
	var face: int
	var u: float
	var v_: float
	
	if abs_x >= abs_y and abs_x >= abs_z:
		face = 0 if nv.x > 0 else 2
		u = -nv.z / abs_x
		v_ = nv.y / abs_x
	elif abs_y >= abs_z:
		face = 3 if nv.y > 0 else 1
		u = nv.x / abs_y
		v_ = nv.z / abs_y
	else:
		face = 4 if nv.z > 0 else 5
		u = nv.x / abs_z
		v_ = -nv.y / abs_z
	
	u = (u + 1.0) * 0.5
	v_ = (v_ + 1.0) * 0.5
	
	u = clamp(u, 0.0, 1.0)
	v_ = clamp(v_, 0.0, 1.0)
	
	return {"face": face, "u": u, "v": v_}

## 2. FACE + UV -> MUNDO 3D
func face_uv_to_world(face: int, u: float, v: float, radius: float = DEFAULT_PLANET_RADIUS) -> Vector3:
	u = u * 2.0 - 1.0
	v = v * 2.0 - 1.0
	
	var dir: Vector3
	match face:
		0: dir = Vector3(1, v, -u)
		1: dir = Vector3(u, -1, v)
		2: dir = Vector3(-1, -v, u)
		3: dir = Vector3(u, 1, -v)
		4: dir = Vector3(u, v, 1)
		5: dir = Vector3(-u, v, -1)
		_: dir = Vector3(1, 0, 0)
	
	return dir.normalized() * radius

## 3. UV -> CHUNK + LOCAL TILE
func uv_to_chunk(u: float, v: float) -> Dictionary:
	_ensure_initialized()
	var cx = int(u * face_chunks_x)
	var cy = int(v * face_chunks_y)
	cx = clamp(cx, 0, face_chunks_x - 1)
	cy = clamp(cy, 0, face_chunks_y - 1)
	
	var local_u = (u * face_chunks_x) - cx
	var local_v = (v * face_chunks_y) - cy
	
	var tile_x = int(local_u * CHUNK_SIZE)
	var tile_y = int(local_v * CHUNK_SIZE)
	tile_x = clamp(tile_x, 0, CHUNK_SIZE - 1)
	tile_y = clamp(tile_y, 0, CHUNK_SIZE - 1)
	
	return {
		"chunk_x": cx,
		"chunk_y": cy,
		"tile_x": tile_x,
		"tile_y": tile_y,
		"local_u": local_u,
		"local_v": local_v
	}

func chunk_to_uv_bounds(chunk_x: int, chunk_y: int) -> Dictionary:
	_ensure_initialized()
	var u0 = chunk_x / face_chunks_x
	var v0 = chunk_y / face_chunks_y
	var u1 = (chunk_x + 1) / face_chunks_x
	var v1 = (chunk_y + 1) / face_chunks_y
	return {"u0": u0, "v0": v0, "u1": u1, "v1": v1}

func chunk_key(face: int, cx: int, cy: int) -> String:
	return "%d_%d_%d" % [face, cx, cy]

func parse_chunk_key(key: String) -> Dictionary:
	var parts = key.split("_")
	if parts.size() == 3:
		return {"face": parts[0].to_int(), "chunk_x": parts[1].to_int(), "chunk_y": parts[2].to_int()}
	return {}

## 4. VIZINHANCA NAS ARESTAS (Costura do Cubo)
# edge: 0=right(+u), 1=top(+v), 2=left(-u), 3=bottom(-v)
# rotation: quantos 90 graus CW rotacionar para alinhar

func _get_neighbors() -> Dictionary:
	return {
		0: {0: {"face": 4, "edge": 2, "rot": 0}, 1: {"face": 3, "edge": 0, "rot": 1}, 2: {"face": 5, "edge": 0, "rot": 3}, 3: {"face": 1, "edge": 0, "rot": 1}},
		1: {0: {"face": 0, "edge": 3, "rot": 3}, 1: {"face": 4, "edge": 3, "rot": 0}, 2: {"face": 2, "edge": 3, "rot": 1}, 3: {"face": 5, "edge": 3, "rot": 1}},
		2: {0: {"face": 5, "edge": 2, "rot": 0}, 1: {"face": 3, "edge": 2, "rot": 3}, 2: {"face": 4, "edge": 0, "rot": 1}, 3: {"face": 1, "edge": 2, "rot": 3}},
		3: {0: {"face": 0, "edge": 1, "rot": 3}, 1: {"face": 5, "edge": 1, "rot": 0}, 2: {"face": 2, "edge": 1, "rot": 1}, 3: {"face": 4, "edge": 1, "rot": 1}},
		4: {0: {"face": 2, "edge": 0, "rot": 3}, 1: {"face": 3, "edge": 3, "rot": 0}, 2: {"face": 0, "edge": 2, "rot": 0}, 3: {"face": 1, "edge": 1, "rot": 0}},
		5: {0: {"face": 0, "edge": 0, "rot": 1}, 1: {"face": 3, "edge": 1, "rot": 2}, 2: {"face": 2, "edge": 2, "rot": 3}, 3: {"face": 1, "edge": 3, "rot": 2}}
	}

func get_neighbor(face: int, edge: int) -> Dictionary:
	return _get_neighbors()[face][edge].duplicate(true)

func cross_edge(face: int, chunk_x: int, chunk_y: int, local_uv: Vector2, edge: int) -> Dictionary:
	var nbr = get_neighbor(face, edge)
	var nface = nbr["face"]
	var nedge = nbr["edge"]
	var rot = nbr["rot"]
	
	var ncx = chunk_x
	var ncy = chunk_y
	match edge:
		0: ncx += 1
		1: ncy += 1
		2: ncx -= 1
		3: ncy -= 1
	
	var nuv = local_uv
	for _ in range(rot):
		nuv = Vector2(1.0 - nuv.y, nuv.x)
	
	match edge:
		0: nuv.x = 0.0
		2: nuv.x = 1.0
		1: nuv.y = 0.0
		3: nuv.y = 1.0
	
	return {"face": nface, "chunk_x": ncx, "chunk_y": ncy, "local_uv": nuv}

## 5. GEODESICAS (Megastruturas Globais)
func geodesic_points(center: Vector3, normal: Vector3, radius: float = DEFAULT_PLANET_RADIUS, num_segments: int = 360) -> Array[Vector3]:
	var points = []
	
	var start = normal.cross(Vector3.UP).normalized()
	if start.length() < 0.001:
		start = normal.cross(Vector3.RIGHT).normalized()
	
	var angle_to_center = atan2(center.dot(normal.cross(start)), center.dot(start))
	var rot_align = Basis(normal, angle_to_center)
	start = rot_align * start
	
	for i in range(num_segments):
		var angle = (2.0 * PI * i) / num_segments
		var rot = Basis(normal, angle)
		var p = (rot * start * radius)
		points.append(p)
	
	return points

func equatorial_geodesic(radius: float = DEFAULT_PLANET_RADIUS, num_segments: int = 360) -> Array[Vector3]:
	return geodesic_points(Vector3(1, 0, 0), Vector3(0, 1, 0), radius, num_segments)

func project_points_to_chunks(points_3d: Array[Vector3]) -> Array[Dictionary]:
	_ensure_initialized()
	var chunk_segments = {}
	
	for p in points_3d:
		var fuv = sphere_to_face_uv(p)
		var face = fuv["face"]
		var u = fuv["u"]
		var v = fuv["v"]
		
		var chunk_info = uv_to_chunk(u, v)
		var key = chunk_key(face, chunk_info["chunk_x"], chunk_info["chunk_y"])
		
		if not key in chunk_segments:
			chunk_segments[key] = {"face": face, "chunk_x": chunk_info["chunk_x"], "chunk_y": chunk_info["chunk_y"], "points": []}
		
		var local_u = (u * face_chunks_x) - chunk_info["chunk_x"]
		var local_v = (v * face_chunks_y) - chunk_info["chunk_y"]
		chunk_segments[key]["points"].append(Vector2(local_u, local_v))
	
	var result = []
	for seg in chunk_segments.values():
		if seg["points"].size() >= 2:
			seg["polyline"] = _smooth_polyline(seg["points"], 8)
			result.append(seg)
	
	return result

func _smooth_polyline(points: Array[Vector2], segments_per_span: int) -> Array[Vector2]:
	if points.size() < 2:
		return points
	
	var result = []
	for i in range(points.size() - 1):
		var p0 = points[max(0, i - 1)]
		var p1 = points[i]
		var p2 = points[i + 1]
		var p3 = points[min(points.size() - 1, i + 2)]
		
		for s in range(segments_per_span):
			var t = float(s) / segments_per_span
			var t2 = t * t
			var t3 = t2 * t
			
			var x = 0.5 * ((2 * p1.x) + (-p0.x + p2.x) * t + (2*p0.x - 5*p1.x + 4*p2.x - p3.x) * t2 + (-p0.x + 3*p1.x - 3*p2.x + p3.x) * t3)
			var y = 0.5 * ((2 * p1.y) + (-p0.y + p2.y) * t + (2*p0.y - 5*p1.y + 4*p2.y - p3.y) * t2 + (-p0.y + 3*p1.y - 3*p2.y + p3.y) * t3)
			
			result.append(Vector2(x, y))
	
	result.append(points[-1])
	return result

## 6. PORTAIS DE CONEXAO
func generate_connection_portals(polyline: Array[Vector2], spacing_tiles: float = 32.0, width_tiles: float = 4.0) -> Array[Dictionary]:
	var portals = []
	if polyline.size() < 2:
		return portals
	
	var total_length = 0.0
	for i in range(polyline.size() - 1):
		var a = polyline[i] * CHUNK_SIZE
		var b = polyline[i + 1] * CHUNK_SIZE
		total_length += (b - a).length()
	
	var num_portals = max(1, int(total_length / spacing_tiles))
	var dist_per_portal = total_length / num_portals
	
	var accumulated = 0.0
	var next_portal_at = dist_per_portal
	
	for i in range(polyline.size() - 1):
		var a = polyline[i] * CHUNK_SIZE
		var b = polyline[i + 1] * CHUNK_SIZE
		var seg_vec = b - a
		var seg_len = seg_vec.length()
		if seg_len < 0.001:
			continue
		
		var seg_dir = seg_vec / seg_len
		var seg_perp = Vector2(-seg_dir.y, seg_dir.x)
		
		while accumulated + seg_len >= next_portal_at:
			var t = (next_portal_at - accumulated) / seg_len
			t = clamp(t, 0.0, 1.0)
			
			var portal_pos = a + seg_vec * t
			var portal_uv = portal_pos / CHUNK_SIZE
			
			var tile_pos = Vector2i(int(round(portal_pos.x)), int(round(portal_pos.y)))
			tile_pos.x = clamp(tile_pos.x, 0, CHUNK_SIZE - 1)
			tile_pos.y = clamp(tile_pos.y, 0, CHUNK_SIZE - 1)
			
			var side = (portals.size() % 2) * 2 - 1
			var conn_dir = Vector2i(int(round(seg_perp.x * side)), int(round(seg_perp.y * side)))
			
			portals.append({
				"local_uv": portal_uv,
				"tile_pos": tile_pos,
				"direction": conn_dir,
				"connection_type": "bidirectional",
				"side": side
			})
			
			next_portal_at += dist_per_portal
		
		accumulated += seg_len
	
	return portals

## 7. UTILITARIOS
func _hash_variant(variant_value: Variant) -> int:
	return variant_value.hash()

func hash_combine(base: int, args: Array) -> int:
	var h = base
	for arg in args:
		h = (h * 31 + _hash_variant(arg)) & 2147483647
	return h