#!/usr/bin/env bash
# Asset Continuum — ensure local CC0 packs and process premium generate queue.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

usage() {
  echo "Usage: $0 [--fetch] [--process-queue] [--all]"
  echo "  --fetch          Run tools/fetch_cc0_assets.sh (T3)"
  echo "  --process-queue  Walk assets/queue/*.job.json and run TRELLIS helper (T4)"
  echo "  --all            fetch + process-queue"
}

DO_FETCH=0
DO_QUEUE=0
for arg in "$@"; do
  case "$arg" in
    --fetch) DO_FETCH=1 ;;
    --process-queue) DO_QUEUE=1 ;;
    --all) DO_FETCH=1; DO_QUEUE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown: $arg"; usage; exit 1 ;;
  esac
done

if [[ $DO_FETCH -eq 0 && $DO_QUEUE -eq 0 ]]; then
  usage
  exit 1
fi

if [[ $DO_FETCH -eq 1 ]]; then
  if [[ -x tools/fetch_cc0_assets.sh ]]; then
    echo "[ensure] T3 fetch CC0…"
    ./tools/fetch_cc0_assets.sh || true
  else
    echo "[ensure] fetch_cc0_assets.sh missing — skip"
  fi
fi

if [[ $DO_QUEUE -eq 1 ]]; then
  mkdir -p assets/queue assets/generated
  shopt -s nullglob
  jobs=(assets/queue/*.job.json)
  if [[ ${#jobs[@]} -eq 0 ]]; then
    echo "[ensure] no pending jobs in assets/queue"
  fi
  for job in "${jobs[@]}"; do
    status=$(python3 -c "import json;print(json.load(open('$job')).get('status',''))" 2>/dev/null || echo "")
    if [[ "$status" != "pending" ]]; then
      echo "[ensure] skip $job (status=$status)"
      continue
    fi
    recipe_id=$(python3 -c "import json;print(json.load(open('$job'))['recipe_id'])")
    out=$(python3 -c "import json;print(json.load(open('$job'))['out'])")
    prompt=$(python3 -c "import json;print(json.load(open('$job')).get('prompt',''))")
    res=$(python3 -c "import json;print(json.load(open('$job')).get('res',512))")
    name=$(basename "$out")
    echo "[ensure] T4 job $recipe_id → $out"

    # Concept image placeholder: user must supply or generate separately.
    concept="$out/concept.png"
    mkdir -p "$out"
    if [[ ! -f "$concept" ]]; then
      echo "[ensure] missing concept image $concept — write prompt to prompt.txt and generate image first"
      echo "$prompt" > "$out/prompt.txt"
      python3 -c "import json;p=json.load(open('$job'));p['status']='need_concept';json.dump(p,open('$job','w'),indent=2)"
      continue
    fi

    if [[ -f tools/run_trellis_image_to_3d.py ]]; then
      python3 tools/run_trellis_image_to_3d.py \
        --image "$concept" \
        --out "$out" \
        --name "$name" \
        --res "$res" \
        --notes "continuum job $recipe_id" \
        && python3 -c "import json;p=json.load(open('$job'));p['status']='done';json.dump(p,open('$job','w'),indent=2)" \
        || python3 -c "import json;p=json.load(open('$job'));p['status']='failed';json.dump(p,open('$job','w'),indent=2)"
    else
      echo "[ensure] run_trellis_image_to_3d.py missing"
    fi
  done
fi

echo "[ensure] done"
