# 01 — Visão do Jogo

**Simplicity** é um jogo espacial quase-2D/isométrico que une automação de fábrica,
exploração espacial procedural e progressão orientada a RNG e personalização.

## O que é

- **Extração de recursos estilo Factorio:** o jogador extrai, refina, transporta e automatiza
  a produção de recursos. Fábricas crescem organicamente e viram o motor econômico do jogo.
- **Exploração espacial estilo No Man's Sky:** uma galáxia de sistemas estelares gerados
  proceduralmente, cada um com planetas, luas e outros astros (maiores e menores), com
  biomas, recursos e perigos próprios.
- **RNG como conteúdo:** drops, loot, recursos raros, variações de mundos e de itens.
  A aleatoriedade gera descoberta e recompensa, não frustração (ver "Filosofia de RNG").
- **Personalização enorme:** naves com interiores editáveis, equipamentos, módulos de
  produção, layouts de bases, tripulação — **e o design das próprias fábricas/máquinas**.
- **Caminhos de máquina com consequências mecânicas:** industrial poluente (com poluição
  aproveitável), industrial brutalista (humana), digital/automatizada, technobiologia
  (máquinas vivas), sustentável/terraformação (buffs), planta-máquina (híbrido
  vegetal/mecânico) e nuclear (lixo radioativo, restrições de manuseio) — **misturáveis**,
  acessíveis via tech tree, cada um com estética própria. **Variedade é obrigatória.**
  Detalhes em `05-fabricas-superficies.md`.
- **Pesquisa por descoberta:** a tech tree se alimenta de **exploração** — naves
  abandonadas, estações espaciais infectadas, antigas construções planetárias,
  assentamentos humanos ativos (que podem virar mão de obra, ou uma megápole que se
  mantém por interesse mútuo) e artefatos de civilizações desaparecidas — e de **fontes
  de pensamento criativas**: cientistas recrutados, datacenters, espíritos de uma
  dimensão superior, mentes humanas mantidas em jarro, uma entidade cósmica aprisionada
  como poder computacional, ou um implante que faz o próprio jogador pensar como nenhum
  outro. Fontes são conteúdo extensível: muitas opções, "e ainda mais poderiam vir".
- **Crew em duas classes:** **Especialistas** (crafters, cientistas, pilotos — traits,
  níveis, desempenho mecânico real no craft/ciência/pilotagem) e **Trabalhadores**
  (aos milhares, tarefas simples). Parcialmente em modelagem.
- **O jogador é um personagem:** gerencia tudo, mas **caminha pelo mundo e pela própria
  nave**, e pode **participar do combate pessoalmente**. A escala da ação pessoal cresce:
  a pé, equipado para explorar por conta própria → veículo → **mecha** → **bombardeio
  orbital** (a própria nave equipada).
- **Corpo do jogador modificável — sem teto rígido** ("o que impede, né?"): equipamento,
  **implantes** (caminho David Martinez), mudança de corpo, e até **upload da própria
  mente para virar um robô**.
- **Meta de design — divergência extrema entre playthroughs:** a ambição é que, num jogo
  pronto, dois jogadores possam ter tido caminhos tão amplos que um transformou o próprio
  personagem num superman que voa e atira laser pelos olhos, enquanto o outro construiu
  um exército de ciborgues e uma linha de artilharia bípede. RNG + personalização +
  caminhos misturáveis + corpo modificável = cada universo de jogador é único.
- **Eventos aleatórios por RNG:** explorando, o jogador encontra nave caída (que pode ser
  **restaurada para virar nave dele**), cargueiro caído (para saquear ou transformar em
  projeto de restauração), criaturas espaciais para caçar, sinal de mercador ambulante,
  sinal de socorro de alguém. A lista não é fechada.
- **Combate:** no espaço e em superfícies, com naves armadas e NPCs recrutáveis que lutam
  ao lado do jogador.
- **Naves com interiores:** a nave não é só um "veículo de menu" — ela tem interior
  navegável, estações operacionais e tripulação com papéis.

## Referências

| Jogo | O que pegamos |
|---|---|
| Factorio | loop de produção, automação, logística, crescimento exponencial |
| No Man's Sky | geração procedural de sistemas/planetas, sensação de descoberta |
| **EVE Online** | **voo espacial em 3D (approach/orbit/warp), mapa do universo como interface central, naves como fit-outs modulares, economia orientada a recursos, sistema de blueprints (BPO/BPC, ME/TE)** |
| Starsector | naves como objetos ricos, combate espacial, crew |
| Starbound / Terraria | mineração em superfície, personalização, progressão por camadas |
| Dyson Sphere Program | fábrica em escala planetária/estelar |
| Cyberpunk 2077 / Edgerunners | implantes, transhumanismo, personalização de corpo ("David Martinez") |

## Perspectiva visual — jogo híbrido **[DECIDIDO]**

Simplicity tem **duas camadas de apresentação** sobre a mesma simulação:

