extends RefCounted
class_name GlobalMegaStructures

var structures: Dictionary = {}
var next_id: int = 1
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

var TYPES: Dictionary = {
	"particle_accelerator": {"name": "Acelerador de Particulas", "width_tiles": 4.0, "portal_spacing": 32.0, "color": Color(0.2, 0.8, 1.0), "glow_color": Color(0.0, 0.5, 1.0, 0.8)},
	"space_elevator": {"name": "Elevador Espacial", "width_tiles": 6.0, "portal_spacing": 64.0, "color": Color(1.0, 0.8, 0.2), "glow_color": Color(1.0, 0.6, 0.0, 0.8)},
	"orbital_ring": {"name": "Anel Orbital", "width_tiles": 8.0, "portal_spacing": 128.0, "color": Color(0.8, 0.2, 1.0), "glow_color": Color(0.6, 0.0, 0.8, 0.8)}
}

func create_structure(type_name: String, parameters: Dictionary) -> int:
	var id = next_id
	next_id += 1
	
	var struct = {
		"id": id,
		"type": type_name,
		"parameters": parameters.duplicate(true),
		"seed": _rng.randi(),
		"created_at": Time.get_unix_time_from_system(),
		"owner": 0,
		"chunks_affected": []
	}
	
	structures[id] = struct
	_recalculate_chunks_affected(id)
	return id

func _recalculate_chunks_affected(id: int) -> void:
	var struct = structures[id]
	if not struct:
		return
	
	var points = _generate_geodesic_for_type(struct)
	var segments = PlanetMath.project_points_to_chunks(points)
	
	var chunks = []
	for seg in segments:
		chunks.append(PlanetMath.chunk_key(seg["face"], seg["chunk_x"], seg["chunk_y"]))
	
	struct["chunks_affected"] = chunks

func _generate_geodesic_for_type(struct: Dictionary) -> Array[Vector3]:
	var params = struct["parameters"]
	var radius = params.get("radius", PlanetMath.DEFAULT_PLANET_RADIUS)
	var num_segments = params.get("num_segments", 720)
	
	match struct["type"]:
		"particle_accelerator":
			var center = params.get("center", Vector3(1, 0, 0)).normalized()
			var normal = params.get("normal", Vector3(0, 1, 0)).normalized()
			return PlanetMath.geodesic_points(center, normal, radius, num_segments)
		
		"space_elevator":
			var center = params.get("center", Vector3(0, 0, 1)).normalized()
			var normal = params.get("normal", Vector3(1, 0, 0)).normalized()
			return PlanetMath.geodesic_points(center, normal, radius, num_segments)
		
		"orbital_ring":
			var lat = params.get("latitude", 0.0)
			var lat_rad = lat * PI / 180.0
			var center = Vector3(cos(lat_rad), 0, sin(lat_rad)).normalized()
			var normal = Vector3(0, 1, 0)
			return PlanetMath.geodesic_points(center, normal, radius, num_segments)
	
	return []

func get_structure(id: int) -> Dictionary:
	return structures.get(id)

func get_structures_in_chunk(face: int, cx: int, cy: int) -> Array[Dictionary]:
	var key = PlanetMath.chunk_key(face, cx, cy)
	var result = []
	for struct in structures.values():
		if key in struct["chunks_affected"]:
			result.append(struct)
	return result

func get_segment_for_chunk(id: int, face: int, cx: int, cy: int) -> Dictionary:
	var struct = structures.get(id)
	if not struct:
		return {}
	
	var points = _generate_geodesic_for_type(struct)
	var segments = PlanetMath.project_points_to_chunks(points)
	
	for seg in segments:
		if seg["face"] == face and seg["chunk_x"] == cx and seg["chunk_y"] == cy:
			var type_info = TYPES[struct["type"]]
			seg["portals"] = PlanetMath.generate_connection_portals(seg["polyline"], type_info["portal_spacing"], type_info["width_tiles"])
			seg["global_id"] = id
			seg["type_info"] = type_info
			return seg
	
	return {}

func remove_structure(id: int) -> void:
	structures.erase(id)

func get_all_structures() -> Array[Dictionary]:
	return structures.values()