#!/usr/bin/env bash
#
# Second Brain — instalador
#
# Cria um vault de conhecimento no padrão LLM Wiki (Karpathy):
# estrutura de pastas, CLAUDE.md, comandos do Claude Code, wiki inicial
# e repositório Git. Não sobrescreve arquivos existentes sem --force.
#
# Uso:
#   ./install.sh [--path DIR] [--theme "TEMA"] [--force] [--no-commit]
#
set -euo pipefail

readonly VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly TEMPLATES="${SCRIPT_DIR}/templates/vault"

VAULT="${HOME}/SecondBrain"
THEME="AI, Agents & Knowledge Engineering"
FORCE=0
COMMIT=1

# ── Saída ────────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
  readonly BOLD=$'\e[1m' DIM=$'\e[2m' RED=$'\e[31m' GREEN=$'\e[32m'
  readonly YELLOW=$'\e[33m' BLUE=$'\e[34m' RESET=$'\e[0m'
else
  readonly BOLD="" DIM="" RED="" GREEN="" YELLOW="" BLUE="" RESET=""
fi

title() { printf '\n%s%s%s\n' "$BOLD" "$*" "$RESET"; }
info()  { printf '  %s→%s %s\n' "$BLUE" "$RESET" "$*"; }
ok()    { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn()  { printf '  %s!%s %s\n' "$YELLOW" "$RESET" "$*"; }
die()   { printf '  %s✗%s %s\n' "$RED" "$RESET" "$*" >&2; exit 1; }

usage() {
  cat <<EOF
${BOLD}Second Brain${RESET} — instalador v${VERSION}

Uso:
  ./install.sh [opções]

Opções:
  --path DIR      Onde criar o vault (padrão: ~/SecondBrain)
  --theme "TEMA"  Tema âncora da wiki (padrão: "${THEME}")
  --force         Sobrescreve arquivos de template já existentes
  --no-commit     Não faz o commit inicial "bootstrap"
  -h, --help      Mostra esta ajuda
  -v, --version   Mostra a versão
EOF
}

# ── Argumentos ───────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path)      VAULT="${2:?--path precisa de um diretório}"; shift 2 ;;
    --theme)     THEME="${2:?--theme precisa de um texto}"; shift 2 ;;
    --force)     FORCE=1; shift ;;
    --no-commit) COMMIT=0; shift ;;
    -h|--help)   usage; exit 0 ;;
    -v|--version) echo "$VERSION"; exit 0 ;;
    *)           usage; die "Opção desconhecida: $1" ;;
  esac
done

VAULT="${VAULT/#\~/$HOME}"

# ── Verificações ─────────────────────────────────────────────────────

check_environment() {
  title "1. Verificando o ambiente"

  [[ -d "$TEMPLATES" ]] || die "Templates não encontrados em $TEMPLATES"

  if [[ "$(uname -s)" == "Darwin" ]]; then
    ok "macOS"
  else
    warn "Sistema não é macOS: os passos funcionam, mas o guia usa atalhos do Mac"
  fi

  command -v git >/dev/null 2>&1 \
    || die "Git não encontrado. No Mac: xcode-select --install"
  ok "git $(git --version | awk '{print $3}')"

  if command -v claude >/dev/null 2>&1; then
    ok "Claude Code instalado"
  else
    warn "Claude Code não encontrado. Instale com:"
    printf '      %scurl -fsSL https://claude.ai/install.sh | bash%s\n' "$DIM" "$RESET"
  fi

  if command -v pdftotext >/dev/null 2>&1; then
    ok "pdftotext (poppler) instalado"
  else
    warn "pdftotext não encontrado: citações de PDF sairão por seção, não por página"
    printf '      %sbrew install poppler%s\n' "$DIM" "$RESET"
  fi

  case "$VAULT" in
    "$HOME/Documents"*|"$HOME/Desktop"*|*"Mobile Documents"*|*"CloudStorage"*)
      warn "O vault está numa pasta que costuma ser sincronizada (iCloud, Dropbox)."
      warn "Sincronização em tempo real conflita com o Git e com o agente."
      warn "Recomendado: --path ~/SecondBrain"
      ;;
  esac
}

