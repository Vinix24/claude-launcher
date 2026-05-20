#!/usr/bin/env bash
# claude-launcher installer — macOS only, v0.0
#
# Voert eerlijke dependency-checks uit, biedt installatie aan waar mogelijk,
# zet ~/.claude-launcher/ tree op, symlinkt de cockpit-CLI in $PATH,
# en draait een smoke-test om te valideren dat de keten werkt.

set -euo pipefail

# ----- styling -----
if [ -t 1 ]; then
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
  C_DIM=$'\033[2m'
  C_BOLD=$'\033[1m'
  C_RESET=$'\033[0m'
else
  C_GREEN="" C_YELLOW="" C_RED="" C_DIM="" C_BOLD="" C_RESET=""
fi

ok()    { echo "${C_GREEN}[ok]${C_RESET} $*"; }
warn()  { echo "${C_YELLOW}[!] ${C_RESET} $*"; }
err()   { echo "${C_RED}[x] ${C_RESET} $*"; }
info()  { echo "${C_DIM}$*${C_RESET}"; }
step()  { echo; echo "${C_BOLD}>>> $*${C_RESET}"; }

confirm() {
  local prompt="$1"
  local default="${2:-N}"
  local answer
  if [ "$default" = "Y" ]; then
    read -r -p "$prompt [Y/n] " answer
    answer="${answer:-Y}"
  else
    read -r -p "$prompt [y/N] " answer
    answer="${answer:-N}"
  fi
  case "$answer" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

# ----- preflight -----
step "Platform-check"
if [ "$(uname -s)" != "Darwin" ]; then
  err "Dit script ondersteunt alleen macOS. Linux/Windows komt in een latere versie."
  exit 1
fi
ok "macOS gedetecteerd"

# Repo dir (waar dit script staat)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAUNCHER_HOME="${CLAUDE_LAUNCHER_HOME:-$HOME/.claude-launcher}"

step "Dependencies"

# tmux
if command -v tmux >/dev/null 2>&1; then
  ok "tmux: $(tmux -V)"
else
  warn "tmux ontbreekt. claude-launcher heeft tmux nodig om workers te draaien."
  if command -v brew >/dev/null 2>&1; then
    if confirm "Nu installeren via 'brew install tmux'?" Y; then
      brew install tmux || { err "brew install tmux faalde"; exit 1; }
      ok "tmux geïnstalleerd"
    else
      err "tmux is verplicht. Installatie afgebroken."
      exit 1
    fi
  else
    err "Homebrew niet gevonden. Installeer eerst Homebrew (brew.sh), dan opnieuw."
    exit 1
  fi
fi

# Python 3.10+
PYTHON_BIN=""
for cand in python3.13 python3.12 python3.11 python3.10 python3; do
  if command -v "$cand" >/dev/null 2>&1; then
    if "$cand" -c 'import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)' 2>/dev/null; then
      PYTHON_BIN="$cand"
      break
    fi
  fi
done
if [ -n "$PYTHON_BIN" ]; then
  ok "Python: $($PYTHON_BIN --version) at $(command -v $PYTHON_BIN)"
else
  warn "Python 3.10+ niet gevonden."
  if command -v brew >/dev/null 2>&1 && confirm "Installeren via 'brew install python'?" Y; then
    brew install python || { err "brew install python faalde"; exit 1; }
    PYTHON_BIN="python3"
    ok "Python geïnstalleerd: $($PYTHON_BIN --version)"
  else
    err "Python 3.10+ is verplicht. Zie python.org of installeer via brew."
    exit 1
  fi
fi

# Python packages
step "Python packages: python-docx, python-pptx, pyyaml"
MISSING_PKGS=()
for pkg in docx pptx yaml; do
  case "$pkg" in
    docx)  module="docx";  install="python-docx" ;;
    pptx)  module="pptx";  install="python-pptx" ;;
    yaml)  module="yaml";  install="pyyaml" ;;
  esac
  if "$PYTHON_BIN" -c "import $module" 2>/dev/null; then
    ok "$install"
  else
    MISSING_PKGS+=("$install")
  fi
done

