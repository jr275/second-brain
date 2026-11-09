# 04 · Solução de problemas

Todos estes casos aconteceram num setup real. Nenhum causa estrago permanente, e quase tudo na wiki pode ser desfeito pelo Git.

> [!TIP]
> Regra geral: descreva o problema ao próprio agente e peça um diagnóstico antes de qualquer correção. Para um retrato completo do vault, rode `./scripts/doctor.sh`.

## Terminal e Claude Code

| Sintoma | Causa | Solução |
| --- | --- | --- |
| `zsh: command not found` ao colar um pedido | O pedido foi colado no Terminal comum (`%`), não no Claude Code (`❯`) | `cd ~/SecondBrain && claude --continue` e cole na linha do `❯` |
| O agente diz que não pode abrir outro vault | O comando `claude` foi digitado dentro de uma sessão | Abra uma aba nova do Terminal (**⌘ T**) para cada vault |
| A mensagem não é enviada | Um menu de sugestões de comando estava aberto | Pressione **Enter** de novo |
| O agente diz que a mensagem é repetida | O texto foi colado duas vezes | Cole uma vez, **Enter** uma vez, espere a resposta |

## Arquivos

| Sintoma | Causa | Solução |
| --- | --- | --- |
| Arquivo criado com o próprio comando dentro, ou vazio | Copiar o comando do chat substituiu o conteúdo copiado antes | Evite `pbpaste` com textos longos: salve pelo Obsidian (**⌘ N** e cole) ou baixe o arquivo pronto |
| Texto colado aparece na página errada da wiki | A nota aberta no Obsidian não era a pretendida | Confira o caminho no topo da nota antes de colar; peça ao agente: *"mostre o git diff e desfaça com git checkout"* |
| Heredoc (`cat <<EOF`) embaralha no Terminal | Colagem de blocos longos é instável | Peça ao agente para criar o arquivo |

## Captura

| Sintoma | Causa | Solução |
| --- | --- | --- |
| Capturas numa pasta `Clippings/` | Template do Clipper com o destino padrão | `Note location: inbox` e confira o rodapé |
| Capturas no vault errado | Template em *Last used* com vários vaults | Fixe o vault no template |
| Captura de PDF vazia | O Clipper não lê PDF | **⌘ S** direto no `inbox` |
| `/triagem` diz que não há nada | Os arquivos estão fora do `inbox/` | `! ls inbox Clippings` para localizar |

## Ingestão

| Sintoma | Causa | Solução |
| --- | --- | --- |
| Perguntas demais a cada ingest | Faltam padrões | Peça para registrar suas respostas na seção "Padrões de ingestão" do `CLAUDE.md` |
| Fontes viram ilhas no grafo | Temas muito diferentes | Concentre as primeiras 20 fontes no tema âncora |
| `/query` responde bem mas sem links | O agente usou conhecimento próprio | Trate como "a wiki não sabe" e peça as fontes |
| Hipótese aparece como fato | Rótulos não aplicados | Peça correção e marque a página como `needs-review` |
| PDF lido com dificuldade | Falta o `pdftotext` | `brew install poppler` |
| sha256 não bate | Arquivo em `raw/` alterado ou hash registrado errado | O lint só reporta; decida qual dos dois está certo |
