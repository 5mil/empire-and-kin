#!/usr/bin/env bash
# Empire & Kin — fetch every CC0 pack we can hit without an itch login.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CC0="$ROOT/assets/cc0"
CACHE="$ROOT/assets/.cache/cc0"
UA="EmpireAndKin-AssetFetch/0.7.2 (+https://github.com/5mil/empire-and-kin)"

FETCH_KENNEY=1
FETCH_POLYHAVEN=1
FETCH_SAMPLES=1
POLY_LIMIT=24

while [[ $# -gt 0 ]]; do
  case "$1" in
    --kenney-only) FETCH_POLYHAVEN=0; FETCH_SAMPLES=0; shift ;;
    --polyhaven-only) FETCH_KENNEY=0; FETCH_SAMPLES=0; shift ;;
    --samples-only) FETCH_KENNEY=0; FETCH_POLYHAVEN=0; shift ;;
    --no-polyhaven) FETCH_POLYHAVEN=0; shift ;;
    --no-samples) FETCH_SAMPLES=0; shift ;;
    --poly-limit) POLY_LIMIT="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: ./tools/fetch_cc0_assets.sh [--kenney-only|--polyhaven-only|--poly-limit N]"
      exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing $1"; exit 1; }; }
need curl; need unzip
mkdir -p "$CC0/characters" "$CC0/buildings" "$CC0/vehicles" "$CC0/props" "$CC0/environment" "$CC0/textures" "$CACHE"

download() {
  local url="$1" out="$2"
  if [[ -f "$out" ]]; then echo "  [skip] $(basename "$out")"; return 0; fi
  echo "  [get] $(basename "$out")"
  curl -fL --retry 3 --retry-delay 2 -A "$UA" -o "$out.partial" "$url"
  mv "$out.partial" "$out"
}

extract_gltf() {
  local zipfile="$1" dest="$2"
  local tmp; tmp="$(mktemp -d "$CACHE/extract.XXXXXX")"
  unzip -qo "$zipfile" -d "$tmp"
  find "$tmp" -type f \( -iname '*.glb' -o -iname '*.GLB' \) -print0 2>/dev/null |
    while IFS= read -r -d '' f; do cp -n "$f" "$dest/" 2>/dev/null || true; done
  rm -rf "$tmp"
}

if [[ "$FETCH_KENNEY" == 1 ]]; then
  echo "=== Kenney CC0 packs ==="
  declare -a KENNEY_JOBS=(
    "city-kit-roads|environment|https://kenney.nl/media/pages/assets/city-kit-roads/74288c9459-1787042796/kenney_city-kit-roads.zip"
    "city-kit-commercial|buildings|https://kenney.nl/media/pages/assets/city-kit-commercial/a742d900eb-1753115042/kenney_city-kit-commercial_2.1.zip"
    "city-kit-suburban|buildings|https://kenney.nl/media/pages/assets/city-kit-suburban/2c871b7af2-1745479373/kenney_city-kit-suburban_20.zip"
    "city-kit-industrial|buildings|https://kenney.nl/media/pages/assets/city-kit-industrial/5fcb837741-1750838303/kenney_city-kit-industrial_1.0.zip"
    "modular-buildings|buildings|https://kenney.nl/media/pages/assets/modular-buildings/3253b4219a-1707397411/kenney_modular-buildings.zip"
    "car-kit|vehicles|https://kenney.nl/media/pages/assets/car-kit/1a312ec241-1775131960/kenney_car-kit.zip"
    "nature-kit|props|https://kenney.nl/media/pages/assets/nature-kit/37ac38a37b-1677698939/kenney_nature-kit.zip"
    "furniture-kit|props|https://kenney.nl/media/pages/assets/furniture-kit/440e0608a4-1677580847/kenney_furniture-kit.zip"
    "food-kit|props|https://kenney.nl/media/pages/assets/food-kit/83086fa91c-1719418518/kenney_food-kit.zip"
    "train-kit|vehicles|https://kenney.nl/media/pages/assets/train-kit/cf8521d625-1727040883/kenney_train-kit.zip"
  )
  for job in "${KENNEY_JOBS[@]}"; do
    IFS='|' read -r name dest_key url <<<"$job"
    dest="$CC0/$dest_key"
    zip_path="$CACHE/${name}.zip"
    echo "-- $name → $dest_key"
    if ! download "$url" "$zip_path"; then
      echo "  [warn] 404 — open https://kenney.nl/assets/$name and refresh the URL"
      continue
    fi
    extract_gltf "$zip_path" "$dest"
    echo "  [ok] $(find "$dest" -maxdepth 1 -iname '*.glb' 2>/dev/null | wc -l | tr -d ' ') glb in $dest_key"
  done
fi

