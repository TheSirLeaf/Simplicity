# 05 — Fábricas e Superfícies

> Status: **em maturação** — este é o sistema que o dono do projeto está desenhando agora,
> e será o primeiro a ser construído. Decisões fechadas e questões em aberto convivem aqui.

## O que já é certo [FIRMES]

- **A fábrica é o coração do jogo** — a gameplay de superfície é a primeira a ser construída.
- **Variedade é obrigatória.** Não é um "nice to have": o jogo existe para oferecer
  caminhos de produção distintos, cada um com estética e mecânicas próprias.
- **O jogador desenha suas fábricas e máquinas** — a personalização do gameplay é profunda:
  o design da fábrica *é* o gameplay.
- **Consequências mecânicas, não cosméticas:** poluição, radiação e biologia alteram
  o planeta, a eficiência, a tripulação e até as opções de estratégia — e podem ser
  **aproveitadas a favor do jogador**, não apenas punidas.
- **Superfícies em construção livre 3D:** fábricas são construídas diretamente no
  terreno curvo do planeta (estilo No Man's Sky / Dyson Sphere Program), não em um
  grid quadrado global — isso é geometricamente impossível em uma esfera
  (ver `07-planeta-grid.md`). Plataformas artificiais planas podem ser construídas
  pelo jogador como exceção local, nunca como regra do planeta inteiro.

## Caminhos de máquina (os "estilos de fábrica")

Cada caminho é um conjunto de tecnologias + estética + consequências mecânicas.
**A lista abaixo não é fechada** — novos caminhos são conteúdo, e o sistema é
data-driven por design.

| Caminho | Ideia | Efeitos mecânicos | Custo/risco | Estética |
|---|---|---|---|---|
| **Industrial poluente** | Produção máxima, máquinas sujas | Poluição altera o planeta; **poluição pode ser aproveitada** (processos que a consomem/favorável) | NPCs sofrem: menos eficientes, doentes, **podem morrer ou ficar incapazes** | Ferrugem, fumaça, ruído |
| **Industrial brutalista (humana)** | Indústria pesada com **mão de obra humana em massa** | Produção em volume; Crew operando as máquinas diretamente; amplifica exposição a poluição/radiação (as consequências do caminho poluente recaem sobre pessoas) | Depende de recrutamento e condições da Crew | Brutalismo: concreto, galpões, trabalho braçal |
| **Digital / automatizada** | Automatização em tudo, digitalização total | **Volume bruto menor, eficiência maior — produtos mais finos (qualidade)**; sinergia direta com o sistema de qualidade | Infraestrutura computacional; produção a gral fica fraca | Limpa, telas, servidores, luz fria |
| **Technobiologia** | Máquinas **vivas**: criaturas engenheiradas como equipamento | Crescem, precisam de "alimentação", podem **mudar/mutar** (RNG orgânico), buffs biológicos | Impróvisíveis; precisam de cuidado contínuo | Orgânica, carne + metal |
| **Sustentável / Terraformação** | Limpar e regenerar o planeta | Buffs: NPCs mais eficientes, recursos regenerativos, bioma agradece | Mais lenta de escalar no início | Verde, limpa, luz natural |
| **Planta-máquina** | Plantas geneticamente modificadas que **produzem** — híbrido vegetal/mecânico | Alta produção com poluição baixa; requer atenção biológica (pragas? maturação?) | Vulnerável a eventos biológicos | Botânica industrial |
| **Nuclear** | Maquinário de energia densa | Energia barata e abundante | **Lixo radioativo precisa de descarte**; alguns recursos não podem ser manuseados de qualquer forma | Retrô-futurista, concreto |

### Caminhos misturáveis [DECIDIDO]

- Os caminhos **não são exclusivos** — usar tecnologia nuclear não impede seguir um
  pouco o desenvolvimento sustentável.
- Todos são acessíveis através de **pesquisa (tech tree)** — ver módulo
  **Research & Descoberta** em `03-modulos.md`.

### Questões em aberto sobre os caminhos

- **Brutalista-humana e digital são caminhos próprios ou variações do industrial?**
  Ficam registradas como estéticas candidatas; decidir eventualmente se são caminhos
  independentes, extremos de um mesmo eixo (humano ←→ máquina), ou variantes.
- **Poluição como recurso:** confirmado que pode jogar a favor — detalhar *como*
  (reagentes de processos, cultivos que prosperam em atmosfera suja, biomas que evoluem).
- Interação com **Worldgen:** planetas com biomas/temperamentos pré-dispostos a certos
  caminhos (RNG de mundo × estratégia do jogador).

### O eixo humano ←→ máquina (observação de design)

As duas novas estéticas sugerem um eixo fundamental: **trabalho humano vs. automação
digital**. Elas se cruzam de forma interessante com os sistemas já decididos:

- Brutalista-humana → puxa o módulo **Crew** para o centro da fábrica (mais NPCs,
  operando máquinas, sofrendo poluição).
- Digital → reduz Crew, mas conecta com o **sistema de qualidade** (produtos finos).
- Juntas, elas dão à escolha de estilo um trade-off econômico real: **volume vs. fino**,
  pessoas vs. servidores — e não só uma escolha de skin.

## Sistema de ambiente / ecologia (novo sistema transversal)

Para que os caminhos tenham consequências de verdade, a superfície precisa simular
seu **estado ambiental**:

- Indicadores por região/chunk: **poluição, radiação, saúde do bioma, fertilidade**.
- Efeitos propagados: eficiência das máquinas, sanidade/saúde da **Crew** (NPCs), spawns
  de fauna, estado do bioma, condições para cultivo de plantas.
- **Reversível:** terraformação pode recuperar; o histórico ambiental fica salvo
  (o planeta é um estado, não um backdrop).

## Decisões em aberto (análise para maturar)

### 1. Construção livre 3D na superfície

Em vez de grid ortogonal, o jogador coloca estruturas como objetos 3D livres no terreno.
Questões ainda a definir:

- **Snap por voxel/grade local:** o jogador coloca livremente, mas existe um snap
  opcional (ex: grade de 1m ou 2m) para ajudar no alinhamento estético? Ou é totalmente
  livre (estilo NMS)?
- **Conexão automática:** quando uma esteira/tubo se aproxima de uma máquina, ela
  conecta automaticamente por proximidade, ou o jogador precisa "desenhar" a conexão?
- **Inclinação de máquinas:** máquinas podem ficar inclinadas em encostas, ou sempre
  ficam em pé (com base que se adapta ao terreno)?
- **Plataformas planas artificiais:** o jogador pode "achatar" uma área e criar uma
  superfície plana para construir grid local (estilo Factorio em miniatura), se quiser.

### 2. Granularidade: máquina-a-máquina vs. regional

- **Máquina-a-máquina:** cada esteira, inserter, máquina é um objeto 3D individual.
  Personalização máxima — é o que "o jogador desenha sua fábrica" pede.
- **Regional (nós de recurso):** constrói-se a fábrica *sobre* um node de recurso e o
  jogador cuida da logística macro. Encaixa com a escala galáctica.

> **Recomendação inicial:** as duas, em camadas. O núcleo é **máquina-a-máquina** (objetos
> 3D livres), e a camada regional entra depois como abstração de alto nível.

### 3. Como o jogador "desenha" máquinas e fábricas

Em aberto — interpretar "personalizável" em pelo menos dois níveis:

- **Layout:** onde cada máquina fica, como as esteiras conectam (construção livre 3D).
- **Composição:** montar a própria máquina a partir de partes/módulos (a nave já funciona
  assim — **por que a máquina de superfície não?**). Há forte coerência em reaproveitar
  o sistema de "montagem por módulos" de naves para máquinas de superfície.

### Qualidade na fonte e refino customizado [DECIDIDO]

- O **RNG do node** define a qualidade base da matéria-prima: um planeta pode ter um
  material de altíssima qualidade já na fonte (ex.: *"Substrato de Stadium"* de
  qualidade máxima), ou uma fonte ruim.
- Fontes de qualidade ruim pedem **refino customizado por material**: um processo que
  gasta tempo e outros insumos (água, combustível, grafeno...), e cuja **refinaria
  precisa ser pesquisada para aquele material específico** — pesquisa customizada.
- Pesquisa customizada concluída pode virar **blueprint** — que, num multiplayer de
  longo prazo (aspiração registrada em `01-visao.md`), poderia ser vendida.
- Regras de propagação e desempenho de crafter estão no módulo Items
  (`03-modulos.md` §Sistema de qualidade integral).

## Impacto nos módulos e no roadmap

- Novo módulo **Ecologia/Ambiente** (ver `03-modulos.md`).
- Novo módulo **Research & Descoberta** (ver `03-modulos.md`): tech tree que dá acesso
  aos caminhos, pesquisa alimentada por exploração e fontes criativas de pensamento.
- **Production** ganha sub-temas: grid, logística regional, designer de máquinas.
- Os caminhos de máquina entram como **fase própria** no roadmap (Fase 5), pois dependem
  de Production e Ecologia prontos.
- O caminho **nuclear** introduz recurso de "restrição de manuseio" — touchpoint com
  Items/RNG e com Crew (quem pode manusear o quê).
