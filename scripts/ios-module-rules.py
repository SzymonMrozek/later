#!/usr/bin/env python3
"""Checks the iOS module graph against the architecture in ios/Modules/README.md.

    scripts/ios-module-rules.py               reads the graph from Tuist
    scripts/ios-module-rules.py --graph FILE  checks a `tuist graph --format json` export

`tuist inspect dependencies` already checks that imports match declared dependencies; this
checks that the declared dependencies are allowed.
"""
import argparse
import json
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPOSITION_ROOT = "AppComposition"


def load_graph(path: Path | None) -> dict:
    if path:
        return json.loads(path.read_text())
    with tempfile.TemporaryDirectory() as output:
        subprocess.run(
            ["tuist", "graph", "--format", "json", "--no-open", "--skip-external-dependencies",
             "--output-path", output],
            cwd=ROOT / "ios", check=True, stdout=subprocess.DEVNULL,
        )
        return json.loads((Path(output) / "graph.json").read_text())


def targets(graph: dict) -> dict[str, dict]:
    found = {}
    for project in graph["projects"]:
        if not isinstance(project, dict):
            continue
        entries = project["targets"]
        for target in entries if isinstance(entries, list) else entries.values():
            dependencies = [d["target"]["name"] for d in target["dependencies"] if "target" in d]
            found[target["name"]] = {"product": target["product"], "dependencies": dependencies}
    return found


def violations(found: dict[str, dict]) -> list[str]:
    problems = []
    for name, target in sorted(found.items()):
        is_test = target["product"] in ("unit_tests", "ui_tests")
        if target["product"] == "app" and target["dependencies"] != [COMPOSITION_ROOT]:
            problems.append(f"{name} depends on {target['dependencies']}. The app depends on {COMPOSITION_ROOT} only.")
        for dependency in target["dependencies"]:
            if dependency.endswith("Implementation") and name not in (COMPOSITION_ROOT, f"{dependency}Tests"):
                problems.append(
                    f"{name} depends on {dependency}. Depend on its Interface; only {COMPOSITION_ROOT} "
                    "selects implementations."
                )
            if dependency == "HTTPNetworkingInterface" and not (
                is_test or name.endswith("ResourceImplementation") or name == "HTTPNetworkingImplementation"
            ):
                problems.append(
                    f"{name} depends on {dependency}. Reach the API through a <Name>Resource, which owns "
                    "its endpoints, bodies and mapping."
                )
    return problems


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--graph", type=Path, help="a `tuist graph --format json` export")
    found = targets(load_graph(parser.parse_args().graph))
    problems = violations(found)
    for problem in problems:
        print(f"error: {problem}", file=sys.stderr)
    if problems:
        return 1
    print(f"Module rules: {len(found)} targets, no violations.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
