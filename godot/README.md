# Simplicity - Godot 4 Prototype

Protótipo da Fase 0: Planeta Cube-Sphere com transição 3D↔2D.

## Estrutura

```
godot/
├── project.godot                 # Configuração do projeto
├── icon.svg                      # Ícone do jogo
├── core/                         # Matemática e dados core (autoload)
│   ├── planet_math.gd            # Cube-sphere, geodésicas, projeções
│   └── chunk_data.gd             # Dados de chunk (tiles, heightmap, megas)
├── systems/                      # Sistemas globais (autoload)
│   ├── chunk_loader.gd           # Streaming de chunks, geração procedural
│   └── global_mega_structures.gd # Megasstruturas globais (acelerador, etc.)
├── scenes/
│   ├── main.tscn                 # Cena principal (GameManager)
│   ├── main.gd                   # Controlador de views (orbital/local/cube_map)
│   ├── orbital/
│   │   ├── OrbitalView.tscn      # Visão 3D orbital (planeta, câmera, raycast)
│   │   └── OrbitalView.gd        # Lógica orbital, input, seleção
│   ├── local/
│   │   ├── LocalView.tscn        # Visão 2D do chunk (grid 256x256, player)
│   │   └── LocalView.gd          # Render chunk, megas, movement, transição
│   └── ui/
│       ├── CubeMapView.tscn      # Mapa 2D do cubo desdobrado (net)
│       └── CubeMapView.gd        # Highlight de chunks, click para selecionar
├── resources/
│   ├── shaders/
│   │   └── planet_shader.gdshader # Shader cube-sphere (vertex)
│   ├── textures/
│   │   └── tile_atlas.png        # Atlas de tiles biomas (16x16)
│   └── environment.tres          # Environment (sky procedural)
```

## Como rodar

1. Abra o Godot 4.2+
2. Import Project → selecione `godot/project.godot`
3. Rode (F5)

## Controles

### Visão Orbital (3D)
| Tecla/Mouse | Ação |
|-------------|------|
| Scroll | Zoom in/out |
| RMB (segurar) + mover | Orbitar câmera |
| MMB ou LMB+RMB + mover | Pan |
| Click esquerdo no planeta | Seleciona chunk → abre visão local |
| **M** | Abre CubeMapView (mapa do cubo) |
| **ESC** | Sai do jogo |

### Visão Local (2D - Chunk 256×256)
| Tecla | Ação |
|-------|------|
| WASD | Move player (1 tile = 1m) |
| Scroll | Zoom câmera 2D |
| **ESC** | Volta para visão orbital |
| Andar até borda do chunk | Pré-carrega chunk vizinho (streaming) |

### CubeMapView (Mapa do Cubo 2D)
| Tecla | Ação |
|-------|------|
| Click numa face | Seleciona face |
| Click num chunk | Highlight do chunk |
| **ESC** ou **M** | Volta para orbital |

## O que testar

1. **Orbital → Local**: Click no planeta → vê chunk 2D com grid 1m, biomas, player amarelo
2. **Megasstruturas**: No orbital, vê acelerador equatorial (azul) e elevador espacial (amarelo) orbitando
3. **Local megas**: No chunk cruzado pelo acelerador, vê faixa azul + portais amarelos (⬢)
4. **Cube Map**: Pressiona **M** → vê net do cubo com 6 faces, chunks carregados em verde
5. **Streaming**: Anda player até borda do chunk → carrega vizinho (log no Output)
5. **Determinismo**: Mesma seed = mesmo planeta (mude `world_seed` no `chunk_loader.gd`)

## Arquitetura de Dados

```
ChunkData (por chunk carregado)
├── tiles[256*256]           # tile_type_id (bioma*10 + variação)
├── heightmap[256*256]       # altura procedural (-0.5..0.5m)
├── mega_structures[]        # segmentos de megas globais neste chunk
│   ├── polyline[]           # Array[Vector2] UV local [0,1] suavizado
│   └── portals[]            # pontos de conexão para fábricas
└── entities[]               # máquinas, itens (futuro)

MegaStructureGlobal (projeto global)
├── id, type, parameters     # ex.: particle_accelerator, equatorial
├── seed                     # variações determinísticas
└── chunks_affected[]        # cache de chunks cruzados (recalculado on-load)
```

## Próximos passos (Fase 0+)

- [ ] Terreno 3D procedural no `planet_shader` (heightmap + triplanar + biomas)
- [ ] Scatter system (rochas, recursos visuais via MultiMeshInstance3D)
- [ ] Fábrica 2D: esteiras, inserters, máquinas no grid ortogonal
- [ ] Conexão fábrica↔mega: esteira snap no `ConnectionPortal`
- [ ] Múltiplos corpos: Lua, asteroides (mesmo sistema, raio menor)
- [ ] Save/Load determinístico (JSON ou var2bytes)

## Notas técnicas

- **Determinismo total**: `world_seed` → `hash_chunk_seed(face, cx, cy)` → geração
- **Megasstruturas não salvas por chunk**: só o projeto global (`MegaStructureGlobal`) é salvo; segmentos por chunk são **derivados on-load** via `project_geodesic_to_chunks()`
- **Costura do cubo**: 12 arestas mapeadas em `PlanetMath.NEIGHBORS` com rotação de UV
- **Geodésicas**: grande círculo na esfera → projeta por chunk → suaviza (Catmull-Rom) → renderiza como Polygon2D no 2D
- **Escala**: Terra = 6.371km raio → ~39k chunks/face → 9B chunks total (só carrega visitados)

## Debug

- `F2` (no Godot) → Print Tree / Remote para inspecionar nodes
- Output log mostra: `Selected: face=X chunk=(X,Y) local_uv=(X,Y)`
- `chunk_loader.get_chunk_count()` no console mostra chunks carregados