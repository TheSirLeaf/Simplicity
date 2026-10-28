# 03 — Arquitetura por Módulos

> O jogo é dividido em **módulos com fronteiras claras**. Cada módulo é uma unidade de
> desenvolvimento, teste e eventual reuso. A regra de ouro: **módulos falam por dados e
> interfaces, não por acoplamento direto.**

## Diagrama de alto nível

```
┌─────────────────────────────────────────────────────┐
│                      Simplicity                     │
│                                                     │
│  ┌───────────┐   ┌──────────────┐   ┌────────────┐  │
│  │  Worldgen │──▶│   Universe   │◀──│  Game State│  │
│  │ (procedur)│   │ (galáxias/   │   │  / Save    │  │
│  └───────────┘   │  sistemas)   │   └────────────┘  │
│                  └──────┬───────┘                   │
│        ┌────────────────┼────────────────┐          │
│        ▼                ▼                ▼          │
│  ┌──────────┐    ┌────────────┐   ┌───────────┐    │
│  │Production│    │ Exploration│   │   Ships   │    │
│  │ (factory)│    │  / Travel  │   │ (interiores)│  │
│  └──────────┘    └────────────┘   └─────┬─────┘    │
│        │                            ┌────▼─────┐    │
│        ▼                            │   Crew   │    │
│  ┌──────────┐    ┌──────────┐      │  (NPCs)  │    │
│  │  Items   │◀──▶│  Combat  │◀────▶└──────────┘    │
│  │/Loot/RNG │    │          │                      │
│  └──────────┘    └──────────┘                      │
│                                                     │
│  ┌────────────────────────────────────────────────┐ │
│  │        Plataforma: UI, Save, Áudio, Input      │ │
│  └────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

## Módulos

### 1. Worldgen (geração procedural)
- Gera sistemas estelares, planetas, luas e astros a partir de **seeds**.
- Determinístico: mesma seed → mesmo mundo, sempre.
- Pode rodar "on-demand" (gera quando o jogador chega) — chave para suportar galáxia/universo.
- **Mapeamento esfera → superfície:** como os planetas são vistos em 3D (esfera, com
  seleção de área) e jogados em construção livre 3D (superfícies curvas), o worldgen define
  a função que liga os dois: coordenadas na esfera (lat/long ou região da seleção) →
  região de superfície 3D, sempre derivada da seed.

### 2. Universe (estrutura do mundo)
- Modelo dos corpos celestes: sistemas → astros → superfícies.
- Sabe onde o jogador está e coordena carregamento/streaming de conteúdo.

### 3. Production (fábrica)
- Mineração, extração, transportadores, máquinas, receitas, logística.
- **Construção livre 3D na superfície:** máquinas, esteiras e tubos são objetos 3D
  colocados livremente no terreno curvo do planeta (não em grid quadrado global —
  impossível geometricamente em esfera; ver `07-planeta-grid.md`). Plataformas
  artificiais planas podem ser construídas pelo jogador como exceção local.
- O módulo mais pesado em simulação — precisa ser otimizado desde cedo
  (buffers, batching, atualização em ticks).
- **Caminhos de máquina** (industrial, technobiologia, sustentável, planta-máquina,
  nuclear — `05-fabricas-superficies.md`) como conteúdo data-driven sobre este módulo.
- **Produção complexa multi-estágio:** cadeias longas e diversificadas, no padrão de
  variedade do EVE Online (blueprints em §Research & Descoberta).
- **Emite efeitos ambientais** (poluição, radiação, resíduos) consumidos pelo módulo
  Ecologia/Ambiente.

### 4. Exploration / Travel
- Movimentação do jogador, nave como transporte, transições entre corpos,
  mapa estelar (nas fases futuras).
- **Camada 3D estilo EVE Online:** voo por ordens de navegação (approach, orbit, warp),
  câmera orbital, seleção de alvos e de áreas de pouso nos corpos celestes.
- **Fronteira de camadas:** a simulação é única; 3D (espaço estilo EVE, superfícies
  planetárias em construção livre 3D) e vistas focadas (interiores de nave, combate
  em solo) são duas *apresentações*. A mesma nave/sistema existe nos dois modos — o
  módulo define as transições (selecionar área no planeta 3D → pousar → mapa de
  superfície local 3D).
- **Eventos aleatórios [FIRME]:** o RNG de exploração gera encontros e achados — nave
  caída (**restaurável → vira nave do jogador**), cargueiro caído (saqueável ou
  transformável em projeto de restauração), criaturas espaciais para caçar, sinal de
  mercador ambulante, sinal de socorro de alguém. Conteúdo data-driven; lista não é
  fechada ("e mais ainda poderiam vir").

### 5. Ships
- Nave como **objeto composto**: casco + módulos + interiores + estações operacionais.
- Interiores editáveis (layout em tiles/blocos).
- Stats derivados dos módulos (velocidade, carga, armamento, vida).

### 6. Crew (NPCs recrutáveis)
- Recrutamento, papéis (piloto, engenheiro, operador de máquina, soldado, cientista,
  crafter), treinamento, IA de comportamento (operar estações, lutar, seguir ordens).
- **Duas classes [FIRME]:**
  - **Especialistas:** crafters, cientistas, pilotos e afins — têm **traits, níveis** e
    progressão. O desempenho é mecânico de verdade: um crafter **ruim** desperdiça
    material, falha, leva mais tempo (e, em **crafts perigosos**, morre — apenas para
    crafters abaixo de certo nível; não é pra crafter bom morrer à toa); um crafter
    **bom** é rápido, conclui crafts complexos que níveis menores não conseguem e pode
    economizar recursos.
  - **Trabalhadores:** em massa (aos milhares) — tarefas simples: pilotos de caças
    simples, grupos enormes de cientistas comuns. **[em modelagem]** o design dessa
    classe ainda está em andamento na cabeça do dono do projeto.
- **Fontes de recrutamento:** incluem assentamentos humanos encontrados na exploração
  (mão de obra) e relações com **megápoles** que se mantém por interesse mútuo.

### 7. Player (personagem & progressão)
- O jogador **gerencia tudo, mas é um personagem**: caminha pelo mundo (superfície
  planetária em 3D livre) e pela própria nave (interior em vista focada), e pode
  **participar do combate pessoalmente**.
- **Corpo modificável, sem teto rígido [FIRME]** ("o que impede, né?"):
  - equipamento pessoal para explorar por si mesmo;
  - **implantes** — o caminho "David Martinez" (Edgerunners);
  - **mudança de corpo**;
  - **upload da própria mente → virar um robô**.
- **Escalas de ação pessoal:** a pé → **veículo** → **mecha** → **bombardeio orbital**
  (a própria nave equipada com armamento pesado).
- Conecta com: Combat (ação pessoal), Items (equipamento, implantes), Ships
  (bombardeio orbital), Crew (o avatar entre os especialistas), Research (implantes
  como conteúdo de pesquisa).

### 8. Research & Descoberta
- **Tech tree data-driven** — os caminhos de máquina (**misturáveis, DECIDIDO**) e todas
  as tecnologias vivem nela como conteúdo.
- **A pesquisa se alimenta de aquisição:** o jogador precisa **explorar e adquirir algo
  para pesquisar** — naves abandonadas, estações espaciais infectadas, antigas
  construções planetárias, assentamentos humanos ativos, artefatos de civilizações
  desaparecidas.
- **Fontes de poder científico (extensível, data-driven):** cientistas recrutados,
  datacenters, espíritos de uma dimensão superior, mentes humanas mantidas em jarro,
  uma entidade cósmica aprisionada usada como poder computacional, ou um implante que
  faz o próprio personagem do jogador pensar como nenhum outro. Cada fonte com custos,
  riscos e implicações próprias.
- **Pesquisa customizada por material** (refinarias específicas, ver §Items) e
  **blueprints** derivados dela.
- Consume: Exploration (sites e achados), Crew (cientistas), Items (artefatos).
- Alimenta: Production (receitas, refinarias, caminhos), Ships (melhorias), Combat.

#### Sistema de blueprints estilo EVE Online [FIRME]

A economia de itens segue o padrão de variedade do EVE Online:

- **BPO (Blueprint Original):** blueprint infinita, usável para sempre — o tesouro
  do produtor.
- **BPC (Blueprint Copy):** cópia com **usos limitados**, feita a partir de uma BPO.
- **Pesquisa de blueprint:** níveis de **ME (Material Efficiency)** e **TE (Time
  Efficiency)** — cada blueprint melhora gastando tempo/cientistas/recursos.
- **Invenção:** transformação de blueprint de tier inferior em tier superior
  (análogo ao T1 → T2 do EVE).
- **Blueprints customizadas:** refinarias/processos pesquisados por material específico
  (ver §Items) viram blueprints — e num multiplayer distante, comercializáveis.
- **Catálogo de itens grande e diverso** + produção complexa multi-estágio:
  a variedade do EVE como alvo de conteúdo, construída sobre o sistema data-driven.

### 9. Combat
- Combate em superfície e espacial. Dano, armas, munição, alvo, IA inimiga.
- Consumido pelo módulo Ships (armamento de nave) e pelo módulo Crew (NPCs lutadores).

### 10. Items / Loot / RNG
- Catálogo de itens definido em **dados** (não em código).
- Sistema de afixos, raridade, drops com seeds derivadas.
- Economia: crafting, valores, reciprocidade entre módulos.
- **Restrições de manuseio** (ex.: materiais radioativos — quem/pode como, ver caminho
  nuclear em `05-fabricas-superficies.md`).

#### Sistema de qualidade integral [FIRME]

**Todo item fabricado/extraído tem medidor de qualidade:** matérias-primas, produtos,
armas, equipamentos — sem exceção. Princípios:

- **Qualidade é atributo intrínseco do item**, presente desde o início do jogo
  (não é um afixo de drop tardio).
- **Stacks heterogêneos:** juntar dois montantes do mesmo item de qualidades diferentes
  **não** funde as qualidades — o montante final mostra a composição
  (ex.: `120× Chapa de Ferro — 40 Superior, 80 Comum`).
- A UI de inventário é **qualidade-ciente em todos os níveis**: montante, craft,
  esteira, mercado.
- **Propagação no craft [DECIDIDO]:** o produto **herda a qualidade da matéria-prima**,
  combinada com a **habilidade de quem fez o craft** — um NPC Especialista (traits/níveis)
  ou uma máquina (estatísticas da máquina, no caso de crafting automatizado).
- **Fontes de qualidade [DECIDIDO]:**
  - **A fonte (RNG no node):** a seed do planeta/node define a qualidade base da
    matéria-prima — um planeta pode ter material de altíssima qualidade já na fonte
    (ex.: *"Substrato de Stadium"* de qualidade máxima), ou uma fonte ruim.
  - **Refino customizado:** fonte ruim exige um processo que gasta tempo e outros
    insumos (água, combustível, grafeno...), e cuja **refinaria precisa ser pesquisada
    para aquele material específico** — pesquisa customizada. Concluída, pode virar uma
    **blueprint** que o jogador poderia vender (aspiração de multiplayer, beeem futuro).
  - **Quem faz:** habilidade do crafter / estatísticas da máquina.
  - **Caminho de máquina:** o caminho **digital** produz "produtos mais finos" —
    sinergia direta.
- **Desempenho do crafter [DECIDIDO]:** ruim → desperdício, falha, lentidão (e morte
  em crafts perigosos, só em nível baixo); bom → rapidez, crafts complexos, economia
  de recursos.

### 11. Ecologia / Ambiente (superfície)
- Estado ambiental por região da superfície: **poluição, radiação, saúde do bioma,
  fertilidade**.
- Recebe "emissões" do módulo Production (poluição, lixo radioativo, resíduos biológicos)
  e devolve **condições**: eficiência de máquinas, saúde/sofrimento da Crew, spawns,
  viabilidade de cultivo (caminho planta-máquina) e terreno recuperável por terraformação.
- O planeta é um **estado simulado e salvo**, não um backdrop estático.

### 12. Plataforma (serviços transversais)
- UI/HUD, áudio, input, save/load, configurações, localização (futuro).

## Regras de convivência entre módulos

1. **Dados definem a união:** itens, receitas, módulos de nave, NPCs e inimigos são
   *definições* em arquivos de dados consumidas por todos os módulos.
2. **Dependência em direção única sempre que possível** (ex.: Ships usa Combat; Combat não conhece Ships).
3. **Eventos como cola:** módulos se comunicam por eventos (ex.: "detonação de gerador"
   pode acionar Combat e Production sem acoplamento).
4. **Cada módulo testável isoladamente** — importante para performance e refatoração.

## Por que módulos ajudam este jogo em específico

- O escopo é **muito** grande (universo, tripulação, loot, fábricas) — módulos permitem
  construir e testar um pilar por vez, casando com o roadmap por fases.
- Módulos mapeiam 1:1 com as fases do roadmap: Worldgen na Fase 2, Ships na Fase 3, etc.
- Facilita paralelização futura (se um dia houver colaboradores) e substituição de implementações.
