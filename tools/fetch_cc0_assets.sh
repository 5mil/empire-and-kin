#!/usr/bin/env bash
# Empire & Kin — automated priority CC0 asset fetch.
# Downloads Kenney packs (direct CDN), optional Poly Haven models, Khronos samples.
# itch.io packs (Quaternius All-in-1, etc.) still need a browser once.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CC0="$ROOT/assets/cc0"
CACHE="$ROOT/assets/.cache/cc0"
UA="EmpireAndKin-AssetFetch/0.4.2 (+https://github.com/5mil/empire-and-kin)"

FETCH_KENNEY=1
FETCH_POLYHAVEN=1
FETCH_SAMPLES=1
POLY_LIMIT=8

while [[ $# -gt 0 ]]; do
  case "$1" in
    --kenney-only) FETCH_POLYHAVEN=0; FETCH_SAMPLES=0; shift ;;
    --polyhaven-only) FETCH_KENNEY=0; FETCH_SAMPLES=0; shift ;;
    --samples-only) FETCH_KENNEY=0; FETCH_POLYHAVEN=0; shift ;;
    --no-polyhaven) FETCH_POLYHAVEN=0; shift ;;
    --no-samples) FETCH_SAMPLES=0; shift ;;
    --poly-limit) POLY_LIMIT="$2"; shift 2 ;;
    -h|--help)
      cat <<'HELP'
Usage: ./tools/fetch_cc0_assets.sh [options]

  (default)     Kenney city/car/nature + Poly Haven props + Khronos samples
  --kenney-only
  --polyhaven-only
  --samples-only
  --no-polyhaven
  --no-samples
  --poly-limit N   Max Poly Haven models (default 8)
HELP
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing dependency: $1"
    exit 1
  }
}

need curl
need unzip
command -v python3 >/dev/null 2>&1 || true

mkdir -p \
  "$CC0/characters" "$CC0/buildings" "$CC0/vehicles" \
  "$CC0/props" "$CC0/environment" "$CC0/textures" \
  "$CC0/reference" "$CACHE"

download() {
  local url="$1" out="$2"
  if [[ -f "$out" ]]; then
    echo "  [skip] exists $(basename "$out")"
    return 0
  fi
  echo "  [get] $(basename "$out")"
  curl -fL --retry 3 --retry-delay 2 -A "$UA" -o "$out.partial" "$url"
  mv "$out.partial" "$out"
}

# Extract archive and promote .glb / Models/glTF-Binary into dest
extract_gltf() {
  local zipfile="$1" dest="$2"
  local tmp
  tmp="$(mktemp -d "$CACHE/extract.XXXXXX")"
  unzip -qo "$zipfile" -d "$tmp"
  # Prefer GLB
  find "$tmp" -type f \( -iname '*.glb' -o -iname '*.GLB' \) -print0 2>/dev/null \
    | while IFS= read -r -d '' f; do
        cp -n "$f" "$dest/" 2>/dev/null || true
      done
  # Also copy standalone .gltf + siblings is complex; GLB is enough for ResourceManager
  # Kenney often ships Models/GLTF format folders
  find "$tmp" -type d \( -iname 'GLTF' -o -iname 'glTF' -o -iname 'gltf' \) 2>/dev/null \
    | while read -r d; do
        find "$d" -maxdepth 2 -type f -iname '*.glb' -print0 2>/dev/null \
          | while IFS= read -r -d '' f; do
              cp -n "$f" "$dest/" 2>/dev/null || true
            done
      done
  rm -rf "$tmp"
}

