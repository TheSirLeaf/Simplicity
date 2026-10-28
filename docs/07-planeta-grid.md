# 07 — Planeta: Superfície Global Curva & Construção Livre 3D

> Status: **Decisão de design travada.**
>
> Após análise da geometria (Teorema de Egregium de Gauss), ficou decidido: **não é possível ter
> grid quadrado ortogonal global em uma superfície esférica**. A escolha foi manter o **mapa
> global curvo (esférico)** e adotar **construção livre em 3D na superfície**, no estilo
> No Man's Sky / Dyson Sphere Program.
>
> O grid quadrado, se existir, fica restrito a **áreas planas artificiais** (abóbadas, plataformas
> de pouso, bases fechadas) — nunca ao planeta inteiro.

---

## Por que o grid quadrado global morreu

| Fato | Implicação |
|------|------------|
| Uma esfera tem curvatura gaussiana positiva em todo ponto. | Não pode ser mapeada para um plano sem distorção. |
| Um grid quadrado requer curvatura zero (plano) e ângulos de 360° em cada vértice. | Impossível em esfera. |
| O cube-sphere tem **8 cantos singulares** (3 faces se encontram, não 4). | Esteiras ortogonais quebram nas arestas dos cantos. |
| Não existe engine, shader ou truque de código que resolva isso. | É geometria elementar, não limitação técnica. |

## O que adotamos: Construção Livre 3D na Superfície (estilo NMS)

O jogador constrói estruturas **diretamente na superfície curva do planeta**, em 3D, sem um
grid ortogonal global forçando a posição.

### Características

| Elemento | Como funciona |
|----------|---------------|
| **Posicionamento** | Livre no terreno (cursor 3D projetado na superfície), com snap opcional por voxel/grade local para alinhamento estético. |
| **Esteiras/Tubos** | Seguem o contorno do terreno; podem subir e descer encostas. Não são blocos de um grid, são curvas/segmentos 3D. |
| **Máquinas** | Colocadas como objetos 3D com base própria; podem ficar inclinadas se o terreno for íngreme. |
| **Snapping** | Quando duas estruturas ficam próximas, conectam automaticamente (esteira entra na máquina, tubo se junta, etc.). |
| **Áreas planas artificiais** | O jogador pode construir plataformas de concreto/asoalho em regiões planas para criar "ilhas de grid quadrado" locais, se quiser. |

### O que isso significa pro gameplay

- **Perde-se:** o visual de cima-para- baixo com grid perfeito do Factorio, a facilidade de "esticar uma linha reta de esteiras" sem pensar no terreno.
- **Ganha-se:** um planeta verdadeiramente contínuo, curvo, sem costuras, sem cantos singulares, onde a fábrica cresce organicamente seguindo a geografia.
- **Fábrica global:** as bases em diferentes planetas/regiões são conectadas por nave espacial, não por esteiras que atravessam a atmosfera.

---

## Arquitetura técnica atualizada

### Worldgen (já existente)
- Planetas gerados proceduralmente por seed (determinístico).
- Terreno 3D com heightmap/voxel ou malha de superfície.
- Biomas por latitude/altitude.

### Construção (novo módulo: `Construction`)
- **Objetos 3D livres** na superfície, não tiles de grid.
- **Snapping por proximidade**: quando o jogador aproxima uma esteira de uma máquina, ela se conecta.
- **Colisão com o terreno**: estruturas não atravessam o solo (ou podem, se o jogador quiser construir abóbadas subterrâneas).
- **Suporte a plataformas planas**: o jogador pode "achatar" uma área e construir grid local ali, se desejar.

### Módulos afetados

| Módulo | Mudança |
|--------|---------|
| `Production` | Não usa mais grid ortogonal global. Máquinas e esteiras são objetos 3D livres. |
| `Ecologia/Ambiente` | Continua valendo (poluição se espalha na superfície). |
| `Ships` | Inalterado (interiores de nave continuam 2D top-down ou podem ser 3D livre — decisão futura). |
| `Player` | O personagem caminha na superfície curva (controle 3D, não mais restrito a grid 2D). |

---

## O que NÃO entra mais

| Recurso | Motivo |
|---------|--------|
| Grid quadrado global do planeta | Impossível geometricamente. |
| Esteiras ortogonais que atravessam o planeta inteiro | Quebrariam nos cantos do cube-sphere. |
| Factorio-like "top-down 2D global" | Abandonado em favor de construção 3D livre na superfície. |

---

## Próximos passos

1. **Atualizar `docs/05-fabricas-superficies.md`** — remover referências a grid quadrado global como requisito.
2. **Atualizar `docs/03-modulos.md`** — reescrever `Production` para construção livre 3D.
3. **Ajustar o protótipo Godot** — a visão local 2D (`LocalView`) deve ser revista: em vez de grid 256×256 tiles, passa a ser uma visão 3D da superfície local com colocação livre de objetos.
4. **Ajustar o protótipo HTML** — o `simplicity_local_continuous.html` já aponta nessa direção (jogador na superfície, movimento contínuo), mas precisa de colocação de estruturas 3D.

---

*Decisão registrada em 26/10/2026. O planeta é curvo. A fábrica é livre. O grid, se existir, é local e artificial.*