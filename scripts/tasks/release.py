# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "pyyaml>=6.0.3",
# ]
# ///
from os import environ
from pathlib import Path
from subprocess import run
from sys import stderr, stdin, stdout

from yaml import safe_load


def _run(*args, **kwargs):
    run(*args, check=True, stderr=stderr, stdin=stdin, stdout=stdout, **kwargs)


def main():
    token = environ["HOMELAB_ANSIBLE_GALAXY_TOKEN"]

    with open("galaxy.yml") as f:
        galaxy = safe_load(f)

    version = galaxy["version"]
    message = f"chore: Release v{version}"
    print(message)

    _run(["antsibull-changelog", "release"])
    _run(["antsibull-changelog", "generate"])
    _run(["git", "add", "."])
    _run(["git", "commit", "-m", message])
    _run(["git", "tag", f"v{version}", "-m", message])

    _run(["mise", "run", "build"])
    build = Path("build", f"{galaxy['namespace']}-{galaxy['name']}-{version}.tar.gz")
    print(f"Uploading {build}")

    _run(["ansible-galaxy", "collection", "publish", "--token", token, str(build)])

    print(f"Released v{version}")
    print("Be sure to push commit and tag")


if __name__ == "__main__":
    main()
