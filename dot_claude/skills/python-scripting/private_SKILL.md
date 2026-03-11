---
name: python-scripting
description: >
  Apply this skill whenever the user asks to create, write, scaffold, or generate a new Python
  script or project. Triggers include: "write a Python script", "create a Python tool", "make a
  CLI in Python", "scaffold a Python project", or any request to produce new Python code as a
  deliverable. Encodes Will's preferred conventions: Python 3.13+, uv with PEP 723 inline
  metadata, src/ layout, ruff for formatting/linting, ty for type-checking, and pytest.
---

# Python Scripting Conventions

This skill encodes preferred conventions for creating new Python scripts and projects.

## Toolchain

| Tool | Role |
|------|------|
| **uv** | Package manager and script runner |
| **ruff** | Linting and formatting (replaces black, isort, flake8) |
| **ty** | Static type checking (Astral's type checker, replaces mypy) |
| **pytest** | Testing framework |

## Python Version

Always target **Python 3.13+**. Use modern language features freely:
- `match` statements over long `if/elif` chains
- `X | Y` union type syntax instead of `Optional[X]` or `Union[X, Y]`
- `tomllib` from stdlib for TOML parsing
- `pathlib.Path` over `os.path`

---

## Project Structure: src/ Layout

For any project with more than one module or that will be installed/imported:

```
my-project/
├── pyproject.toml
├── src/
│   └── my_project/
│       ├── __init__.py
│       └── main.py
├── tests/
│   ├── __init__.py
│   └── test_main.py
└── README.md
```

For **single-file scripts** that are truly standalone utilities, use PEP 723 inline metadata (see below) instead of a full project layout.

---

## Dependency Management: uv + PEP 723

### Single-file scripts (preferred for utilities)

Use [PEP 723 inline script metadata](https://peps.python.org/pep-0723/):

```python
#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.13"
# dependencies = [
#   "httpx>=0.27",
#   "rich>=13",
# ]
# ///

"""One-line description of what this script does."""

import httpx
from rich.console import Console
```

Run with: `uv run script.py` — no venv setup required.

### Multi-module projects

Use `pyproject.toml` managed by uv:

```toml
[project]
name = "my-project"
version = "0.1.0"
requires-python = ">=3.13"
dependencies = [
    "httpx>=0.27",
]

[project.scripts]
my-project = "my_project.main:main"

[tool.uv]
dev-dependencies = [
    "ty>=0.0.1a1",
    "pytest>=8",
    "ruff>=0.4",
]

[tool.ruff]
line-length = 88
target-version = "py313"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B", "SIM"]

[tool.pytest.ini_options]
testpaths = ["tests"]
```

Initialize with: `uv init --lib my-project` then edit as needed.

---

## Code Style

### Formatting (ruff)

- Enforce import sorting (`I`), pyupgrade (`UP`), flake8-bugbear (`B`), flake8-simplify (`SIM`)
- Run: `uv run ruff format . && uv run ruff check --fix .`

### Type Hints — Strict
All code must pass `ty check` (Astral's type checker). This means:
- Every function parameter and return type annotated
- No bare `Any` unless absolutely unavoidable (add `# type: ignore[misc]` with a comment explaining why)
- Use `TypeAlias`, `TypeVar`, `Protocol`, `dataclass`, or `TypedDict` for complex types
- Prefer `dataclasses.dataclass` or `pydantic.BaseModel` over raw dicts for structured data

```python
# Good
def fetch_items(url: str, timeout: float = 30.0) -> list[str]:
    ...

# Bad — missing annotations
def fetch_items(url, timeout=30):
    ...
```

### General conventions
- Docstrings on all public functions, classes, and modules (one-line for simple, Google-style for complex)
- `if __name__ == "__main__":` guard in all runnable scripts
- Use `click` for all CLI argument parsing — always, for consistency
- Prefer `logging` over `print` for anything beyond quick debugging
- Exceptions should be specific — avoid bare `except Exception`

---

## Testing: pytest

- Tests live in `tests/`, mirroring `src/` structure
- Test files named `test_<module>.py`
- Use fixtures liberally; avoid global state in tests
- Prefer `pytest.mark.parametrize` for data-driven tests
- Mock external I/O (HTTP, filesystem, subprocess) — don't make real network calls in tests

```python
# Example
import pytest
from my_project.main import parse_args

@pytest.mark.parametrize("args,expected", [
    (["--count", "3"], 3),
    ([], 1),
])
def test_parse_args(args: list[str], expected: int) -> None:
    result = parse_args(args)
    assert result.count == expected
```

---

## Checklist for New Scripts

Before delivering any Python script or project:

- [ ] PEP 723 inline metadata (single-file) or `pyproject.toml` (multi-module)
- [ ] `requires-python = ">=3.13"` specified
- [ ] All functions/methods fully type-annotated
- [ ] Would pass `ty check`
- [ ] Would pass `ruff format --check` and `ruff check`
- [ ] `if __name__ == "__main__":` guard present in runnable scripts
- [ ] At least a stub `tests/` structure for multi-module projects