if [ "${#MISSING_PKGS[@]}" -gt 0 ]; then
  warn "Ontbrekende packages: ${MISSING_PKGS[*]}"
  if confirm "Installeren via 'pip3 install --user ${MISSING_PKGS[*]}'?" Y; then
    "$PYTHON_BIN" -m pip install --user "${MISSING_PKGS[@]}" || {
      err "pip install faalde. Installeer handmatig: pip3 install --user ${MISSING_PKGS[*]}"
      exit 1
    }
    ok "packages geïnstalleerd"
  else
    err "Python packages zijn verplicht voor de output-skills. Installatie afgebroken."
    exit 1
  fi
fi

# claude CLI
step "Claude Code CLI"
if command -v claude >/dev/null 2>&1; then
  ok "claude: $(command -v claude)"
else
  err "Claude Code CLI ('claude') niet gevonden in PATH."
  echo
  echo "  Installatie-instructies: https://docs.anthropic.com/claude/docs/claude-code"
  echo "  Na install: log in met 'claude login', dan opnieuw './install.sh'."
  exit 1
fi

# ----- ~/.claude-launcher tree -----
step "Workspace-tree opzetten in $LAUNCHER_HOME"

if [ -d "$LAUNCHER_HOME" ]; then
  warn "$LAUNCHER_HOME bestaat al."
  if confirm "Templates overschrijven? (config + output + inbox blijven behouden)" N; then
    info "Templates worden bijgewerkt..."
  else
    info "Templates ongewijzigd. Skip naar smoke-test."
    SKIP_TEMPLATES=1
  fi
fi

mkdir -p "$LAUNCHER_HOME/inbox" "$LAUNCHER_HOME/output" "$LAUNCHER_HOME/lib"
mkdir -p "$LAUNCHER_HOME/cockpit" "$LAUNCHER_HOME/workspaces" "$LAUNCHER_HOME/skills"

if [ -z "${SKIP_TEMPLATES:-}" ]; then
  # cockpit
  cp -r "$REPO_DIR/templates/cockpit/." "$LAUNCHER_HOME/cockpit/"
  ok "cockpit templates gekopieerd naar $LAUNCHER_HOME/cockpit/"

  # workspaces
  cp -r "$REPO_DIR/templates/workspaces/." "$LAUNCHER_HOME/workspaces/"
  ok "workspaces gekopieerd naar $LAUNCHER_HOME/workspaces/"

  # cross-cutting output skills
  cp -r "$REPO_DIR/templates/skills/." "$LAUNCHER_HOME/skills/"
  ok "output skills gekopieerd naar $LAUNCHER_HOME/skills/"

  # lib (inbox.py)
  cp "$REPO_DIR/lib/inbox.py" "$LAUNCHER_HOME/lib/inbox.py"
  chmod +x "$LAUNCHER_HOME/lib/inbox.py"
  ok "lib/inbox.py geïnstalleerd"
fi

# manifest
[ -f "$LAUNCHER_HOME/manifest.json" ] || echo '{"workers": []}' > "$LAUNCHER_HOME/manifest.json"

# ----- cockpit CLI symlink -----
step "cockpit-CLI op het PATH"

SYMLINK_DIR=""
if confirm "Symlink 'cockpit' naar ~/.local/bin? (anders /usr/local/bin)" Y; then
  SYMLINK_DIR="$HOME/.local/bin"
else
  SYMLINK_DIR="/usr/local/bin"
fi

mkdir -p "$SYMLINK_DIR"
SYMLINK_PATH="$SYMLINK_DIR/cockpit"

# Kopieer ook bin/cockpit naar ~/.claude-launcher/bin/ zodat het zonder repo werkt
mkdir -p "$LAUNCHER_HOME/bin"
cp "$REPO_DIR/bin/cockpit" "$LAUNCHER_HOME/bin/cockpit"
chmod +x "$LAUNCHER_HOME/bin/cockpit"

if [ -L "$SYMLINK_PATH" ] || [ -f "$SYMLINK_PATH" ]; then
  warn "$SYMLINK_PATH bestaat al"
  if confirm "Overschrijven?" Y; then
    rm -f "$SYMLINK_PATH"
  else
    info "Symlink ongewijzigd."
    SKIP_SYMLINK=1
  fi
