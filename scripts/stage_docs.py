#!/usr/bin/env python3
"""Stage only public documentation and assets for GitHub Pages."""

import argparse
import shutil
from pathlib import Path


def stage_docs(root, destination):
    root = Path(root).resolve()
    destination = Path(destination).resolve()
    # Keep generated output out of the source tree and never overwrite a directory.
    if destination == root or root in destination.parents or destination in root.parents:
        raise ValueError("The documentation destination must be outside the source tree.")
    destination.mkdir(parents=True, exist_ok=False)

    for name in ("index.html", "docs-manifest.json", ".nojekyll"):
        shutil.copyfile(root / name, destination / name)

    allowed_suffixes = {".md", ".pdf", ".vsdx"}
    asset_suffixes = {".svg", ".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico"}
    # Limit traversal to documented content roots; never package .git or runtime files.
    candidates = list(root.iterdir())
    for name in ("docs", "modules", "references", "assets"):
        candidates.extend((root / name).rglob("*"))
    for source in candidates:
        relative = source.relative_to(root)
        if any(part.startswith(".") for part in relative.parts) or source.is_symlink():
            continue
        if not source.is_file():
            continue
        if source.suffix.lower() not in allowed_suffixes | asset_suffixes:
            continue
        target = destination / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", type=Path)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    stage_docs(args.root, args.destination)


if __name__ == "__main__":
    main()
