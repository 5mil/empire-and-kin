#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
if [[ -f src/engine/session_run_part0.zig.txt ]]; then
  cat src/engine/session_run_part0.zig.txt \
      src/engine/session_run_part1.zig.txt \
      src/engine/session_run_part2.zig.txt \
      > src/engine/session_run.zig
  echo "OK: assembled session_run.zig ($(wc -c < src/engine/session_run.zig) bytes)"
  grep -q 'pub fn run' src/engine/session_run.zig
  grep -q 'while (!gfx.shouldClose())' src/engine/session_run.zig
  grep -q 'raw.shift' src/engine/session_run.zig
  grep -q 'action.drive' src/engine/session_run.zig
  echo "OK: structure checks passed (run/while/handbrake)"
else
  echo "ERROR: part files missing under src/engine/"
  exit 1
fi
