#!/usr/bin/env python3
"""Discover loaded skills → AGENTS.md Skills section.

Scans a skills directory for SKILL.md files, extracts name + description
from YAML frontmatter, and outputs a Markdown Skills section ready to
insert into AGENTS.md.

Agent-agnostic: works with any AI coding agent that organizes skills as
directories containing a SKILL.md file with YAML frontmatter.

Usage:
    python detect-skills.py /path/to/skills-dir
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


def _read_safe(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return ""


def _parse_frontmatter(text: str) -> dict[str, str]:
    """Extract YAML frontmatter fields from a SKILL.md file.

    Tolerates optional code-fence wrappers (```skill) before the opening ---.
    """
    # Strip leading code-fence lines (e.g. ```skill)
    stripped = re.sub(r"^```\w*\s*\n", "", text)
    m = re.match(r"^---\s*\n(.*?)\n---", stripped, re.DOTALL)
    if not m:
        return {}
    fields: dict[str, str] = {}
    for line in m.group(1).splitlines():
        km = re.match(r'^(\w+):\s*["\']?(.*?)["\']?\s*$', line)
        if km:
            fields[km.group(1)] = km.group(2)
    return fields


def discover_skills(skills_dir: Path) -> list[dict[str, str]]:
    """Return list of {name, description} for each SKILL.md found."""
    if not skills_dir.is_dir():
        return []
    skills: list[dict[str, str]] = []
    for child in sorted(skills_dir.iterdir()):
        sm = child / "SKILL.md"
        if not sm.is_file():
            continue
        fm = _parse_frontmatter(_read_safe(sm))
        name = fm.get("name", child.name)
        desc = fm.get("description", "")
        if name:
            skills.append({"name": name, "description": desc})
    return skills


def render(skills: list[dict[str, str]]) -> str:
    """Generate the ## Skills markdown section."""
    lines = [
        "## Skills",
        "",
        "> **MANDATORY**: Before starting ANY task, inspect your loaded skills and "
        "execute every skill that matches. Skills override your general knowledge "
        "— they are the primary source of truth for framework conventions.",
        "",
    ]
    if skills:
        lines += ["| Skill | When & Why |", "|-------|------------|"]
        for s in skills:
            # Synthesize a concise one-liner from the raw description
            desc = s["description"]
            if len(desc) > 200:
                desc = desc[:197] + "..."
            lines.append(f"| `{s['name']}` | {desc} |")
    else:
        lines += [
            "No skills found in the provided directory.",
            "Verify that skills are installed and the path is correct.",
        ]
    lines += [
        "",
        "If a required skill is not loaded, inform the user before proceeding "
        "— do not substitute with general knowledge.",
    ]
    return "\n".join(lines)


if __name__ == "__main__":
    p = argparse.ArgumentParser(
        description="Discover loaded skills → Markdown Skills section for AGENTS.md"
    )
    p.add_argument("skills_dir", help="Directory containing installed skills (each as a subdirectory with SKILL.md)")
    args = p.parse_args()

    skills_dir = Path(args.skills_dir).resolve()
    if not skills_dir.is_dir():
        print(f"Error: {skills_dir} is not a directory", file=sys.stderr)
        sys.exit(1)

    skills = discover_skills(skills_dir)
    if not skills:
        print(f"Warning: no skills found in {skills_dir}", file=sys.stderr)

    print(render(skills))
