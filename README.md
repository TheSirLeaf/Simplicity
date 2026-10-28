# Simplicity

Jogo espacial de **extração de recursos e automação** (estilo Factorio), combinado com
**exploração espacial procedural** (estilo No Man's Sky), com uma pitada de **RNG/drops**,
**personalização profunda** (naves, equipamentos, bases), **combate** e **naves com interiores
e tripulação recrutável**.

> Este repositório, por enquanto, contém a documentação do projeto. O código virá em etapas.

## Pilares do projeto

1. **Loop de fábrica** — extrair → processar → fabricar → automatizar.
2. **Exploração procedural** — sistemas estelares gerados proceduralmente, com planetas, luas e astros de variados tamanhos.
3. **Espaço em 3D estilo EVE Online** — mapa do universo com zoom/órbita/seleção de área nos planetas, voo por ordens de navegação (approach, orbit, warp). **Superfícies planetárias em construção livre 3D** (estilo No Man's Sky / Dyson Sphere Program): o jogador constrói diretamente no terreno curvo, sem grid quadrado global. Interiores de nave e combate em solo continuam em vistas focadas (2D top-down ou 3D local — decisão futura).
4. **RNG & loot** — geração aleatória como conteúdo: drops, recursos raros, variedade de mundos e itens.
5. **Divergência extrema entre playthroughs** — a ambição: dois jogadores com caminhos tão amplos que um vira um superman que voa e atira laser pelos olhos e o outro constrói um exército de ciborgues e uma linha de artilharia bípede.
6. **Personalização enorme** — naves (interiores incluídos), equipamentos, bases e processos de produção.
7. **Estilos de máquina & consequências mecânicas** — caminhos de produção distintos e **misturáveis** (industrial poluente, brutalista-humana, digital/automatizada, technobiologia, sustentável/terraformação, planta-máquina, nuclear), cada um com estética própria; poluição/radiação alteram planetas, eficiência e Crew — e podem ser usadas a favor do jogador. **Variedade é obrigatória.**
8. **Pesquisa & descoberta** — tech tree alimentada por **exploração** (naves abandonadas, estações infectadas, artefatos, assentamentos) e por fontes de pensamento criativas (cientistas, datacenters, espíritos de dimensão superior, mentes em jarro, entidade cósmica, implante do jogador).
9. **Combate & tripulação** — NPCs recrutáveis em duas classes (**Especialistas** com traits/níveis e **Trabalhadores** em massa) para operar naves/maquinário e para lutar.
10. **Escalabilidade do mundo** — começa em uma galáxia; evolui para galáxias procedurais e, no limite, um universo contínuo.
11. **Acessibilidade técnica** — rodar bem em PCs medianos, com **suporte a Linux (Arch, Ubuntu) e Windows** como requisito de primeira classe.

## Escopo por etapas

Nada disso entra de uma vez. O roadmap detalhado está em [`docs/02-roadmap.md`](docs/02-roadmap.md):
começamos com um **MVP enxuto** e crescemos em fases até o universo completo.

## Documentação

| Documento | Conteúdo |
|---|---|
| [`docs/01-visao.md`](docs/01-visao.md) | Visão do jogo, pilares, referências e decisões de design |
| [`docs/02-roadmap.md`](docs/02-roadmap.md) | MVP e fases de desenvolvimento |
| [`docs/03-modulos.md`](docs/03-modulos.md) | Arquitetura por módulos (produção, combate, naves, etc.) |
| [`docs/04-tech.md`](docs/04-tech.md) | Escolha de engine/stack, requisitos técnicos e arquitetura de software |
| [`docs/05-fabricas-superficies.md`](docs/05-fabricas-superficies.md) | Fábricas, superfícies, caminhos de máquina e sistema de ecologia |
| [`docs/06-pitch.md`](docs/06-pitch.md) | Pitch do projeto — o resumo para mostrar a alguém |
