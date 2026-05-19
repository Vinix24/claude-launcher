#!/usr/bin/env python3
"""
inbox.py — atomic NDJSON event writer for claude-launcher workers.

Invoked via `cockpit msg <type> ...` from inside a worker tmux session.
Reads CLAUDE_LAUNCHER_TASK_ID + CLAUDE_LAUNCHER_HOME from the environment.

Events land in: $CLAUDE_LAUNCHER_HOME/inbox/<task-id>.ndjson
Format        : one JSON object per line (NDJSON), atomic append.

Event types:
  status     - progress update                     (content)
  question   - blocking question to the operator   (content, options[])
  deliver    - artifact ready                       (path, format)
  done       - work completed                       (summary)
  error      - failure                              (content, blocking)
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import time
from pathlib import Path

EVENT_TYPES = {"status", "question", "deliver", "done", "error"}


def launcher_home() -> Path:
    return Path(os.environ.get("CLAUDE_LAUNCHER_HOME", os.path.expanduser("~/.claude-launcher")))


def task_id() -> str:
    tid = os.environ.get("CLAUDE_LAUNCHER_TASK_ID", "").strip()
    if not tid:
        sys.exit(
            "cockpit msg: CLAUDE_LAUNCHER_TASK_ID is leeg.\n"
            "Werd deze worker via 'cockpit launch' gestart? Anders export hem zelf."
        )
    return tid


def inbox_path() -> Path:
    p = launcher_home() / "inbox"
    p.mkdir(parents=True, exist_ok=True)
    return p / f"{task_id()}.ndjson"


def append_event(event: dict) -> None:
    event = {"ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), **event}
    path = inbox_path()
    line = json.dumps(event, ensure_ascii=False) + "\n"

    # atomic append: open with O_APPEND so writes from concurrent workers
    # interleave at the line level rather than corrupt each other
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_APPEND, 0o644)
    try:
        os.write(fd, line.encode("utf-8"))
    finally:
        os.close(fd)

    # echo to stderr so the worker sees confirmation in its tmux pane
    print(f"[cockpit msg] {event['type']}: {line.strip()}", file=sys.stderr)


def cmd_status(args: argparse.Namespace) -> None:
    append_event({"type": "status", "content": args.text})


def cmd_question(args: argparse.Namespace) -> None:
    event = {"type": "question", "content": args.text}
    if args.options:
        event["options"] = [o.strip() for o in args.options.split(",") if o.strip()]
    append_event(event)


def cmd_deliver(args: argparse.Namespace) -> None:
    p = Path(args.path)
    if not p.is_absolute():
        p = (launcher_home() / "output" / p).resolve()
    if not p.exists():
        sys.exit(f"cockpit msg deliver: bestand bestaat niet: {p}")

    event = {"type": "deliver", "artifact": str(p)}
    if args.format:
        event["format"] = args.format
    else:
        event["format"] = p.suffix.lstrip(".") or "unknown"
    if args.bytes:
        try:
            event["bytes"] = p.stat().st_size
        except OSError:
            pass
    append_event(event)


def cmd_done(args: argparse.Namespace) -> None:
    append_event({"type": "done", "summary": args.summary})


def cmd_error(args: argparse.Namespace) -> None:
    append_event({"type": "error", "content": args.text, "blocking": bool(args.blocking)})


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="cockpit msg",
        description="Schrijf een NDJSON-event naar de inbox van deze worker.",
    )
    sub = p.add_subparsers(dest="event_type", required=True)

    sp = sub.add_parser("status", help="Progress update")
    sp.add_argument("text")
    sp.set_defaults(func=cmd_status)

    sp = sub.add_parser("question", help="Blocking question to the operator")
    sp.add_argument("text")
    sp.add_argument("--options", help="Comma-separated answer options")
    sp.set_defaults(func=cmd_question)

    sp = sub.add_parser("deliver", help="Mark an artifact ready")
    sp.add_argument("path", help="Absolute path or relative to ~/.claude-launcher/output/")
    sp.add_argument("--format", help="Override format (defaults to file suffix)")
    sp.add_argument("--bytes", action="store_true", help="Include file size in bytes")
    sp.set_defaults(func=cmd_deliver)

    sp = sub.add_parser("done", help="Mark the task complete")
    sp.add_argument("summary")
    sp.set_defaults(func=cmd_done)

    sp = sub.add_parser("error", help="Report a failure")
    sp.add_argument("text")
    sp.add_argument("--blocking", action="store_true", help="Operator needs to intervene")
    sp.set_defaults(func=cmd_error)

    return p


def main(argv: list[str] | None = None) -> None:
    parser = build_parser()
    args = parser.parse_args(argv)
    args.func(args)


if __name__ == "__main__":
    main()
