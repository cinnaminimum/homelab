from pathlib import Path
from subprocess import run
from sys import stderr, stdin, stdout

from yaml import safe_load


def main() -> None:
    with open("galaxy.yml") as f:
        galaxy = safe_load(f)

    run(
        [
            "ansible-galaxy",
            "collection",
            "install",
            "--force",
            Path("build") / f"cinnaminimum-homelab-{galaxy['version']}.tar.gz",
        ],
        check=True,
        stderr=stderr,
        stdin=stdin,
        stdout=stdout,
    )


if __name__ == "__main__":
    main()
