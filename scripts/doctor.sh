#!/usr/bin/env bash
#
# Second Brain — diagnóstico
#
# Verifica a saúde do vault sem alterar nada: estrutura, dependências,
# fila de triagem, fontes pendentes, integridade (sha256) das fontes
# ingeridas, possíveis credenciais expostas e estado do Git.
#
# Uso:
#   ./scripts/doctor.sh [--path DIR]
#
set -euo pipefail

VAULT="${HOME}/SecondBrain"

if [[ -t 1 ]]; then
  readonly BOLD=$'\e[1m' DIM=$'\e[2m' RED=$'\e[31m' GREEN=$'\e[32m'
  readonly YELLOW=$'\e[33m' RESET=$'\e[0m'
else
  readonly BOLD="" DIM="" RED="" GREEN="" YELLOW="" RESET=""
fi

ISSUES=0
WARNINGS=0

title() { printf '\n%s%s%s\n' "$BOLD" "$*" "$RESET"; }
ok()    { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn()  { printf '  %s!%s %s\n' "$YELLOW" "$RESET" "$*"; WARNINGS=$((WARNINGS + 1)); }
bad()   { printf '  %s✗%s %s\n' "$RED" "$RESET" "$*"; ISSUES=$((ISSUES + 1)); }
note()  { printf '      %s%s%s\n' "$DIM" "$*" "$RESET"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path) VAULT="${2:?--path precisa de um diretório}"; shift 2 ;;
    -h|--help) echo "Uso: $0 [--path DIR]"; exit 0 ;;
    *) echo "Opção desconhecida: $1" >&2; exit 2 ;;
  esac
done

VAULT="${VAULT/#\~/$HOME}"
[[ -d "$VAULT" ]] || { echo "Vault não encontrado: $VAULT" >&2; exit 2; }
cd "$VAULT"

sha256() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

# Lê o valor de um campo do frontmatter YAML (primeira ocorrência).
frontmatter_field() {
  local field="$1" file="$2"
  awk -v key="$field" '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---"  { exit }
    $0 ~ "^" key ":" {
      sub("^" key ":[[:space:]]*", "")
      sub("[[:space:]]+#.*$", "")
      gsub(/^["'\'']|["'\'']$/, "")
      print; exit
    }' "$file"
}

check_structure() {
  title "Estrutura"
  local missing=0 path
  for path in CLAUDE.md inbox raw/notes wiki/sources wiki/index.md wiki/log.md .claude/commands; do
    if [[ ! -e "$path" ]]; then
      bad "faltando: $path"
      missing=1
    fi
  done
  [[ "$missing" -eq 0 ]] && ok "estrutura completa"

  if [[ -d Clippings ]]; then
    warn "existe uma pasta Clippings/: o Web Clipper está salvando fora do inbox"
    note "Ajuste: Options → Templates → Default → Note location: inbox"
  fi

  local commands
  commands="$(find .claude/commands -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
  ok "${commands} comandos do agente"
}

check_dependencies() {
  title "Dependências"
  local tool
  for tool in git claude pdftotext; do
    if command -v "$tool" >/dev/null 2>&1; then
      ok "$tool"
    else
      warn "$tool não encontrado"
    fi
  done
}

check_inbox() {
  title "Caixa de entrada"
  local count
  count="$(find inbox -type f ! -name '.DS_Store' ! -path 'inbox/quarentena/*' 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$count" -eq 0 ]]; then
    ok "inbox vazio"
  else
    warn "${count} arquivo(s) aguardando triagem: rode /triagem"
  fi

  if [[ -d inbox/quarentena ]] && [[ -n "$(find inbox/quarentena -type f ! -name '.DS_Store' 2>/dev/null)" ]]; then
    warn "há arquivos em quarentena: decida o destino e tire-os do vault"
  fi
}

check_sources() {
  title "Fontes"
  local ingested=0 pending=0 file rel

  # Fontes pendentes: arquivos em raw/ que nenhuma página referencia.
  while IFS= read -r -d '' file; do
    rel="${file#./}"
    if grep -rqF -- "$rel" wiki/sources 2>/dev/null; then
      ingested=$((ingested + 1))
    else
      pending=$((pending + 1))
      [[ "$pending" -le 10 ]] && note "pendente: $rel"
    fi
  done < <(find ./raw -type f ! -path './raw/assets/*' ! -name '.DS_Store' -print0 2>/dev/null)

  ok "${ingested} fonte(s) ingerida(s)"
  [[ "$pending" -gt 0 ]] && warn "${pending} fonte(s) pendente(s) em raw/: rode /ingest"
  return 0
}

check_integrity() {
  title "Integridade (sha256)"
  local page raw expected actual checked=0
  shopt -s nullglob
  for page in wiki/sources/*.md; do
    raw="$(frontmatter_field raw "$page")"
    expected="$(frontmatter_field sha256 "$page")"
    [[ -n "$raw" && -n "$expected" ]] || continue
    checked=$((checked + 1))

    if [[ ! -f "$raw" ]]; then
      bad "$(basename "$page"): arquivo de origem sumiu ($raw)"
      continue
    fi
    actual="$(sha256 "$raw")"
    if [[ "$actual" != "$expected"* ]]; then
      bad "$(basename "$page"): sha256 não bate com $raw"
    fi
  done
  shopt -u nullglob

  if [[ "$checked" -eq 0 ]]; then
    ok "nenhuma fonte com sha256 registrado ainda"
  else
    ok "${checked} fonte(s) verificada(s)"
  fi
}

check_secrets() {
  title "Credenciais expostas"
  local pattern='(sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|BEGIN [A-Z ]*PRIVATE KEY|api[_-]?key[[:space:]]*[:=]|senha[[:space:]]*[:=]|password[[:space:]]*[:=])'
  local hits
  hits="$(grep -rIlEi --exclude-dir=.git --exclude-dir=.obsidian -- "$pattern" inbox raw wiki 2>/dev/null || true)"
  if [[ -z "$hits" ]]; then
    ok "nenhum padrão de credencial encontrado"
  else
    bad "possíveis credenciais nestes arquivos (conteúdo não exibido):"
    while IFS= read -r file; do note "$file"; done <<<"$hits"
    note "Tire-os do vault e troque as credenciais."
  fi
}

check_git() {
  title "Git"
  if [[ ! -d .git ]]; then
    bad "o vault não é um repositório Git"
    return
  fi
  local last
  last="$(git log -1 --format='%h %s' 2>/dev/null || true)"
  [[ -n "$last" ]] && ok "último commit: $last"

  if [[ -z "$(git status --porcelain 2>/dev/null)" ]]; then
    ok "nada pendente de commit"
  else
    warn "há alterações não commitadas (edições suas ou operação interrompida)"
    git status --short | head -5 | while IFS= read -r line; do note "$line"; done
  fi
}

main() {
  printf '%sSecond Brain · diagnóstico%s  %s%s%s\n' "$BOLD" "$RESET" "$DIM" "$VAULT" "$RESET"
  check_structure
  check_dependencies
  check_inbox
  check_sources
  check_integrity
  check_secrets
  check_git

  title "Resumo"
  if [[ "$ISSUES" -eq 0 && "$WARNINGS" -eq 0 ]]; then
    ok "tudo em ordem"
  else
    printf '  %s%d problema(s)%s · %s%d aviso(s)%s\n' "$RED" "$ISSUES" "$RESET" "$YELLOW" "$WARNINGS" "$RESET"
  fi
  [[ "$ISSUES" -eq 0 ]]
}

main
