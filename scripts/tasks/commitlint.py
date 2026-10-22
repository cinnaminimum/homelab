from os import environ
from subprocess import run
from sys import argv, exit, stderr, stdin, stdout


FIRST_COMMIT = "99d2ec2a9bcd0545650105b36ac414d59bb6b003"


def main(args_in: list[str]) -> None:
    args_out = ["mise", "run", "commitlint"]
    match environ.get("FORGEJO_EVENT_NAME"):
        case "pull_request":
            print("Linting pull requests...")
            args_out = args_out + [
                "--from",
                environ["COMMITLINT_FROM"],
                "--to",
                environ["COMMITLINT_TO"],
                "--verbose",
            ]
        case "push":
            print("Linting push commits...")
            args_out = args_out + ["--last", "--verbose"]
        case _:
            if len(args_in) == 0:
                print("Linting all commits...")
                args_out = args_out + ["--from", FIRST_COMMIT, "--verbose"]
            else:
                args_out = args_out + args_in

    env = environ | {
        "GIT_CONFIG_COUNT": "1",
        "GIT_CONFIG_KEY_0": "log.showSignature",
        "GIT_CONFIG_VALUE_0": "false",
    }

    process = run(args_out, env=env, stdin=stdin, stdout=stdout, stderr=stderr, check=False)
    exit(process.returncode)


if __name__ == "__main__":
    main(argv[1:])
