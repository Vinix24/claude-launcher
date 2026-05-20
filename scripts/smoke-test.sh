#!/usr/bin/env bash
# scripts/smoke-test.sh — end-to-end test van claude-launcher v0.0
#
# Test in volgorde:
#   1. cockpit help werkt
#   2. cockpit msg keten produceert valide NDJSON
#   3. md2docx converter maakt valide .docx
#   4. outline2pptx converter maakt valide .pptx
#   5. install.sh smoke-test (in een sandbox $HOME)
#
# Loopt zonder Claude Code te starten — geen API-calls, geen tmux.
# Geschikt voor CI en lokale verificatie.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SANDBOX="$(mktemp -d -t claude-launcher-smoke-XXX)"
trap 'rm -rf "$SANDBOX"' EXIT

if [ -t 1 ]; then
  C_GREEN=$'\033[32m'; C_RED=$'\033[31m'; C_DIM=$'\033[2m'; C_RESET=$'\033[0m'
else
  C_GREEN="" C_RED="" C_DIM="" C_RESET=""
fi
pass() { echo "${C_GREEN}[pass]${C_RESET} $*"; }
fail() { echo "${C_RED}[fail]${C_RESET} $*"; exit 1; }
info() { echo "${C_DIM}$*${C_RESET}"; }

echo "Sandbox: $SANDBOX"
echo

# ----- 1. cockpit help -----
info "1. cockpit help"
"$REPO_DIR/bin/cockpit" help >/dev/null || fail "cockpit help error"
pass "cockpit help werkt"

# ----- 2. cockpit msg keten -----
info "2. cockpit msg NDJSON keten"
export CLAUDE_LAUNCHER_HOME="$SANDBOX/claude-launcher"
export CLAUDE_LAUNCHER_TASK_ID="smoke-$$"
mkdir -p "$CLAUDE_LAUNCHER_HOME/inbox" "$CLAUDE_LAUNCHER_HOME/output" "$CLAUDE_LAUNCHER_HOME/lib"
cp "$REPO_DIR/lib/inbox.py" "$CLAUDE_LAUNCHER_HOME/lib/inbox.py"

"$REPO_DIR/bin/cockpit" msg status "test status" 2>/dev/null
"$REPO_DIR/bin/cockpit" msg question "test question?" --options "a,b" 2>/dev/null
echo "deliver-content" > "$CLAUDE_LAUNCHER_HOME/output/deliver-test.md"
"$REPO_DIR/bin/cockpit" msg deliver "deliver-test.md" --format markdown 2>/dev/null
"$REPO_DIR/bin/cockpit" msg done "all clear" 2>/dev/null
"$REPO_DIR/bin/cockpit" msg error "test error" --blocking 2>/dev/null

INBOX_FILE="$CLAUDE_LAUNCHER_HOME/inbox/$CLAUDE_LAUNCHER_TASK_ID.ndjson"
[ -f "$INBOX_FILE" ] || fail "inbox file ontbreekt: $INBOX_FILE"

LINE_COUNT=$(wc -l < "$INBOX_FILE" | tr -d ' ')
[ "$LINE_COUNT" -eq 5 ] || fail "verwacht 5 events in inbox, kreeg $LINE_COUNT"

# Validate JSON parseability
python3 - "$INBOX_FILE" <<'PY' || fail "inbox NDJSON niet parseable"
import json, sys
with open(sys.argv[1]) as f:
    for i, line in enumerate(f, 1):
        try:
            obj = json.loads(line)
            assert "ts" in obj and "type" in obj, f"line {i} mist ts of type"
        except Exception as e:
            print(f"line {i} fout: {e}", file=sys.stderr)
            sys.exit(1)
PY
pass "cockpit msg produceert 5 valide NDJSON events"

