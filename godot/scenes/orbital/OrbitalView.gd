extends Node3D
class_name OrbitalView

@onready var planet_sphere: MeshInstance3D = %PlanetSphere
@onready var mega_renderer: MeshInstance3D = %MegaStructureRenderer
@onready var camera_rig: Node3D = %CameraRig
@onready var spring_arm: SpringArm3D = %SpringArm
@onready var orbital_camera: Camera3D = %OrbitalCamera
@onready var raycast: RayCast3D = %RayCast
@onready var info_label: Label = %UI/InfoPanel/InfoLabel
@onready var ui_panel: Panel = %UI/InfoPanel

var chunk_loader: ChunkLoader
var global_mega: GlobalMegaStructures
var planet_radius: float = PlanetMath.DEFAULT_PLANET_RADIUS

var orbit_angle_x: float = 0.0
var orbit_angle_y: float = PI / 4.0
var zoom_distance: float = 2.0
var min_zoom: float = 1.05
var max_zoom: float = 100.0

var orbiting: bool = false
var panning: bool = false
var last_mouse_pos: Vector2

var selected_chunk_key: String = ""
var selected_face: int = -1
var selected_cx: int = -1
var selected_cy: int = -1
var selected_local_uv: Vector2 = Vector2.ZERO

signal open_local_view(face: int, chunk_x: int, chunk_y: int, local_uv: Vector2)

func _ready() -> void:
	chunk_loader = ChunkLoader
	global_mega = GlobalMegaStructures
	
	PlanetMath._ensure_initialized()
	
	planet_sphere.mesh = _create_cube_sphere_mesh()
	
	var mat = planet_sphere.material_override
	if mat:
		mat.set_shader_parameter("planet_radius", planet_radius)
		mat.set_shader_parameter("face_chunks_x", PlanetMath.face_chunks_x)
	
	var mega_mat = mega_renderer.material_override
	if mega_mat:
		mega_mat.set_shader_parameter("planet_radius", planet_radius)
		mega_mat.set_shader_parameter("face_chunks_x", PlanetMath.face_chunks_x)
	
	_update_camera_position()
	_draw_mega_structures()
	
	ui_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
	_handle_input(delta)
	_update_info_panel()

func _handle_input(delta: float) -> void:
	var scroll = Input.get_axis("ui_page_down", "ui_page_up")
	if scroll != 0:
		zoom_distance = clamp(zoom_distance * pow(1.1, -scroll), min_zoom, max_zoom)
		_update_camera_position()
	
	if Input.is_action_pressed("orbital_orbit"):
		if not orbiting:
			orbiting = true
			last_mouse_pos = Input.get_mouse_position()
		else:
			var current = Input.get_mouse_position()
			var diff = current - last_mouse_pos
			orbit_angle_x -= diff.x * 0.005
			orbit_angle_y = clamp(orbit_angle_y - diff.y * 0.005, -PI / 2 + 0.01, PI / 2 - 0.01)
			last_mouse_pos = current
			_update_camera_position()
	else:
		orbiting = false
	
	if Input.is_action_pressed("orbital_pan"):
		if not panning:
			panning = true
			last_mouse_pos = Input.get_mouse_position()
		else:
			var current = Input.get_mouse_position()
			var diff = current - last_mouse_pos
			var basis = camera_rig.global_basis
			var right = basis.get_column(0)
			var up = basis.get_column(1)
			spring_arm.global_position -= (right * diff.x + up * diff.y) * (zoom_distance * 0.0001)
			last_mouse_pos = current
	else:
		panning = false
	
	if Input.is_action_just_pressed("ui_accept") and not Input.is_action_pressed("orbital_orbit"):
		_raycast_select()

func _raycast_select() -> void:
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var fuv = PlanetMath.sphere_to_face_uv(collision_point.normalized())
		var face = fuv["face"]
		var u = fuv["u"]
		var v = fuv["v"]
		
		var chunk_info = PlanetMath.uv_to_chunk(u, v)
		var cx = chunk_info["chunk_x"]
		var cy = chunk_info["chunk_y"]
		var local_uv = Vector2(chunk_info["local_u"], chunk_info["local_v"])
		
		selected_face = face
		selected_cx = cx
		selected_cy = cy
		selected_local_uv = local_uv
		selected_chunk_key = PlanetMath.chunk_key(face, cx, cy)
		
		ui_panel.visible = true
		open_local_view.emit(face, cx, cy, local_uv)
		
		print("Selected: face=%d chunk=(%d,%d) local_uv=(%.3f,%.3f)" % [face, cx, cy, local_uv.x, local_uv.y])

