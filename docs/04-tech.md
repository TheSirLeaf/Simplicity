# 04 — Decisões Técnicas

> Status: **decisão inicial registrada: Godot 4** (com simulação isolada da engine).
> A comparação abaixo permanece como registro do raciocínio.

## Requisitos que a tecnologia precisa cumprir

| Requisito | Peso |
|---|---|
| Linux de primeira classe (Arch, Ubuntu) **e Windows** | **obrigatório** |
| Rodar bem em PCs medianos | **obrigatório** |
| Jogo quase-2D/isométrico | define o tipo de engine ideal (interiores e naves focadas) |
| Simulação pesada (fábricas, mundo procedural) | define a arquitetura |
| Desenvolvedor iniciante na engine escolhida | curva de aprendizado importa |

## Comparação de engines

### Godot 4 (GDScript / C#) — ⭐ recomendado

**Prós:**
- **Linux nativo de verdade** — o editor e os builds Linux rodam de primeira classe; fácil de testar no Arch/Ubuntu.
- Leve e roda bem em hardware modesto (tanto editor quanto jogo).
- Excelente em 2D — e quase-2D/isométrico é exatamente o ponto forte dele.
- Curva de aprendizado suave (GDScript parece Python; há opção C# para performance).
- Open source (MIT) — sem licença, sem dor de cabeça futura, comunidade enorme de 2D.

**Contras:**
- Se um dia o jogo exigir 3D "de verdade" em grande escala (superfícies planetárias com milhares de objetos 3D simultâneos), o Godot 3D é menos maduro que Unreal para esse caso extremo — mas o Simplicity aposta em superfícies leves e estilizadas, não em cenários 3D densos.
- Performance de GDScript não serve para a simulação pesada → precisaremos de C# ou
  extensão nativa para o core de simulação (arquitetura já prevê isso).

### Unity (C#)

**Prós:**
- C# maduro, ecossistema gigante, muitos tutoriais e assets.
- 2D muito capaz.

**Contras:**
- Editor Linux existe, mas é histórico de segunda classe (instabilidade, dependência de versões específicas).
- Runtime mais pesado; PCs medianos sentem mais.
- Histórico recente de decisões de licenciamento que abalaram a confiança da comunidade.

### Unreal Engine (C++ / Blueprints)

**Prós:**
- Potência gráfica de ponta.

**Contras:**
- **Não feito para 2D/isométrico** — usar Unreal para isso é lutar contra a ferramenta.
- Builds Linux possíveis mas o fluxo no Linux é claramente secundário.
- Projeto pesado; PCs medianos sofrem; tempo de iteração maior.

### Engine própria (Bevy/Rust, MonoGame/C#, Love2D/Lua)

**Prós:**
- Performance máxima e controle total; Bevy tem ECS moderno, Linux nativo.
- É o caminho "Factorio-style" (o Factorio usa engine própria).

**Contras:**
- Maior tempo até o primeiro jogo jogável — você ainda não definiu como quer aprender.
- Bevy: APIs mudam rápido, ecossistema jovem; MonoGame: muito código de infraestrutura por sua conta.

## Recomendação

**[DECIDIDO]** **Godot 4** para o MVP e as primeiras fases. A preocupação "Godot me
segura mais tarde?" foi avaliada e revisada com a decisão de design do jogo híbrido:

- O caso mais comum de "ficar preso" no Godot é gráfico 3D AAA. O Simplicity **tem uma
  camada 3D** (espaço estilo EVE Online e superfícies planetárias em construção livre
  3D), mas ela é **leve e estilizada**: corpos celestes esféricos, modelos de naves,
  estruturas na superfície, câmera orbital e ordens de navegação — exatamente o tipo
  de 3D que o Godot 4 lida bem. Não há requisitos de iluminação/física de ponta.
- Para simulação pesada estilo Factorio (milhares de entidades), *nenhum* engine
  scripting resolve; a solução é a mesma em qualquer engine: núcleo de simulação em
  código compilado. Com Godot, isso significa **C# ou GDExtension**, previsto abaixo.
- O risco de reescrever tudo em uma troca futura de engine é mitigado pela regra de
  ouro: **a simulação vive em `core/` e não conhece a engine**. Engine é a "tela";
  o jogo é o núcleo.

Com a ressalva de arquitetura:

> **Escreva a simulação (fábrica, worldgen, combate) isolada da engine**, num núcleo
> que não sabe o que é "renderização". Assim, se no futuro a engine vira gargalo,
> a lógica migra sem reescrever o jogo — e o jogo continua rodando no Linux.

Plano concreto:

1. **Linguagem:** começar com **GDScript** para aprender rápido e prototipar;
   migrar a simulação pesada (Production, Worldgen) para **C#** ou extensão nativa
   quando medirmos gargalos (nunca antes de existir um gargalo real).
2. **Estrutura do projeto:** separar `core/` (simulação pura, sem engine) de `app/` (Godot).
3. **Dados:** itens, receitas, módulos e NPCs em arquivos de dados (JSON/TOML/Resource),
   nunca hardcoded.

## Arquitetura de software (independente de engine)

Princípios que valem com qualquer engine escolhida:

1. **Simulação separada da apresentação.** O núcleo do jogo roda "headless";
   a engine só desenha o estado e repassa inputs. Isso viabiliza testes automatizados,
   testes de carga e saves robustos.
2. **Simulação única, duas apresentações.** O estado do jogo (sistemas, naves, fábricas,
   tripulação) é um só; **3D (espaço estilo EVE Online e superfícies planetárias em
   construção livre 3D) e vistas focadas (interiores de nave, combate em solo) são
   camadas de apresentação** que leem esse estado e repassam inputs. Uma mesma nave
   existe como objeto de simulação tanto no voo 3D quanto no interior focado.
3. **Determinismo por seed.** Worldgen e RNG de loot usam geradores com seeds derivadas
   (ex.: seed da galáxia → seed do sistema → seed do planeta → seed do drop).
4. **Geração on-demand.** O universo é uma função da seed; só o que foi visitado/
   modificado pelo jogador é salvo.
5. **Mapeamento esfera → superfície.** A seleção de área no planeta 3D (lat/long da
   esfera) resolve, via seed, para uma região de superfície 3D — sem armazenar o
   planeta inteiro.
6. **Data-driven.** Conteúdo (itens, receitas, módulos de nave, NPCs) vive em dados;
   o código implementa *sistemas*, não *conteúdo*.
7. **Ticks de simulação.** Fábricas atualizam em ticks fixos (desacoplados do framerate),
   com batching/otimização para milhares de entidades.

## Zoom multi-escala (aglomerado → galáxia → sistema → planeta)

O requisito de navegar por zoom em todas as escalas do universo **não será implementado
como zoom contínuo em um único mundo 3D** — em escalas de galáxia, posições maiores que
~10^7 unidades destroem a precisão de ponto flutuante em qualquer engine (câmera treme,
geometria quebra), e consertar isso exige técnicas pesadas (floating origin, depth
logarítmico) que não valem o custo neste projeto.

O modelo, em camadas:

| Nível | Cena 3D | Dados | Aparece na fase |
|---|---|---|---|
| Aglomerado de galáxias | pontos/nuvens de galáxias | seed do cluster | Fase 8 |
| Galáxia | braços espirais, sistemas como estrelas | seed da galáxia | Fase 7 |
| Sistema estelar | planetas/luas/astros como esferas orbitando | seed do sistema | Fase 2 |
| Planeta | esfera navegável com áreas selecionáveis | seed do planeta | Fase 2 |

- Cada nível é uma **cena 3D própria e leve**, gerada on-demand quando o jogador zooma
  até ela, e descartável quando sai dela.
- O "zoom contínuo" é **ilusão vendida pelas transições** (fade, voo de câmera, warp):
  é o que EVE e NMS fazem, e é suficiente.
- Cada nível de zoom corresponde a um nível de seed — a hierarquia de seeds e a de
  zoom são a mesma árvore.
- Melhoria futura (opcional, não comprometida): zoom contínuo *dentro* de um nível
  (ex.: aproximar suavemente de um planeta na cena do sistema) sem atravessar níveis.
  Zoom contínuo *atravessando* níveis fica registrado como "não fazer" — custo alto,
  retorno cosmético.

## A referência 3D: o que o EVE roda, e o teto real do Godot

**O que o EVE Online roda:** engine própria da CCP — hoje **Carbon** (open-sourced pela
CCP/Fenris Creations em 2025): núcleo **C++**, renderer **Trinity** (DirectX 11/12 e
Metal) e lógica de gameplay em **Python**. Mais de 20 anos de iteração, um único shard
de MMO e um pipeline de arte gigante — é daí que vem o "3D avançado" do EVE, não de
mágica de engine. Detalhe relevante: EVE historicamente roda bem em hardware modesto.

**O que isso significa para o Simplicity:** o visual espacial do EVE é feito de naves
PBR, bloom/glow, volumetria (nebulosas), efeitos de warp e câmera trabalhada — exatamente
o vocabulário que o **Godot 4 (Forward+/Vulkan) entrega**: materiais PBR, bloom,
volumetric fog, shaders customizados de nebulosa/estrela, GPUParticles. E o espaço é o
caso 3D mais amigável possível: fundo preto, sem interplay complexo de luzes, um sistema
por vez, naves modulares. Conclusão: o Godot **alcança** o nível de apresentação que a
exploração espacial do Simplicity pede. O gap em relação ao EVE será de **produção de
arte** (anos de pipeline), não de engine — e o que não buscamos replicar: batalhas de
milhares de jogadores num shard (TiDi) e escala de MMO.

## Ambiente de desenvolvimento

- **SO alvo de dev:** o que você usar, mas com **CI rodando no Linux e no Windows desde
  a Fase 0** (GitHub Actions com matriz Ubuntu + Windows) para garantir que os dois
  requisitos de plataforma nunca quebram.
- **Distribuições:** testar no Ubuntu (base de tudo) e no Arch (bleeding edge) —
  Godot cobre as duas sem esforço extra. Windows entra na mesma matriz de CI com custo
  marginal (Godot exporta os três alvos com o mesmo projeto).
- Controle de versão: git + este repositório (futuro).

## Questões em aberto

- [ ] Multiplayer: sequer considerar agora; a arquitetura de simulação separada
  facilitaria no futuro, mas não deve guiar decisões do MVP.
- [x] Superfície planetária — **decidido: construção livre 3D na superfície curva** (`07-planeta-grid.md`).
- [ ] Interiores de nave — em aberto (2D top-down vs. 3D local).
- [ ] 32-bit / Steam Deck: Steam Deck é Linux — naturalmente contemplada pela exigência Linux.