if [[ "$FETCH_POLYHAVEN" == 1 ]]; then
  echo "=== Poly Haven models (limit=$POLY_LIMIT) ==="
  if command -v python3 >/dev/null 2>&1; then
    PH_LIST="$CACHE/polyhaven_models.json"
    curl -fsSL -A "$UA" "https://api.polyhaven.com/assets?t=models" -o "$PH_LIST" || PH_LIST=""
    if [[ -n "$PH_LIST" && -f "$PH_LIST" ]]; then
      python3 - "$PH_LIST" "$POLY_LIMIT" "$CACHE" "$CC0/props" "$UA" <<'PY'
import json, os, sys, urllib.request, zipfile, shutil, tempfile
list_path, limit, cache, dest, ua = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4], sys.argv[5]
with open(list_path, encoding="utf-8") as f:
    assets = json.load(f)
prefer = ("building", "urban", "street", "prop", "furniture", "barrel", "crate", "car", "vehicle", "lamp", "bench", "trash")
ids = list(assets.keys())
def score(aid):
    meta = assets[aid]
    tags = " ".join(meta.get("tags") or []).lower()
    cat = meta.get("categories") or meta.get("category") or ""
    if isinstance(cat, list): cat = " ".join(cat)
    cat = str(cat).lower()
    return (-sum(1 for p in prefer if p in tags or p in cat), aid)
ids.sort(key=score)
os.makedirs(dest, exist_ok=True)
for aid in ids[:limit]:
    try:
        req = urllib.request.Request(f"https://api.polyhaven.com/files/{aid}", headers={"User-Agent": ua})
        with urllib.request.urlopen(req, timeout=60) as r:
            files = json.load(r)
    except Exception as e:
        print(f"  [warn] {aid}: {e}"); continue
    gltf = files.get("gltf") or {}
    if not gltf:
        print(f"  [skip] no gltf {aid}"); continue
    chosen = None
    for rk in sorted(gltf.keys()):
        node = gltf[rk]
        if isinstance(node, dict) and ("gltf" in node or "url" in node):
            chosen = node.get("gltf") or node
            break
    if not chosen or "url" not in chosen:
        print(f"  [skip] no url {aid}"); continue
    url = chosen["url"]
    out = os.path.join(cache, f"ph_{aid}.zip")
    if not os.path.isfile(out):
        print(f"  [get] {aid}")
        req2 = urllib.request.Request(url, headers={"User-Agent": ua})
        with urllib.request.urlopen(req2, timeout=300) as r, open(out + ".partial", "wb") as w:
            w.write(r.read())
        os.replace(out + ".partial", out)
    tmp = tempfile.mkdtemp(prefix="ph_")
    try:
        try:
            with zipfile.ZipFile(out) as z:
                z.extractall(tmp)
            for root, _, names in os.walk(tmp):
                for n in names:
                    if n.lower().endswith(".glb"):
                        shutil.copy2(os.path.join(root, n), os.path.join(dest, f"ph_{aid}_{n}"))
        except zipfile.BadZipFile:
            if url.lower().endswith(".glb"):
                shutil.copy2(out, os.path.join(dest, f"ph_{aid}.glb"))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
print("  [ok] Poly Haven pass")
PY
    fi
  else
    echo "  [skip] need python3"
  fi
fi

if [[ "$FETCH_SAMPLES" == 1 ]]; then
  echo "=== Khronos CC0-friendly samples ==="
  BASE="https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models"
  declare -a SAMPLES=(
    "Box/glTF-Binary/Box.glb|props"
    "Cube/glTF-Binary/Cube.glb|props"
    "Triangle/glTF-Binary/Triangle.glb|props"
  )
  for s in "${SAMPLES[@]}"; do
    IFS='|' read -r rel dest_key <<<"$s"
    name="$(basename "$rel")"
    dest="$CC0/$dest_key"
    out="$dest/khronos_$name"
    [[ -f "$out" ]] && { echo "  [skip] $name"; continue; }
    download "$BASE/$rel" "$out" || { echo "  [warn] $rel"; rm -f "$out" "$out.partial"; }
  done
fi

echo
echo "=== Summary ==="
for d in characters buildings vehicles props environment; do
  n="$(find "$CC0/$d" -maxdepth 1 -iname '*.glb' 2>/dev/null | wc -l | tr -d ' ')"
  echo "  assets/cc0/$d: $n glb"
done
cat <<'EOF'

Still manual (itch — no stable CDN):
  Quaternius UBC: https://quaternius.itch.io/universal-base-characters
  Kenney characters: https://kenney.itch.io/kenney-character-assets

Then from repo root:
  zig build -Dgpu=true -Doptimize=ReleaseFast
Look for [models] cache=N chars=... bld=... veh=...
EOF
