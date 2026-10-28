# Simplicity — O pitch

## A frase de efeito

> **Factorio, No Man's Sky, EVE Online e Cyberpunk entraram num carro. O carro tinha
> motor próprio. O destino era um universo inteiro.**

Simplicity é um jogo espacial de **fábricas, exploração e transformação** — do planeta
sob os seus pés até o seu próprio corpo. Você começa minerando ferro. Semanas depois,
pode ser um homem-robô com implantes de guerra comandando uma linha de artilharia
bípede a partir de um cargueiro que você restaurou depois de encontrá-lo caído num
deserto de um planeta que ninguém jamais viu — porque ele foi gerado por uma seed que
só existe no SEU universo.

## Como se joga (o loop que se fecha sozinho)

1. **Pousa** num planeta procedural. Minera. Seta uma primeira fábrica tosca.
2. **Automatiza.** A fábrica cresce, e ela passa a fabricar o que sua exploração precisa.
3. **Explora.** O espaço é 3D estilo EVE Online: órbita, warp, câmera livre. Acha naves
   caídas, estações infectadas, sinais de socorro, mercadores ambulantes, criaturas
   espaciais para caçar.
4. **Aprende.** A pesquisa não se compra — se **alimenta do que você achou lá fora**.
   (E a fonte de "poder de pensar" pode ser um cientista recrutado... ou um deus
   cósmico aprisionado sendo usado como processador.)
5. **Evolui.** A tech tree abre caminhos de máquina **misturáveis**: nuclear, industrial
   poluente, technobiologia (máquinas vivas), sustentável/terraformação, planta-máquina...
6. **Transforma.** O planeta (poluição tem consequência — e pode jogar a favor), a sua
   nave (com interior editável e tripulação), e o **próprio corpo** (implantes, mudança
   de corpo, upload de mente — virar um robô. O que impede, né?).
7. **Repete, mais longe.** Sistema novo, galáxia nova, universo novo.

## O que tem dentro

- **Fábricas de verdade, estilo Factorio** — esteiras, máquinas, design livre; o
  "blueprint" é seu.
- **Um universo procedural em camadas** — aglomerado de galáxias → galáxia → sistema →
  planeta 3D navegável → superfície em construção livre 3D. Tudo por seed: compartilhe a seed,
  compartilhe o universo.
- **Caminhos de máquina com estética e mecânica próprias** — e consequências reais:
  poluição que muda o planeta e derruba sua tripulação... a menos que você aprenda a
  *usar* a poluição. Lixo radioativo que precisa ir embora — pra onde, é problema seu.
- **Economia de itens no padrão EVE Online** — blueprints originais (BPO) infinitas, cópias (BPC) com usos limitados, eficiência de material/tempo pesquisável, produção complexa multi-estágio e um catálogo gigante; e blueprints customizadas que, um dia, até se vendem.
- **Qualidade em tudo** — do minério bruto à arma na sua mão. Stacks que mostram
  honestamente o que contêm. Um crafter ruim desperdiça, falha, e em serviço perigoso
  pode até morrer (não é pra crafter bom morrer à toa, combinado).
- **Tripulação em duas classes** — Especialistas com traits e níveis, e Trabalhadores
  aos milhares. Sua nave tem interiores editáveis e gente de verdade operando ela.
- **Corpo como fronteira aberta** — de equipamento de exploração a mecha a bombardeio
  orbital. De implante a upload de consciência.

## A meta que resume tudo

> No jogo pronto, dois jogadores com universos diferentes deveriam poder terminar assim:
> **um deles transformou a si mesmo num superman que voa e atira laser pelos olhos;
> o outro construiu um exército de ciborgues e uma linha de artilharia bípede.**
> Se os dois saves chegarem parecidos, o design falhou.

## Técnico, rapidinho

- **Híbrido 3D + vistas focadas:** espaço em 3D leve estilo EVE; superfícies planetárias
  em construção livre 3D (estilo NMS/DSP); interiores de nave e combate em solo em
  vistas focadas (2D top-down ou 3D local — decisão futura). A simulação pesada (a
  fábrica!) roda num núcleo próprio, desacoplado da engine.
- **Godot 4**, open source. **Linux (Arch, Ubuntu) e Windows** como plataformas de
  primeira classe, desde o primeiro dia.
- Meta de hardware: **PC mediano**. O universo é função da seed, não um arquivo gigante.

## Status

- ✅ Visão, pilares, arquitetura em módulos e roadmap por fases — documentados.
- 🔧 Próxima parada: prototipar a superfície (o coração) — construção livre 3D no
  terreno, mineração, primeira esteira, primeiro forno.
- 🚀 Depois: o resto do universo. Literalmente.