# ── Kenney (direct CDN, no login) ───────────────────────────────────────────
if [[ "$FETCH_KENNEY" == 1 ]]; then
  echo "=== Kenney CC0 packs ==="
  # URL pattern: kenney.nl/media/pages/assets/<slug>/<hash>/filename.zip
  # Hashes can change when packs update; re-scrape page if 404.
  declare -a KENNEY_JOBS=(
    "city-kit-roads|environment|https://kenney.nl/media/pages/assets/city-kit-roads/74288c9459-1741864740/kenney_city-kit-roads.zip"
    "city-kit-commercial|buildings|https://kenney.nl/media/pages/assets/city-kit-commercial/a742d900eb-1753115042/kenney_city-kit-commercial_2.1.zip"
    "city-kit-suburban|buildings|https://kenney.nl/media/pages/assets/city-kit-suburban/2c871b7af2-1745479373/kenney_city-kit-suburban_20.zip"
    "city-kit-industrial|buildings|https://kenney.nl/media/pages/assets/city-kit-industrial/5fcb837741-1750838303/kenney_city-kit-industrial_1.0.zip"
    "car-kit|vehicles|https://kenney.nl/media/pages/assets/car-kit/1a312ec241-1775131960/kenney_car-kit.zip"
    "nature-kit|props|https://kenney.nl/media/pages/assets/nature-kit/37ac38a37b-1677698939/kenney_nature-kit.zip"
  )

  for job in "${KENNEY_JOBS[@]}"; do
    IFS='|' read -r name dest_key url <<<"$job"
    dest="$CC0/$dest_key"
    zip_path="$CACHE/${name}.zip"
    echo "-- $name → $dest_key"
    if ! download "$url" "$zip_path"; then
      echo "  [warn] direct URL failed; try opening https://kenney.nl/assets/$name"
      continue
    fi
    extract_gltf "$zip_path" "$dest"
    count="$(find "$dest" -maxdepth 1 -iname '*.glb' 2>/dev/null | wc -l | tr -d ' ')"
    echo "  [ok] $dest has $count .glb files (cumulative)"
  done
fi

# ── Poly Haven (public API) ─────────────────────────────────────────────────
if [[ "$FETCH_POLYHAVEN" == 1 ]]; then
  echo "=== Poly Haven models (API, limit=$POLY_LIMIT) ==="
  if ! command -v python3 >/dev/null 2>&1; then
    echo "  [skip] python3 required for Poly Haven JSON"
  else
    PH_LIST="$CACHE/polyhaven_models.json"
    curl -fsSL -A "$UA" "https://api.polyhaven.com/assets?t=models" -o "$PH_LIST" || {
      echo "  [warn] Poly Haven list failed"
      PH_LIST=""
    }
    if [[ -n "$PH_LIST" && -f "$PH_LIST" ]]; then
      python3 - "$PH_LIST" "$POLY_LIMIT" "$CACHE" "$CC0/props" "$UA" <<'PY'
import json, os, sys, urllib.request

list_path, limit, cache, dest, ua = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4], sys.argv[5]
with open(list_path, encoding="utf-8") as f:
    assets = json.load(f)
# Prefer small / outdoor / architecture-ish tags for NYC feel
prefer = ("building", "urban", "street", "prop", "furniture", "barrel", "crate", "car", "vehicle", "lamp")
ids = list(assets.keys())

def score(aid):
    meta = assets[aid]
    tags = " ".join(meta.get("tags") or []).lower()
    cat = (meta.get("categories") or meta.get("category") or "")
    if isinstance(cat, list):
        cat = " ".join(cat)
    cat = str(cat).lower()
    s = sum(1 for p in prefer if p in tags or p in cat)
    # lower poly preference when available
    return (-s, aid)

ids.sort(key=score)
picked = ids[:limit]
os.makedirs(dest, exist_ok=True)

