extends Node
class_name GameManager

@onready var chunk_loader: ChunkLoader = %Systems/ChunkLoader
@onready var global_mega: GlobalMegaStructures = %Systems/GlobalMegaStructures
@onready var orbital_view: Node3D = %Views/OrbitalView
@onready var local_view: Node2D = %Views/LocalView
@onready var cube_map_view: Control = %Views/CubeMapView

var current_view: String = "orbital"  # "orbital", "local", "cube_map"

func _ready() -> void:
	# Configura views iniciais
	orbital_view.open_local_view.connect(_on_orbital_open_local_view)
	local_view.tree_exiting.connect(_on_local_view_exiting)
	
	# Inicia na visão orbital
	_show_orbital_view()

func _show_orbital_view() -> void:
	current_view = "orbital"
	orbital_view.visible = true
	orbital_view.process_mode = Node.PROCESS_MODE_INHERIT
	local_view.visible = false
	local_view.process_mode = Node.PROCESS_MODE_DISABLED
	cube_map_view.visible = false
	cube_map_view.process_mode = Node.PROCESS_MODE_DISABLED
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _show_local_view(face: int, cx: int, cy: int, local_uv: Vector2) -> void:
	current_view = "local"
	orbital_view.visible = false
	orbital_view.process_mode = Node.PROCESS_MODE_DISABLED
	local_view.visible = true
	local_view.process_mode = Node.PROCESS_MODE_INHERIT
	cube_map_view.visible = false
	cube_map_view.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Inicializa local view
	local_view.initialize(face, cx, cy, local_uv)

func _show_cube_map_view() -> void:
	current_view = "cube_map"
	orbital_view.visible = false
	orbital_view.process_mode = Node.PROCESS_MODE_DISABLED
	local_view.visible = false
	local_view.process_mode = Node.PROCESS_MODE_DISABLED
	cube_map_view.visible = true
	cube_map_view.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Atualiza highlight se há seleção
	var orbital_script = orbital_view.get_script_instance()
	if orbital_script and orbital_script.selected_chunk_key != "":
		cube_map_view.update_highlight(
			orbital_script.selected_face,
			orbital_script.selected_cx,
			orbital_script.selected_cy
		)

func _on_orbital_open_local_view(face: int, cx: int, cy: int, local_uv: Vector2) -> void:
	_show_local_view(face, cx, cy, local_uv)

func _on_local_view_exiting() -> void:
	# Volta para visão orbital quando LocalView é fechado
	_show_orbital_view()

func _input(event: InputEvent) -> void:
	# Tecla M para alternar mapa do cubo
	if event is InputEventKey and event.keycode == KEY_M and event.pressed:
		if current_view == "orbital":
			_show_cube_map_view()
		elif current_view == "cube_map":
			_show_orbital_view()
	
	# Tecla ESC
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		if current_view == "local":
			_show_orbital_view()
		elif current_view == "cube_map":
			_show_orbital_view()
		elif current_view == "orbital":
			get_tree().quit()