# Validate all 5 event types present
EVENT_TYPES=$(python3 -c "
import json, sys
seen = set()
with open('$INBOX_FILE') as f:
    for line in f: seen.add(json.loads(line)['type'])
print(','.join(sorted(seen)))
")
[ "$EVENT_TYPES" = "deliver,done,error,question,status" ] || \
  fail "verwacht alle 5 event types, kreeg: $EVENT_TYPES"
pass "alle 5 event-types aanwezig (deliver, done, error, question, status)"

# ----- 3. md2docx converter -----
info "3. md2docx converter"
python3 -c "import docx" 2>/dev/null || fail "python-docx niet geïnstalleerd"

cat > "$SANDBOX/test.md" <<'EOF'
---
title: Test
---

# Hoofd

## Sub

Een **bold** en *italic* paragraaf.

- item 1
- item 2

1. eerste
2. tweede

---

Na page-break.
EOF

python3 "$REPO_DIR/templates/skills/output/docx/scripts/md2docx.py" \
  "$SANDBOX/test.md" "$SANDBOX/test.docx" >/dev/null
[ -f "$SANDBOX/test.docx" ] || fail "docx niet aangemaakt"
file "$SANDBOX/test.docx" | grep -q "OOXML" || fail "docx is geen valid OOXML"
pass "md2docx produceert valide .docx"

# ----- 4. outline2pptx converter -----
info "4. outline2pptx converter"
python3 -c "import pptx" 2>/dev/null || fail "python-pptx niet geïnstalleerd"

cat > "$SANDBOX/outline.md" <<'EOF'
# Test Pitch

Auteur Onbekend
2026-05-20

---

# Probleem

- Item een
- Item twee

---

# Oplossing

- Oplossing een
- Oplossing twee
EOF

python3 "$REPO_DIR/templates/skills/output/pptx/scripts/outline2pptx.py" \
  "$SANDBOX/outline.md" "$SANDBOX/out.pptx" >/dev/null
[ -f "$SANDBOX/out.pptx" ] || fail "pptx niet aangemaakt"
file "$SANDBOX/out.pptx" | grep -q "OOXML" || fail "pptx is geen valid OOXML"
pass "outline2pptx produceert valide .pptx"

# ----- 5. routes.yaml is valide YAML -----
info "5. routes.yaml parseability"
python3 -c "
import yaml
with open('$REPO_DIR/templates/cockpit/routes.yaml') as f:
    data = yaml.safe_load(f)
assert 'routes' in data, 'routes key ontbreekt'
assert len(data['routes']) >= 3, 'verwacht minstens 3 routes voor v0.0'
" || fail "routes.yaml is niet valide YAML"
pass "routes.yaml is valide YAML met >= 3 routes"

# ----- 6. SKILL.md files hebben valide frontmatter -----
info "6. SKILL.md frontmatter"
for skill in \
  "$REPO_DIR/templates/workspaces/marketing/.claude/skills/blog-writer/SKILL.md" \
  "$REPO_DIR/templates/workspaces/marketing/.claude/skills/linkedin-writer/SKILL.md" \
  "$REPO_DIR/templates/workspaces/marketing/.claude/skills/marktonderzoeker/SKILL.md" \
  "$REPO_DIR/templates/cockpit/.claude/skills/cockpit-dispatch/SKILL.md" \
  "$REPO_DIR/templates/cockpit/.claude/skills/cockpit-monitor/SKILL.md" \
  "$REPO_DIR/templates/cockpit/.claude/skills/project-manager/SKILL.md" \
  "$REPO_DIR/templates/skills/output/docx/SKILL.md" \
  "$REPO_DIR/templates/skills/output/pptx/SKILL.md"
do
  head -1 "$skill" | grep -q '^---$' || fail "$skill heeft geen YAML frontmatter"
  python3 - "$skill" <<'PY' || fail "$skill frontmatter ongeldig"
import sys, re, yaml
text = open(sys.argv[1]).read()
m = re.match(r'^---\n(.*?)\n---\n', text, re.DOTALL)
if not m:
    sys.exit(f"geen frontmatter in {sys.argv[1]}")
fm = yaml.safe_load(m.group(1))
assert 'name' in fm and 'description' in fm, f"name of description ontbreekt in {sys.argv[1]}"
PY
done
pass "alle 8 SKILL.md files hebben valide frontmatter"

# ----- 7. install.sh syntax -----
info "7. install.sh shell syntax"
bash -n "$REPO_DIR/install.sh" || fail "install.sh syntax error"
pass "install.sh parsed OK"

# ----- 8. bin/cockpit syntax -----
info "8. bin/cockpit shell syntax"
bash -n "$REPO_DIR/bin/cockpit" || fail "bin/cockpit syntax error"
pass "bin/cockpit parsed OK"

# ----- summary -----
echo
echo "${C_GREEN}all smoke-tests passed${C_RESET}"
echo
echo "Geverifieerde keten:"
echo "  cockpit msg -> NDJSON inbox (5 event types)"
echo "  markdown   -> docx via python-docx"
echo "  outline    -> pptx via python-pptx"
echo "  routes.yaml + 7 SKILL.md files valideren"
echo "  install.sh + bin/cockpit shell-syntax OK"