for aid in picked:
    files_url = f"https://api.polyhaven.com/files/{aid}"
    req = urllib.request.Request(files_url, headers={"User-Agent": ua})
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            files = json.load(r)
    except Exception as e:
        print(f"  [warn] files {aid}: {e}")
        continue
    gltf = files.get("gltf") or {}
    # pick lowest resolution key available
    if not gltf:
        print(f"  [skip] no gltf for {aid}")
        continue
    res_keys = sorted(gltf.keys(), key=lambda k: (0 if k[0].isdigit() else 1, k))
    chosen = None
    for rk in res_keys:
        node = gltf[rk]
        if isinstance(node, dict) and "gltf" in node:
            chosen = node["gltf"]
            break
        if isinstance(node, dict) and "url" in node:
            chosen = node
            break
    if not chosen or "url" not in chosen:
        print(f"  [skip] no gltf url for {aid}")
        continue
    url = chosen["url"]
    # Poly Haven gltf is often a zip of gltf+bin+textures
    out = os.path.join(cache, f"ph_{aid}.zip")
    if not os.path.isfile(out):
        print(f"  [get] {aid}")
        req2 = urllib.request.Request(url, headers={"User-Agent": ua})
        with urllib.request.urlopen(req2, timeout=300) as r, open(out + ".partial", "wb") as w:
            w.write(r.read())
        os.replace(out + ".partial", out)
    else:
        print(f"  [skip] cached {aid}")
    # extract any glb or leave zip note — ResourceManager wants .glb
    import zipfile, shutil, tempfile
    tmp = tempfile.mkdtemp(prefix="ph_")
    try:
        with zipfile.ZipFile(out) as z:
            z.extractall(tmp)
        for root, _, names in os.walk(tmp):
            for n in names:
                if n.lower().endswith(".glb"):
                    shutil.copy2(os.path.join(root, n), os.path.join(dest, f"ph_{aid}_{n}"))
    except zipfile.BadZipFile:
        # single file?
        if url.lower().endswith(".glb"):
            shutil.copy2(out, os.path.join(dest, f"ph_{aid}.glb"))
        else:
            print(f"  [warn] not a zip/glb: {aid}")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
print("  [ok] Poly Haven pass done")
PY
    fi
  fi
fi

# ── Khronos pipeline samples (small, for loader validation) ─────────────────
if [[ "$FETCH_SAMPLES" == 1 ]]; then
  echo "=== Khronos glTF samples (loader smoke) ==="
  BASE="https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models"
  # Prefer CC0-friendly / widely redistributed samples used for testing
  declare -a SAMPLES=(
    "Box/glTF-Binary/Box.glb|props"
    "Duck/glTF-Binary/Duck.glb|props"
    "CesiumMan/glTF-Binary/CesiumMan.glb|characters"
    "RiggedSimple/glTF-Binary/RiggedSimple.glb|characters"
  )
  for s in "${SAMPLES[@]}"; do
    IFS='|' read -r rel dest_key <<<"$s"
    name="$(basename "$rel")"
    dest="$CC0/$dest_key"
    out="$dest/khronos_$name"
    if [[ -f "$out" ]]; then
      echo "  [skip] $name"
      continue
    fi
    if download "$BASE/$rel" "$out"; then
      echo "  [ok] $dest_key/$name"
    else
      echo "  [warn] sample missing: $rel"
      rm -f "$out" "$out.partial" 2>/dev/null || true
    fi
  done
fi

# ── Summary ─────────────────────────────────────────────────────────────────
echo
echo "=== Summary ==="
for d in characters buildings vehicles props environment; do
  n="$(find "$CC0/$d" -maxdepth 1 -iname '*.glb' 2>/dev/null | wc -l | tr -d ' ')"
  echo "  assets/cc0/$d: $n glb"
done

cat <<'EOF'

Manual (itch.io — no stable free CDN):
  Kenney All-in-1:  https://kenney.itch.io/kenney-game-assets
  Quaternius UBC:   https://quaternius.itch.io/universal-base-characters
  Character assets: https://kenney.itch.io/kenney-character-assets

After fetch, run the game (GPU). Expect:
  [res] +assets/cc0/... cat=...
  [models] cache=N chars=... bld=... veh=...

Caches: assets/.cache/cc0/  (safe to delete to re-download)
Log packs in assets/CREDITS.md
EOF