fi

if [ -z "${SKIP_SYMLINK:-}" ]; then
  if [ -w "$SYMLINK_DIR" ]; then
    ln -s "$LAUNCHER_HOME/bin/cockpit" "$SYMLINK_PATH"
  else
    info "Schrijf-permissie ontbreekt voor $SYMLINK_DIR, sudo nodig"
    sudo ln -s "$LAUNCHER_HOME/bin/cockpit" "$SYMLINK_PATH"
  fi
  ok "cockpit -> $SYMLINK_PATH"
fi

# PATH check
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$SYMLINK_DIR"; then
  warn "$SYMLINK_DIR staat niet in je PATH"
  echo "  Voeg deze regel toe aan ~/.zshrc of ~/.bash_profile:"
  echo "    export PATH=\"$SYMLINK_DIR:\$PATH\""
fi

# ----- smoke test -----
step "Smoke-test: end-to-end keten"

TEST_TASK_ID="install-smoketest-$$"
TEST_INBOX="$LAUNCHER_HOME/inbox/$TEST_TASK_ID.ndjson"

info "Schrijf test-events via cockpit msg..."
CLAUDE_LAUNCHER_HOME="$LAUNCHER_HOME" CLAUDE_LAUNCHER_TASK_ID="$TEST_TASK_ID" \
  "$LAUNCHER_HOME/bin/cockpit" msg status "hello world from installer" 2>/dev/null

CLAUDE_LAUNCHER_HOME="$LAUNCHER_HOME" CLAUDE_LAUNCHER_TASK_ID="$TEST_TASK_ID" \
  "$LAUNCHER_HOME/bin/cockpit" msg done "installer smoke-test passed" 2>/dev/null

if [ -f "$TEST_INBOX" ] && [ "$(wc -l < "$TEST_INBOX" | tr -d ' ')" -ge 2 ]; then
  ok "inbox-event keten werkt"
  info "  $TEST_INBOX:"
  while IFS= read -r line; do echo "    $line"; done < "$TEST_INBOX"
  rm "$TEST_INBOX"
else
  err "smoke-test faalde: geen events in $TEST_INBOX"
  exit 1
fi

# md2docx smoke test
info "Test md2docx converter..."
TEST_MD="$LAUNCHER_HOME/output/install-test.md"
TEST_DOCX="$LAUNCHER_HOME/output/install-test.docx"
cat > "$TEST_MD" <<'EOF'
# Hello

Een **test** document.

- bullet 1
- bullet 2
EOF
"$PYTHON_BIN" "$LAUNCHER_HOME/skills/output/docx/scripts/md2docx.py" "$TEST_MD" "$TEST_DOCX" >/dev/null
if [ -f "$TEST_DOCX" ]; then
  ok "md2docx werkt ($(wc -c < "$TEST_DOCX" | tr -d ' ') bytes)"
  rm "$TEST_MD" "$TEST_DOCX"
else
  err "md2docx faalde"
  exit 1
fi

# ----- summary -----
echo
echo "${C_BOLD}${C_GREEN}claude-launcher v0.0 geïnstalleerd${C_RESET}"
echo
echo "  cockpit-CLI:  $SYMLINK_PATH"
echo "  data-tree:    $LAUNCHER_HOME"
echo "  workspaces:   $LAUNCHER_HOME/workspaces"
echo "  cockpit-dir:  $LAUNCHER_HOME/cockpit"
echo
echo "${C_BOLD}Volgende stappen:${C_RESET}"
echo "  1. Open je brand-voice in een editor:"
echo "       \$EDITOR $LAUNCHER_HOME/workspaces/marketing/brand-voice.md"
echo "  2. Start de cockpit:"
echo "       cockpit start"
echo "  3. (optioneel) zet inbox-polling aan in de cockpit:"
echo "       /loop 60 /cockpit-monitor"
echo
echo "Documentatie: $REPO_DIR/README.md"
echo "Probleem of bug? https://github.com/Vinix24/claude-launcher/issues"