# ── Instalação ───────────────────────────────────────────────────────

readonly DIRECTORIES=(
  inbox
  raw/articles raw/papers raw/books raw/transcripts raw/notes raw/assets
  wiki/sources wiki/concepts wiki/entities wiki/syntheses
  .claude/commands
)

create_directories() {
  title "2. Criando a estrutura em ${VAULT}"
  local dir
  for dir in "${DIRECTORIES[@]}"; do
    mkdir -p "${VAULT}/${dir}"
  done
  ok "${#DIRECTORIES[@]} pastas prontas"
}

# Copia um template, substituindo os marcadores. Respeita arquivos
# existentes, a menos que --force tenha sido usado.
install_file() {
  local src="$1" dest="$2"
  local today
  today="$(date +%Y-%m-%d)"

  if [[ -e "$dest" && "$FORCE" -eq 0 ]]; then
    info "mantido: ${dest#"$VAULT"/}"
    return
  fi

  local content
  content="$(<"$src")"
  content="${content//\{\{TEMA_ANCORA\}\}/$THEME}"
  content="${content//\{\{DATA\}\}/$today}"
  printf '%s\n' "$content" >"$dest"
  ok "criado: ${dest#"$VAULT"/}"
}

install_templates() {
  title "3. Instalando regras, comandos e wiki inicial"

  install_file "${TEMPLATES}/CLAUDE.md"          "${VAULT}/CLAUDE.md"
  install_file "${TEMPLATES}/gitignore.template" "${VAULT}/.gitignore"
  install_file "${TEMPLATES}/wiki/index.md"      "${VAULT}/wiki/index.md"
  install_file "${TEMPLATES}/wiki/log.md"        "${VAULT}/wiki/log.md"

  local cmd
  for cmd in "${TEMPLATES}"/.claude/commands/*.md; do
    install_file "$cmd" "${VAULT}/.claude/commands/$(basename "$cmd")"
  done
}

init_git() {
  title "4. Versionamento"

  if [[ -d "${VAULT}/.git" ]]; then
    info "repositório Git já existe"
  else
    git -C "$VAULT" init --quiet
    ok "repositório Git criado"
  fi

  [[ "$COMMIT" -eq 1 ]] || { info "commit inicial pulado (--no-commit)"; return; }

  if git -C "$VAULT" rev-parse --verify HEAD >/dev/null 2>&1; then
    info "o vault já tem commits; nada a fazer"
    return
  fi

  git -C "$VAULT" add -A
  if git -C "$VAULT" commit --quiet -m "bootstrap: estrutura inicial do second brain" 2>/dev/null; then
    ok "commit \"bootstrap\" criado"
  else
    warn "não foi possível fazer o commit (configure seu nome e e-mail no Git):"
    printf '      %sgit config --global user.name "Seu Nome"%s\n' "$DIM" "$RESET"
    printf '      %sgit config --global user.email "voce@exemplo.com"%s\n' "$DIM" "$RESET"
  fi
}

next_steps() {
  title "Pronto. Próximos passos:"
  cat <<EOF

  1. No Obsidian: ${BOLD}Manage vaults → Open folder as vault${RESET} → ${VAULT}
  2. Configure o Obsidian e o Web Clipper (docs/02-obsidian.md)
  3. Abra o agente no vault:

       ${GREEN}cd "${VAULT}" && claude${RESET}

  4. Capture três fontes sobre o mesmo tema na pasta inbox/ e rode:

       ${GREEN}/triagem${RESET}   depois   ${GREEN}/ingest${RESET}

  Diagnóstico a qualquer momento: ${DIM}./scripts/doctor.sh --path "${VAULT}"${RESET}

EOF
}

main() {
  printf '%sSecond Brain%s %sv%s · padrão LLM Wiki%s\n' "$BOLD" "$RESET" "$DIM" "$VERSION" "$RESET"
  check_environment
  create_directories
  install_templates
  init_git
  next_steps
}

main "$@"
