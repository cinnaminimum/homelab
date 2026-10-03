from pathlib import Path
from subprocess import run
from sys import stderr, stdin, stdout

BUILD_DIR = "build/docs"
COLLECTION = "cinnaminimum.homelab"
COPYRIGHT = "Gerald Ya Ya"


def _run(*args, **kwargs):
    return run(*args, stdout=stdout, stderr=stderr, stdin=stdin, check=True, **kwargs)


def main():
    build_dir = Path(BUILD_DIR)
    build_dir.mkdir(parents=True, exist_ok=True, mode=0o755)

    pyproject = build_dir / "pyproject.toml"
    if not pyproject.exists():
        with pyproject.open("w") as f:
            f.write("[project]\n")
            f.write('name = "cinnaminimum.homelab"\n')
            f.write('version = "0.0.0"')

    # documentation_home_url changes the top-left-most link from / to index.html
    # https://github.com/ansible-community/sphinx_ansible_theme/blob/eaaabfbba3e8fd1ed5d2ebf6a15f3fcf23974315/src/sphinx_ansible_theme/extrabody.html#L20
    _run(
        [
            "antsibull-docs",
            "sphinx-init",
            "--use-current",
            "--squash-hierarchy",
            "--extra-html-theme-options",
            "documentation_home_url=index.html",
            "--copyright",
            COPYRIGHT,
            "--dest-dir",
            BUILD_DIR,
            COLLECTION,
        ]
    )

    venv = build_dir / ".venv"
    if not venv.exists():
        _run(["uv", "venv"], cwd=build_dir)

    _run(["uv", "add", "--requirements", "requirements.txt"], cwd=build_dir)

    _run(["uv", "run", "bash", "build.sh"], cwd=build_dir)


if __name__ == "__main__":
    main()
