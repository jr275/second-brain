# 01 · Instalação

Do zero à primeira ingestão em cerca de 1h30. O tempo maior vai para as três primeiras fontes, e é assim que deve ser.

- [Antes de começar](#antes-de-começar)
- [Passo 1 · Instalar as ferramentas](#passo-1--instalar-as-ferramentas)
- [Passo 2 · Criar o vault](#passo-2--criar-o-vault)
- [Passo 3 · Abrir no Obsidian](#passo-3--abrir-no-obsidian)
- [Passo 4 · Revisar o contrato com o agente](#passo-4--revisar-o-contrato-com-o-agente)
- [Passo 5 · As três primeiras fontes](#passo-5--as-três-primeiras-fontes)
- [Passo 6 · Validar](#passo-6--validar)

---

## Antes de começar

### Três decisões

1. **Pessoal é separado de empresa.** Este vault é para o seu conhecimento. Material de clientes ou da empresa vai para um vault separado (basta rodar o instalador com outro `--path`).
2. **O vault fica fora de pastas sincronizadas.** No Mac, `Documentos` e `Mesa` costumam estar no iCloud. A sincronização em tempo real disputa arquivos com o Git e com o agente. Use `~/SecondBrain`.
3. **Você participa de toda ingestão.** O agente para e discute antes de escrever. É o que mantém você aprendendo.

### Duas noções de Terminal

| Você vê | Onde está | O que digitar |
| --- | --- | --- |
| `joao@mac SecondBrain %` | Terminal comum | Comandos: `cd`, `ls`, `git` |
| `❯` | Claude Code | Pedidos em português e comandos `/ingest`, `/query`... |

Para rodar um comando de Terminal sem sair do Claude Code, coloque `!` na frente:

```text
❯ ! git log --oneline
```

> [!TIP]
> Viu `zsh: command not found`? Um pedido em português foi colado no Terminal comum. Nada quebrou: abra o Claude Code com `claude --continue` e cole de novo.

---

## Passo 1 · Instalar as ferramentas

**Obsidian:** baixe em [obsidian.md](https://obsidian.md) e instale.

**Claude Code:**

```bash
curl -fsSL https://claude.ai/install.sh | bash
claude --version
```

Se você já tinha a versão instalada pelo npm, migre para a nativa, que se atualiza sozinha:

```bash
claude install
```

**Leitor de PDF** (permite citar papers com número de página; exige [Homebrew](https://brew.sh)):

```bash
brew install poppler
```

**Git:** já vem no Mac. Se aparecer um pedido para instalar as *Command Line Developer Tools*, aceite. Configure seu nome uma vez:

```bash
git config --global user.name "Seu Nome"
git config --global user.email "voce@exemplo.com"
```

---

## Passo 2 · Criar o vault

```bash
git clone https://github.com/jr275/second-brain.git
cd second-brain
./install.sh --theme "Seu tema âncora"
```

O tema âncora é o assunto central da wiki nos primeiros meses. Um tema focado gera muito mais conexões do que uma wiki sobre tudo. Exemplos: `"Inteligência Artificial"`, `"Mercado Financeiro"`, `"Biologia Sintética"`.

O instalador cria:

```text
~/SecondBrain
├── CLAUDE.md
├── .claude/commands/   8 comandos
├── .gitignore          raw/ e inbox/ fora do Git
├── inbox/
├── raw/{articles,papers,books,transcripts,notes,assets}/
└── wiki/{sources,concepts,entities,syntheses}/ + index.md + log.md
```

e faz o commit `bootstrap`.

---

## Passo 3 · Abrir no Obsidian

1. No Obsidian, clique no nome do vault no canto inferior esquerdo → **Manage vaults…**
2. Ao lado de **Open folder as vault**, clique em **Open**.
3. Pressione **⌘ ⇧ H** (vai para a sua pasta de usuário), selecione `SecondBrain` e clique em **Open**.

Depois, configure o Obsidian e o Web Clipper seguindo **[02 · Obsidian](02-obsidian.md)**. São 5 minutos e evitam os erros mais comuns.

---

## Passo 4 · Revisar o contrato com o agente

```bash
cd ~/SecondBrain && claude
```

Se ele perguntar se você confia nos arquivos da pasta, escolha **Yes**. Na linha do `❯`, peça:

```text
Leia o CLAUDE.md, os comandos em .claude/commands/ e o idea file
original em https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

Explique como uma fonte será processada, como as citações funcionam,
como você vai evitar alucinações e como eu participo de cada
ingestão. Aponte o que você ajustaria no CLAUDE.md para o meu tema.
Não altere nada ainda.
```

Ajustes no `CLAUDE.md` são feitos sempre com a sua aprovação, em commits `schema:`.

---

## Passo 5 · As três primeiras fontes

Comece com **três fontes sobre o mesmo tema**: o mínimo para as conexões aparecerem. Uma boa combinação é um paper, um artigo de análise e um texto seu.

### Capturar

| Tipo | Como |
| --- | --- |
| Artigo da web | Web Clipper → confira o rodapé (`inbox`) → **Add to Obsidian** |
| PDF | No navegador, **⌘ S** → **⌘ ⇧ G** → `~/SecondBrain/inbox` → Salvar |
| Texto seu | No Obsidian, **⌘ N** (a nota já nasce em `inbox`) |
| Lista de links | No agente: `/baixar https://... https://...` |

### Triar

```text
❯ /triagem
```

O agente mostra uma tabela com o destino proposto para cada arquivo. Responda `aprovado` ou ajuste.

### Ingerir

```text
❯ /ingest
```

Ele lista as fontes pendentes e começa pela primeira:

1. Apresenta os achados centrais, a metodologia e as limitações, e **para**.
2. Você pergunta. Três perguntas que funcionam bem:
   - *Qual é o achado mais fraco e por quê?*
   - *O que aqui contradiz o senso comum?*
   - *Como isso se aplica ao meu trabalho?*
3. Você responde `pode integrar`.
4. Ele escreve as páginas e faz o commit `ingest:`.

Para textos seus, dê contexto numa frase:

```text
Esta é uma nota minha: trate as afirmações como teses minhas e
confronte com as fontes.
```

---

## Passo 6 · Validar

```text
❯ /query Como estas três fontes se conectam? Onde há tensão entre elas?
```

Depois:

- No Obsidian, abra o **Graph view** (**⌘ G**): as fontes devem estar ligadas por conceitos em comum.
- Abra uma página de fonte e confira se as afirmações têm citação com página e se as interpretações do agente estão marcadas.
- No Terminal comum, rode o diagnóstico:

```bash
./scripts/doctor.sh --path ~/SecondBrain
```

✅ **Pronto quando** a resposta do `/query` traz uma conexão que você não tinha percebido, o grafo mostra as fontes ligadas e o `git log` tem um commit `ingest:` por fonte.

Próximo: **[03 · Rotina](03-rotina.md)**.
