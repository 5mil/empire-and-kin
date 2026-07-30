#!/usr/bin/env python3
"""
TRELLIS.2 image → textured GLB helper for Empire & Kin.

This script is a thin wrapper. You must install TRELLIS.2 (or compatible
TRELLIS image-to-3D pipeline) separately on a GPU machine.

Docs: docs/ART_GENERATION_PIPELINE.md
Upstream: https://microsoft.github.io/TRELLIS.2/

Usage:
  python tools/run_trellis_image_to_3d.py \
    --image path/to/concept.png \
    --out assets/generated/props/crate_01 \
    --name crate_01 \
    --res 512
"""

from __future__ import annotations

import argparse
import json
import hashlib
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def write_meta(out_dir: Path, args: argparse.Namespace, image: Path, glb: Path) -> None:
    meta = {
        "name": args.name,
        "tool": "TRELLIS.2",
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "source_image": str(image.resolve()),
        "source_sha256": sha256_file(image),
        "output_glb": glb.name,
        "res": args.res,
        "seed": args.seed,
        "notes": args.notes or "",
        "license_note": "Input image must be owned/CC0/PD. TRELLIS.2 is MIT — verify upstream terms.",
    }
    (out_dir / "meta.json").write_text(json.dumps(meta, indent=2) + "\n", encoding="utf-8")


def try_run_trellis(image: Path, out_glb: Path, res: int, seed: int) -> bool:
    """Attempt to call TRELLIS if installed. Returns True on success."""
    try:
        # Prefer current TRELLIS.2 API if present on PYTHONPATH.
        # Names may differ slightly across TRELLIS vs TRELLIS.2 releases;
        # adjust imports to match the installed package README.
        from PIL import Image  # type: ignore

        # Common pattern from Microsoft TRELLIS family:
        # from trellis.pipelines import TrellisImageTo3DPipeline
        # pipeline = TrellisImageTo3DPipeline.from_pretrained(...)
        #
        # TRELLIS.2 may use a different module path — follow upstream README.
        import importlib

        pipeline_mod = None
        for candidate in (
            "trellis.pipelines",
            "trellis2.pipelines",
            "trellis_2.pipelines",
        ):
            try:
                pipeline_mod = importlib.import_module(candidate)
                break
            except ImportError:
                continue

        if pipeline_mod is None:
            print(
                "[trellis] TRELLIS Python package not found on PYTHONPATH.\n"
                "          Install per https://microsoft.github.io/TRELLIS.2/\n"
                "          Then re-run this script.",
                file=sys.stderr,
            )
            return False

        # Heuristic: look for an ImageTo3D pipeline class
        pipeline_cls = None
        for name in dir(pipeline_mod):
            if "ImageTo3D" in name or "Image2" in name:
                pipeline_cls = getattr(pipeline_mod, name)
                break

        if pipeline_cls is None:
            print(
                "[trellis] Package found but no ImageTo3D pipeline class detected.\n"
                "          Call upstream demo/CLI and copy the GLB into --out manually.",
                file=sys.stderr,
            )
            return False

        print("[trellis] Loading pipeline (first run downloads weights)...")
        # from_pretrained name varies; try common defaults
        if hasattr(pipeline_cls, "from_pretrained"):
            try:
                pipeline = pipeline_cls.from_pretrained("microsoft/TRELLIS-image-large")
            except Exception:
                pipeline = pipeline_cls.from_pretrained("microsoft/TRELLIS.2")
        else:
            pipeline = pipeline_cls()

        if hasattr(pipeline, "cuda"):
            pipeline.cuda()

        img = Image.open(image).convert("RGB")
        print(f"[trellis] Running image→3D res={res} seed={seed} ...")

        # API shape varies; try common call patterns
        outputs = None
        if hasattr(pipeline, "run"):
            try:
                outputs = pipeline.run(img, seed=seed)
            except TypeError:
                outputs = pipeline.run(img)
        elif callable(pipeline):
            outputs = pipeline(img)

        if outputs is None:
            print("[trellis] Pipeline returned nothing usable.", file=sys.stderr)
            return False

        # Extract mesh / export GLB — adapt to actual return type
        mesh = None
        if isinstance(outputs, dict):
            mesh = outputs.get("mesh") or outputs.get("meshes")
            if isinstance(mesh, list) and mesh:
                mesh = mesh[0]
        else:
            mesh = outputs

        out_glb.parent.mkdir(parents=True, exist_ok=True)

        # Try common export helpers
        exported = False
        if hasattr(mesh, "export"):
            mesh.export(str(out_glb))
            exported = True
        else:
            try:
                from trellis.utils import postprocessing_utils  # type: ignore

                glb = postprocessing_utils.to_glb(mesh)
                glb.export(str(out_glb))
                exported = True
            except Exception as e:
                print(f"[trellis] Export failed: {e}", file=sys.stderr)

        if not exported or not out_glb.is_file():
            print(
                "[trellis] Could not auto-export GLB. Use upstream demo, then:\n"
                f"          cp your.glb {out_glb}",
                file=sys.stderr,
            )
            return False

        print(f"[trellis] Wrote {out_glb}")
        return True

    except Exception as e:
        print(f"[trellis] Runtime error: {e}", file=sys.stderr)
        return False


def main() -> int:
    p = argparse.ArgumentParser(description="TRELLIS.2 image → GLB for Empire & Kin")
    p.add_argument("--image", required=True, type=Path, help="Input concept image (legal source)")
    p.add_argument("--out", required=True, type=Path, help="Output directory under assets/generated/...")
    p.add_argument("--name", required=True, help="Asset name (used for .glb filename)")
    p.add_argument("--res", type=int, default=512, choices=(512, 1024, 1536), help="Generation resolution")
    p.add_argument("--seed", type=int, default=1)
    p.add_argument("--notes", default="", help="Free-form note stored in meta.json")
    p.add_argument(
        "--glb",
        type=Path,
        default=None,
        help="If set, skip generation and just register an existing GLB (copy + meta)",
    )
    args = p.parse_args()

    if not args.image.is_file():
        print(f"Image not found: {args.image}", file=sys.stderr)
        return 1

    out_dir = args.out
    out_dir.mkdir(parents=True, exist_ok=True)
    out_glb = out_dir / f"{args.name}.glb"

    if args.glb is not None:
        if not args.glb.is_file():
            print(f"GLB not found: {args.glb}", file=sys.stderr)
            return 1
        shutil.copy2(args.glb, out_glb)
        write_meta(out_dir, args, args.image, out_glb)
        print(f"[ok] Registered existing GLB → {out_glb}")
        return 0

    ok = try_run_trellis(args.image, out_glb, args.res, args.seed)
    if not ok:
        # Still write a stub meta so the folder convention is clear
        stub = {
            "name": args.name,
            "tool": "TRELLIS.2",
            "status": "pending_manual",
            "source_image": str(args.image.resolve()),
            "instructions": "Install TRELLIS.2, generate GLB, then re-run with --glb path/to/out.glb",
        }
        (out_dir / "meta.json").write_text(json.dumps(stub, indent=2) + "\n", encoding="utf-8")
        print(
            f"[pending] meta written to {out_dir / 'meta.json'}\n"
            f"          After manual generation:\n"
            f"          python tools/run_trellis_image_to_3d.py --image {args.image} "
            f"--out {out_dir} --name {args.name} --glb path/to/result.glb",
            file=sys.stderr,
        )
        return 2

    write_meta(out_dir, args, args.image, out_glb)
    print(f"[ok] {out_glb} + meta.json ready for ResourceManager")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
