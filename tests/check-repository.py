#!/usr/bin/env python3
"""Check public-package boundaries and relative Markdown links, without ITK."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
errors = []
for path in root.rglob('*'):
    if '.git' in path.parts or not path.is_file():
        continue
    if path.suffix.lower() in {'.exe', '.msi', '.sys', '.dll', '.bio', '.rom', '.vdi', '.iso', '.qcow2'}:
        errors.append(f'Private/binary artifact in source: {path.relative_to(root)}')
    if path.suffix == '.md':
        for target in re.findall(r'\]\(([^)]+)\)', path.read_text()):
            if '://' in target or target.startswith('#'):
                continue
            relative = target.split('#', 1)[0]
            if relative and not (path.parent / relative).exists():
                errors.append(f'Broken local link: {path.relative_to(root)} -> {target}')
if errors:
    raise SystemExit('\n'.join(errors))
print('PASS: public artifact boundaries and local Markdown links.')
