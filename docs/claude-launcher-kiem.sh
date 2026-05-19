#!/bin/bash
# claude-launcher.sh — spawn een tmux sessie, start Claude Code, paste een prompt, optioneel pop in iTerm
#
# Usage:
#   ./claude-launcher.sh NAME FOLDER [opties]
#
# Verplicht:
#   NAME     — tmux sessie naam (alfanumeriek, unique)
#   FOLDER   — werkdirectory voor de Claude sessie
#
# Opties (combineerbaar):
#   --prompt-file FILE     — prompt-tekst uit bestand (paste na Claude-startup)
#   --prompt "TEXT"        — prompt-tekst inline
#   --resume UUID          — claude --resume <uuid> ipv nieuwe sessie
#   --skip-permissions     — voeg --dangerously-skip-permissions toe
#   --no-iterm             — skip de iTerm pop-up (sessie blijft headless)
#   --iterm                — forceer iTerm pop-up (default als TERM_PROGRAM=iTerm)
#   --wait-seconds N       — wacht N seconden op Claude-startup (default 4)
#
# Voorbeelden:
#   ./claude-launcher.sh convman /pad/naar/folder \
#       --prompt-file /tmp/start.txt \
#       --skip-permissions
#
#   ./claude-launcher.sh sentech /Users/.../Renewance \
#       --resume 39a503ed-5962-4279-b9c5-1ec002ba3412 \
#       --skip-permissions \
#       --no-iterm

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 NAME FOLDER [--prompt-file FILE | --prompt TEXT] [--resume UUID] [--skip-permissions] [--no-iterm] [--wait-seconds N]"
  exit 1
fi

NAME="$1"
FOLDER="$2"
shift 2

PROMPT_FILE=""
PROMPT_INLINE=""
RESUME_UUID=""
SKIP_PERMS=0
WAIT_SECONDS=4
USE_ITERM="auto"

while [ $# -gt 0 ]; do
  case "$1" in
    --prompt-file)    PROMPT_FILE="$2"; shift 2 ;;
    --prompt)         PROMPT_INLINE="$2"; shift 2 ;;
    --resume)         RESUME_UUID="$2"; shift 2 ;;
    --skip-permissions) SKIP_PERMS=1; shift ;;
    --no-iterm)       USE_ITERM="no"; shift ;;
    --iterm)          USE_ITERM="yes"; shift ;;
    --wait-seconds)   WAIT_SECONDS="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [ ! -d "$FOLDER" ]; then
  echo "Folder bestaat niet: $FOLDER"
  exit 1
fi

if tmux has-session -t "$NAME" 2>/dev/null; then
  echo "Sessie '$NAME' bestaat al. Gebruik andere naam of run: tmux kill-session -t $NAME"
  exit 1
fi

CLAUDE_CMD="claude"
[ $SKIP_PERMS -eq 1 ] && CLAUDE_CMD="$CLAUDE_CMD --dangerously-skip-permissions"
[ -n "$RESUME_UUID" ] && CLAUDE_CMD="$CLAUDE_CMD --resume $RESUME_UUID"

echo "1/4  spawn tmux sessie '$NAME' in $FOLDER"
tmux new-session -d -s "$NAME" -c "$FOLDER" -x 220 -y 50

echo "2/4  start Claude Code"
tmux send-keys -t "$NAME" "$CLAUDE_CMD" Enter

echo "3/4  wacht ${WAIT_SECONDS}s op Claude startup"
sleep "$WAIT_SECONDS"

if [ -n "$PROMPT_FILE" ] || [ -n "$PROMPT_INLINE" ]; then
  TMP_PROMPT="$(mktemp -t claude-launcher-prompt-XXXX)"
  trap 'rm -f "$TMP_PROMPT"' EXIT
  if [ -n "$PROMPT_FILE" ]; then
    cp "$PROMPT_FILE" "$TMP_PROMPT"
  else
    printf '%s' "$PROMPT_INLINE" > "$TMP_PROMPT"
  fi
  echo "4/4  paste prompt"
  tmux load-buffer "$TMP_PROMPT"
  tmux paste-buffer -t "$NAME"
  sleep 0.4
  tmux send-keys -t "$NAME" Enter
else
  echo "4/4  geen prompt opgegeven, sessie blijft op input-prompt"
fi

# iTerm pop-up
if [ "$USE_ITERM" = "auto" ]; then
  [ "${TERM_PROGRAM:-}" = "iTerm.app" ] && USE_ITERM="yes" || USE_ITERM="no"
fi

if [ "$USE_ITERM" = "yes" ]; then
  osascript <<EOF
tell application "iTerm"
  activate
  create window with default profile
  tell current session of current window
    write text "tmux attach -t $NAME"
  end tell
end tell
EOF
  echo "✓ iTerm-venster open, attached aan tmux:$NAME"
else
  echo "✓ tmux sessie '$NAME' draait headless. Attach met:  tmux attach -t $NAME"
fi
