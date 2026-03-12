# Instructions for GitHub Copilot

## General

- `awk` is not available on the target platform.
- `jq` is available on the target platform.

## For shell scripts

- Use `/bin/sh` only for shell scripts (POSIX shell).
- Do not use Bash.
- Assume BusyBox utilities, not extended GNU utilities.
- Prefer POSIX-compatible flags and options in all shell commands.
- For if-statements without else, prefer `[ "$FOO" ] || { echo 'There is no FOO'; }` over `if [ -z "$FOO" ]; then echo 'There is no FOO'; fi`.
- Prefer `[ "$FOO" ]` over `[ -n "$FOO" ]` for checking if a variable is non-empty.
- Use double quotes only when there is variable expansion; use single quotes for static strings.
- Never use braces around variable names unless there is a substitution or to prevent ambiguity (e.g., `${FOO}bar`).
- Wrap comments to not exceed 80 characters per line.
- Do not use consecutive echo commands; use a single echo with newlines instead.

## For Dockerfiles

- Use SHELL ["/bin/bash", "-o", "pipefail", "-c"] for better error handling (only when needed/applicable though!), but do not use bash-specific features in the commands.
