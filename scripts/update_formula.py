#!/usr/bin/env python3
"""Update the Homebrew formula to the latest PyPI release of chszlablib."""
import hashlib
import json
import re
import sys
import urllib.request
from pathlib import Path

FORMULA = Path(__file__).resolve().parent.parent / "Formula" / "chszlablib.rb"
PYPI_URL = "https://pypi.org/pypi/chszlablib/json"
GITHUB_TARBALL = "https://github.com/CHSZLab/CHSZLabLib/archive/refs/tags/v{version}.tar.gz"

# Regexes for the wheel file names (the macOS deployment target in the name can change).
WHEEL_PATTERNS = {
    "macos_arm": r"cp313-cp313-macosx_\d+_\d+_arm64\.whl$",
    "linux_x64": r"cp313-cp313-manylinux_2_27_x86_64\.manylinux_2_28_x86_64\.whl$",
}


def get_pypi_info():
    data = json.loads(urllib.request.urlopen(PYPI_URL).read())
    version = data["info"]["version"]
    wheels = {}
    for f in data["urls"]:
        for key, pattern in WHEEL_PATTERNS.items():
            if re.search(pattern, f["filename"]):
                wheels[key] = {"url": f["url"], "sha256": f["digests"]["sha256"]}
    return version, wheels


def get_github_sha(version):
    url = GITHUB_TARBALL.format(version=version)
    data = urllib.request.urlopen(url).read()
    return hashlib.sha256(data).hexdigest()


def get_current_version():
    text = FORMULA.read_text()
    m = re.search(r'url "https://github\.com/CHSZLab/CHSZLabLib/archive/refs/tags/v(.+?)\.tar\.gz"', text)
    return m.group(1) if m else None


def update_formula(version, github_sha, wheels):
    text = FORMULA.read_text()

    # Update main URL and SHA
    text = re.sub(
        r'(url "https://github\.com/CHSZLab/CHSZLabLib/archive/refs/tags/v).+?(\.tar\.gz")',
        rf"\g<1>{version}\g<2>",
        text,
    )
    text = re.sub(
        r'(url "https://github\.com/CHSZLab/CHSZLabLib/archive/refs/tags/v.+?\.tar\.gz"\n\s+sha256 ")[a-f0-9]+(")',
        rf"\g<1>{github_sha}\g<2>",
        text,
    )

    # Update macOS ARM wheel
    if "macos_arm" in wheels:
        w = wheels["macos_arm"]
        text = re.sub(
            r'(resource "chszlablib-whl" do\n\s+url ")https://[^"]+macosx_\d+_\d+_arm64\.whl(")',
            rf'\g<1>{w["url"]}\g<2>',
            text,
        )
        text = re.sub(
            r'(url "[^"]+macosx_\d+_\d+_arm64\.whl"[^\n]*\n\s+sha256 ")[a-f0-9]+(")',
            rf'\g<1>{w["sha256"]}\g<2>',
            text,
        )

    # Update Linux x64 wheel
    if "linux_x64" in wheels:
        w = wheels["linux_x64"]
        text = re.sub(
            r'(resource "chszlablib-whl" do\n\s+url ")https://[^"]+manylinux_2_27_x86_64\.manylinux_2_28_x86_64\.whl(")',
            rf'\g<1>{w["url"]}\g<2>',
            text,
        )
        text = re.sub(
            r'(url "[^"]+manylinux_2_27_x86_64\.manylinux_2_28_x86_64\.whl"[^\n]*\n\s+sha256 ")[a-f0-9]+(")',
            rf'\g<1>{w["sha256"]}\g<2>',
            text,
        )

    FORMULA.write_text(text)


def main():
    current = get_current_version()
    latest, wheels = get_pypi_info()

    if current == latest:
        print(f"Already up to date: {current}")
        sys.exit(0)

    if not wheels.get("macos_arm") or not wheels.get("linux_x64"):
        print(f"Missing wheels for {latest}, skipping update")
        sys.exit(1)

    print(f"Updating {current} -> {latest}")
    github_sha = get_github_sha(latest)
    update_formula(latest, github_sha, wheels)
    print(f"Formula updated to {latest}")
    sys.exit(0)


if __name__ == "__main__":
    main()
