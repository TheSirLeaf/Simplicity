# 02 — Roadmap por Etapas

> Princípio: **cada fase entrega um jogo jogável.** Nada de "3 anos sem build".
> O MVP é deliberadamente pequeno; as fases seguintes expandem uma dimensão por vez.

## Fase 0 — Fundação (pré-jogo)

- Escolher engine/stack emontar o projeto vazio (ver `docs/04-tech.md`).
- Definir a arquitetura de módulos (`docs/03-modulos.md`) e o padrão de dados
  (itens, receitas, recursos como data-driven).
- Protótipo técnico mínimo: um tile/planetoide desenhado, câmera, loop de update
  rodando no Linux e no Windows.

**Critério de saída:** projeto abre e roda nos dois SOs, arquitetura de módulos no lugar.

---

## MVP — "Uma fábrica e uma nave" (jogável)

O menor jogo que já é *Simplicity*:

- **1 único planeta** (estático ou com seed fixa) com terreno minerável.
- **Loop de fábrica básico:** minerar → mover (esteira/inserter simplificado) → fundir →
  craftar alguns itens.
- **1 nave funcional** com voo simples entre o planeta e um ponto em órbita (sem interior
  completo — um compartimento placeholder).
- **Combate mínimo:** uma ameaça simples (inimigo que ataca a fábrica ou o jogador).
- **Save/Load.**

**Critério de saída:** alguém consegue instalar no Linux, jogar 30 minutos, minerar,
automatizar uma mini-cadeia e sobreviver a um combate.

> O que o MVP **não** tem (de propósito): geração procedural de sistemas, luas,
> tripulantes, loot RNG, personalização profunda, múltiplos sistemas.
> A camada 3D (voo estilo EVE, mapa do universo) entra na Fase 2 — no MVP a nave é
> um placeholder simples, até 2D, para não atrasar o critério de saída.

---

## Fase 2 — Exploração procedural + camada 3D

- **Geração procedural do sistema estelar:** planetas, luas e astros menores a partir de seed.
- **Camada espacial em 3D (estilo EVE Online):**
  - visão do sistema com corpos celestes esféricos (zoom, órbita da câmera ao redor do planeta);
  - **seleção de área no planeta** → define onde o jogador pousa (entra em **superfície local 3D** para construção livre);
  - voo com ordens de navegação: aproximar, orbitar, warp.
- **Viagem entre corpos do sistema** (a nave como transporte real).
- **Eventos aleatórios de exploração:** nave caída (restaurável → vira nave do jogador),
  cargueiro caído (saque ou projeto de restauração), criaturas espaciais para caçar,
  sinal de mercador ambulante, sinal de socorro.
- **Bases em mais de um corpo** — o loop de fábrica passa a exigir múltiplos locais.
- **Tech tree básica com pesquisa por descoberta:** as primeiras tecnologias vêm do que
  se **acha e adquire explorando** (naves abandonadas, estações, artefatos) e de fontes
  simples (cientistas recrutados, datacenters).
- **Primeiras regras de RNG de recursos:** raridade por tipo de corpo.

## Fase 3 — Naves de verdade

- **Interiores de nave editáveis** (módulos, layouts, estações).
- **Tripulação recrutável:** NPCs que operam estações e lutam.
- **Crew em duas classes:** **Especialistas** (crafters, cientistas, pilotos — traits e
  níveis que afetam desempenho real) e **Trabalhadores** (em massa, tarefas simples —
  design ainda em modelagem).
- **Aprimoramento de nave** (performance por módulos instalados).

## Fase 4 — Combate pleno

- Combate espacial real (naves vs. naves, pygame-like tático ou em tempo real — a decidir).
- Combate em superfície com armas/perks.
- **Participação pessoal do jogador** no combate (o personagem como unidade de ação).
- **Bombardeio orbital** (nave equipada com armamento pesado).
- NPCs de combate com papéis e treinamento.

## Fase 5 — Estilos de máquina & ecologia

Os **caminhos de máquina** (doc `05-fabricas-superficies.md`) — dependem de Production
e Crew maduros. **[DECIDIDO]** Caminhos são **misturáveis** e todos acessíveis via
**tech tree**:

- **Sistema de ambiente/ecologia** na superfície: poluição, radiação, saúde do bioma —
  com efeitos mecânicos reais (eficiência, Crew sofrendo, bioma mudando).
- Primeiros caminhos: **industrial poluente** (com poluição aproveitável a favor) e
  **nuclear** (lixo radioativo, restrições de manuseio).
- Caminhos seguintes conforme maturação: **technobiologia** (máquinas vivas, RNG
  orgânico), **sustentável/terraformação** (buffs de recuperação), **planta-máquina**.
- Estética própria por caminho (data-driven).

## Fase 6 — RNG, loot e personalização profunda

- **Drops e afixos** em itens (raridade, modificadores).
- **Medidores de qualidade em todo item** (matérias-primas, produtos, armas,
  equipamentos) com stacks heterogêneos — princípio firme em `03-modulos.md` §Items;
  a fase entrega as fontes de qualidade além da fonte/crafter (afixos, raridade).
- **Refino customizado por material** (refinaria pesquisada para aquele material, com
  custos de tempo/água/combustível/etc.) e **blueprints** derivados de pesquisa
  customizada.
- Personalização de equipamentos, remessa e layouts de fábrica.
- **Progressão do corpo do jogador:** equipamento pessoal, **implantes** (caminho David
  Martinez), **mudança de corpo**, **upload de mente → virar um robô**; veículos e
  **mechas**. Serve à meta de divergência extrema entre playthroughs (`01-visao.md`).
- Catálogo grande de itens construído sobre o sistema data-driven.

## Fase 7 — Múltiplos sistemas → galáxia

- Galáxia completa com dezenas/centenas de sistemas procedurais.
- Navegação de mapa estelar (cena 3D da galáxia, nível de zoom da Fase 2 expandido),
  combustível, distância como custo real.

## Fase 8 — Universo

- Galáxias procedurais ligadas (nível de zoom do aglomerado de galáxias);
  expansão contínua do universo conforme exploração.
- Otimizações sérias de streaming de mundo e save.

---

## Gestão de risco

| Risco | Mitigação |
|---|---|
| Escopo explodir (o "universo" é grande) | MVP minúsculo + fases com critérios de saída claros |
| Performance (simulação de fábrica grande) | Arquitetura com simulação separada e testes de carga desde a Fase 2 |
| Engine errada | Decisão barata de reverter: lógica de jogo isolada da engine (`docs/04-tech.md`) |
| Linux de segunda classe | CI testando no Linux desde a Fase 0 |