### Camada espacial — 3D, estilo EVE Online
- **Mapa do universo em 3D:** sistemas estelares com planetas, luas e astros como corpos
  esféricos; é possível dar zoom, **orbitar um planeta** e **selecionar uma área dele**
  (escolher onde pousar/construir).
- **Navegação multi-escala por zoom:** aglomerado de galáxias → galáxia → sistema
  estelar → planeta. Implementada como **níveis de zoom em camadas com transições
  polidas** (ver `04-tech.md`) — cada nível gerado on-demand pela sua seed.
- **Voo espacial estilo EVE Online:** a nave se move em 3D com ordens de navegação
  (aproximar, orbitar, warp) e câmera livre — não é um "arcade de empurrar analógico".
- É 3D **leve e estilizado** (corpos celestes, naves, efeitos), não 3D AAA.

### Camada de dentro — superfície 3D livre + interiores focados

- **Superfícies planetárias: construção livre 3D na superfície curva** (estilo No Man's Sky / Dyson Sphere Program). O jogador constrói diretamente no terreno, não em um grid quadrado global. Isso é **impossível de evitar geometricamente** — uma esfera não pode ser coberta por um grid quadrado ortogonal sem distorção (Teorema de Egregium de Gauss). O grid quadrado, se existir, fica restrito a **plataformas artificiais planas** construídas pelo jogador (abóbadas, bases fechadas), nunca ao planeta inteiro.
- **Interiores de nave e combate em solo:** vistas focadas (2D top-down ou 3D local — decisão futura). São espaços fechados e pequenos, onde um grid local ou construção livre funciona sem o problema da curvatura planetária.

A fronteira entre as camadas é clara: **em 3D você está "na espaçonave/no espaço/na superfície de um planeta"; em vistas focadas você está "dentro de alguma coisa"** (numa sala de nave, numa base fechada). Selecionar uma área no planeta em 3D = escolher o destino de pouso, que vira um mapa de superfície local onde a fábrica acontece em 3D livre.

## Filosofia de RNG

- **Determinismo por seed:** todo mundo gerado (sistema, planeta, drop) deve ser reproduzível
  a partir de uma seed. Compartilhar uma seed = compartilhar um mundo.
- **RNG recompensa exploração:** coisas raras devem existir em lugares distantes ou perigosos,
  nunca atrás de sorte pura repetitiva (sem "gacha" sem contexto).
- **Camadas de aleatoriedade:** geração estrutural (mundos), drops (itens), variação
  (afixos/qualidade de itens). Cada camada com suas próprias regras e seeds derivadas.

## Tom: o estranho é conteúdo

O universo Simplicity comporta elementos que vão do grounded ao cósmico-esquisito:
espíritos de uma dimensão superior como fonte de pesquisa, mentes humanas mantidas em
jarro, uma entidade cósmica aprisionada usada como poder computacional, implantes que
mudam a mente do próprio jogador. Isso fixa um **tom** — ficção científica com doses de
weird/cosmic horror — e uma regra: essas fontes são **conteúdo data-driven extensível**,
não lore fixa. O catálogo cresce conforme o jogo cresce.

## Escala do mundo — visão de longo prazo

1. **Fase inicial:** uma galáxia com N sistemas estelares procedurais.
2. **Evolução:** múltiplas galáxias procedurais.
3. **Ambição final:** um universo contínuo, expandido conforme o jogador viaja.

A técnica por trás disso: **geração procedural on-demand com seeds**, nunca armazenar tudo.
O universo "existe" como uma função, não como dados. (Detalhes em `docs/04-tech.md`.)

## Requisitos não-funcionais

- Rodar bem em **PCs medianos** (meta de referência: hardware de ~2018+, integrado a GPU médio).
- **Linux é plataforma de primeira classe** — precisa rodar bem em Arch e Ubuntu, não é "port de segunda".
- **Windows também é plataforma alvo** (alvos oficiais: Linux Arch/Ubuntu + Windows).
- O jogo será pesado no fim das contas (simulação + mundo grande), então a arquitetura precisa
  ser performática desde o início: simulação separada de renderização, dados orientados a
  definições (data-driven), saves compactos.

## O que Simplicity NÃO é (por enquanto)

- Não é multiplayer no escopo próximo — registrado pelo autor como **aspiração de longo
  prazo** ("beeem futuro"), incluindo venda de blueprints entre jogadores. A arquitetura
  de simulação separada facilitaria um dia, mas não guia decisões.
- Não é 3D em primeira pessoa — o 3D existe apenas na camada espacial (voo/mapa estilo
  EVE Online), com câmera de terceira pessoa/orbital.
- Não é superfícies planetárias em grid quadrado global — uma esfera não pode ser coberta por grid quadrado ortogonal sem distorção (Teorema de Egregium de Gauss). Superfícies usam construção livre 3D no terreno.
- Não é um MMO de universo infinito no MVP — o universo inteiro é objetivo de longo prazo.
