#!/usr/bin/env python3
"""Assert the appliance chart ships no credential values.

A chart carrying working credentials gives every operator who does not override
them an identically-credentialled deployment, with the value readable by anyone
holding the chart. Each path below must therefore be empty in values.yaml and
supplied at install time.

Checked by path rather than by grepping, because the obvious regex matches
things it should not: `secretKeys.password` names a key rather than carrying a
secret, and an empty value can still carry an illustrative comment.
"""

from __future__ import annotations

import sys
from pathlib import Path

import yaml

VALUES = Path(__file__).resolve().parents[2] / "charts" / "xyo-appliance" / "values.yaml"

# Each entry is the dotted path of a value that must not ship with a credential,
# paired with how an operator is expected to supply it instead.
CREDENTIAL_PATHS = {
    "global.licenseKey": "global.existingLicenseSecret",
    "postgresql.auth.password": "postgresql.auth.existingSecret",
    "postgresql.external.dsn": "postgresql.external.existingSecret",
}


def resolve(data: dict, dotted: str):
    node = data
    for part in dotted.split("."):
        if not isinstance(node, dict) or part not in node:
            return KeyError
        node = node[part]
    return node


def main() -> int:
    data = yaml.safe_load(VALUES.read_text(encoding="utf-8")) or {}
    failures = []

    for path, alternative in CREDENTIAL_PATHS.items():
        value = resolve(data, path)
        if value is KeyError:
            failures.append(f"{path} is missing from values.yaml entirely")
        elif value not in ("", None):
            failures.append(
                f"{path} ships the value {value!r}; it must be empty and supplied "
                f"at install time, or via {alternative}"
            )
        else:
            print(f"  [ok] {path} ships no value")

    if failures:
        print(f"\n{len(failures)} credential problem(s) in {VALUES.name}:", file=sys.stderr)
        for failure in failures:
            print(f"  {failure}", file=sys.stderr)
        return 1

    print("\nThe chart ships no credential values.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