func _update_camera_position() -> void:
	var dir = Vector3(
		cos(orbit_angle_y) * cos(orbit_angle_x),
		sin(orbit_angle_y),
		cos(orbit_angle_y) * sin(orbit_angle_x)
	).normalized()
	
	camera_rig.global_position = dir * planet_radius * zoom_distance
	camera_rig.look_at(Vector3.ZERO, Vector3.UP)
	spring_arm.spring_length = planet_radius * (zoom_distance - 1.0)

func _draw_mega_structures() -> void:
	var structures = global_mega.get_all_structures()
	
	for struct in structures:
		var type_info = global_mega.TYPES[struct["type"]]
		if not type_info:
			continue
		
		var points = _generate_geodesic_for_type(struct)
		var color = type_info["color"]
		
		var line_mesh = ArrayMesh.new()
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = points
		
		line_mesh.add_surface_from_arrays(Mesh.PRIMITIVES_LINE_STRIP, arrays)
		
		var line_instance = MeshInstance3D.new()
		line_instance.mesh = line_mesh
		
		var mat = StandardMaterial3D.new()
		mat.shader = preload("res://resources/shaders/planet_shader.gdshader")
		mat.set_shader_parameter("planet_radius", planet_radius)
		mat.albedo_color = color
		mat.emission_enabled = true
		mat.emission_color = type_info["glow_color"]
		mat.emission_energy_multiplier = 2.0
		mat.render_method = StandardMaterial3D.RENDER_METHOD_FORWARD
		mat.cull_mode = StandardMaterial3D.CULL_DISABLED
		
		line_instance.material_override = mat
		mega_renderer.add_child(line_instance)

func _generate_geodesic_for_type(struct: Dictionary) -> Array[Vector3]:
	var params = struct["parameters"]
	var radius = params.get("radius", planet_radius)
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

func _update_info_panel() -> void:
	if selected_chunk_key != "":
		info_label.text = "Selecionado:\nFace: %d\nChunk: (%d, %d)\nLocal UV: (%.3f, %.3f)\n\n[Enter] Abrir visao local\n[Scroll] Zoom\n[RMB] Orbitar\n[MMB/LMB+RMB] Pan" % [
			selected_face, selected_cx, selected_cy,
			selected_local_uv.x, selected_local_uv.y
		]
	else:
		info_label.text = "Clique no planeta para selecionar um chunk\n\n[Scroll] Zoom\n[RMB] Orbitar\n[MMB/LMB+RMB] Pan"

func _create_cube_sphere_mesh(subdivisions: int = 64) -> ArrayMesh:
	var mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var vertices = []
	var uvs = []
	var normals = []
	var indices = []
	
	var face_data = [
		{"face": 0, "normal": Vector3(1, 0, 0), "u_axis": Vector3(0, 0, -1), "v_axis": Vector3(0, 1, 0)},
		{"face": 1, "normal": Vector3(0, -1, 0), "u_axis": Vector3(1, 0, 0), "v_axis": Vector3(0, 0, 1)},
		{"face": 2, "normal": Vector3(-1, 0, 0), "u_axis": Vector3(0, 0, 1), "v_axis": Vector3(0, -1, 0)},
		{"face": 3, "normal": Vector3(0, 1, 0), "u_axis": Vector3(1, 0, 0), "v_axis": Vector3(0, 0, -1)},
		{"face": 4, "normal": Vector3(0, 0, 1), "u_axis": Vector3(1, 0, 0), "v_axis": Vector3(0, 1, 0)},
		{"face": 5, "normal": Vector3(0, 0, -1), "u_axis": Vector3(-1, 0, 0), "v_axis": Vector3(0, 1, 0)}
	]
	
	var vertex_index = 0
	
	for fd in face_data:
		var face_id = fd["face"]
		var normal = fd["normal"]
		var u_axis = fd["u_axis"]
		var v_axis = fd["v_axis"]
		
		var face_center = normal * 0.5
		
		for gy in range(subdivisions + 1):
			for gx in range(subdivisions + 1):
				var u = (float(gx) / subdivisions) - 0.5
				var v = (float(gy) / subdivisions) - 0.5
				
				var cube_pos = face_center + u_axis * u + v_axis * v
				
				vertices.append(cube_pos)
				uvs.append(Vector2(float(gx) / subdivisions, float(gy) / subdivisions))
				normals.append(normal)
		
		for gy in range(subdivisions):
			for gx in range(subdivisions):
				var a = vertex_index + gy * (subdivisions + 1) + gx
				var b = vertex_index + gy * (subdivisions + 1) + gx + 1
				var c = vertex_index + (gy + 1) * (subdivisions + 1) + gx
				var d = vertex_index + (gy + 1) * (subdivisions + 1) + gx + 1
				
				indices.append(a)
				indices.append(b)
				indices.append(c)
				indices.append(b)
				indices.append(d)
				indices.append(c)
		
		vertex_index += (subdivisions + 1) * (subdivisions + 1)
	
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVES_TRIANGLES, arrays)
	return mesh