# 02 · Obsidian

O Obsidian é a tela do sistema: não correlaciona nada sozinho, só mostra os links que o agente escreve. Estas configurações fazem a captura cair no lugar certo e deixam a wiki muito mais legível.

---

## Configurações do vault

**Engrenagem** (canto inferior esquerdo) → **Files and links**:

| Opção | Valor | Por quê |
| --- | --- | --- |
| Default location for new notes | In the folder specified below → `inbox` | Ideias novas passam pela triagem |
| Default location for new attachments | In the folder specified below → `raw/assets` | Imagens ficam junto das fontes |
| New link format | Path from vault folder | Links no formato `[[sources/slug]]`, igual ao do agente |
| Automatically update internal links | Ligado | Renomear não quebra links |
| Use [[Wikilinks]] | Ligado | Formato que o agente usa |

O Obsidian salva sozinho. Cada vault tem configurações próprias: repita isso em cada vault novo.

---

## Web Clipper

A extensão salva **o conteúdo da página** como nota, com a URL registrada no topo.

### Instalar

1. Em [obsidian.md/clipper](https://obsidian.md/clipper), clique em **Get for Chrome**.
2. Ícone de quebra-cabeça do Chrome → **alfinete** ao lado do Obsidian Web Clipper.

### Configurar (uma vez)

Botão direito no ícone do Clipper → **Options**:

1. **General → Vaults:** digite o nome do vault **exatamente** como aparece no Obsidian (maiúsculas importam) e pressione **Enter**.
2. **Templates → Default:**
   - **Note location:** troque `Clippings` por `inbox`.
   - **Vault:** escolha o seu vault (não deixe em *Last used* se você tiver mais de um).

### Capturar

1. Abra a página no Chrome.
2. Clique no ícone do Clipper, ou use **⌥ ⇧ O** para captura rápida.
3. **Confira o rodapé da janela** antes de salvar: vault e pasta. É o rodapé que vale.
4. **Add to Obsidian**.

> [!WARNING]
> Se aparecer uma pasta `Clippings/` na raiz do vault, o template ainda está com o destino padrão. Peça ao agente: *"Mova o conteúdo de Clippings/ para inbox/ e rode a /triagem"* e corrija o template.

### Quando o Clipper não serve

| Caso | Use |
| --- | --- |
| PDF | **⌘ S** no navegador, salvando em `inbox` |
| Vídeo | A transcrição, salva em `inbox` com título e URL |
| Muitos links | `/baixar` no agente |
| Página com login | O Clipper funciona (usa a sua sessão); o `/baixar` não |

---

## Grafo legível

**⌘ G** abre o Graph view. Na engrenagem do grafo:

- **Filters:** `path:wiki` (esconde `raw/` e `inbox/`).
- **Groups → New group**, uma cor para cada:

```text
path:wiki/sources     fontes
path:wiki/concepts    conceitos
path:wiki/syntheses   sínteses
path:wiki/entities    entidades
```

Dentro de qualquer página, **⋯ → Open local graph** mostra só as conexões dela.

---

## Painéis com Bases

O **Bases** (nativo do Obsidian) transforma as páginas em tabelas filtráveis usando os metadados do topo. Peça ao agente:

```text
Crie wiki/painel.base no formato Bases do Obsidian com quatro
visualizações: fontes agrupadas por domínio com confiança; páginas
com status needs-review; conceitos ordenados pelo número de fontes;
sínteses mais recentes. Commit schema.
```

---

## Página inicial com mapa

```text
Crie wiki/home.md com um diagrama Mermaid dos conceitos principais e
suas ligações, as 3 tensões em aberto mais importantes, as perguntas
em aberto e links para o painel e as últimas sínteses. Atualize essa
página sempre que rodar o LINT. Commit schema.
```

O Obsidian desenha Mermaid nativamente. Em **Settings → General → Default file to open**, escolha `wiki/home.md`.

---

## Plugins de IA

Plugins que colocam um chat dentro do Obsidian costumam enviar as notas para serviços externos, o que conflita com a regra de privacidade do `CLAUDE.md`. O Claude Code já cumpre esse papel, com as suas regras. Se instalar algum, verifique antes para onde ele envia o conteúdo.
