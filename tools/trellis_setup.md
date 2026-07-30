# TRELLIS.2 setup for Empire & Kin

## 1. GPU machine

- NVIDIA GPU with recent drivers
- Python 3.10+
- CUDA matching the TRELLIS.2 README pins

## 2. Install upstream

Follow the official project page:

- https://microsoft.github.io/TRELLIS.2/
- Clone the official repo and install requirements as documented there.

Weights are typically downloaded from Hugging Face on first run.

## 3. Generate an asset

From the Empire & Kin repo root:

```bash
python tools/run_trellis_image_to_3d.py \
  --image /path/to/legal_concept.png \
  --out assets/generated/props/hydrant_01 \
  --name hydrant_01 \
  --res 512
```

If the auto-import of the Python package fails, generate with the upstream demo CLI, then:

```bash
python tools/run_trellis_image_to_3d.py \
  --image /path/to/legal_concept.png \
  --out assets/generated/props/hydrant_01 \
  --name hydrant_01 \
  --glb /path/to/upstream_output.glb
```

## 4. Engine

Run the game. `ResourceManager.ingestTree` should pick up `assets/generated/**/*.glb` once that root is registered in boot (same as `assets/cc0`).

Add scan root in boot if not already present:

```zig
res.addScanRoot("assets/generated");
```

## 5. Credits

Append a row to `assets/CREDITS.md` for every shipped generated asset.
