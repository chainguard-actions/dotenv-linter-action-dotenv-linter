<!-- markdownlint-disable -->

# Hardening Report: dotenv-linter--action-dotenv-linter/v3.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **dotenv-linter--action-dotenv-linter/v3.0.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes remote install scripts directly to 'sh' via curl without first downloading to a file. Line 11-12: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- ...`. Line 16-17: `curl -sSfL https://raw.githubusercontent.com/dotenv-linter/dotenv-linter/master/install.sh | sh -s -- ...`. If the remote server is compromised or the URL is intercepted, arbitrary code executes immediately on the runner.

Locations:

- `script.sh:11`
- `script.sh:16`

### script-injection (severity: high)

Rule (b): Unquoted shell variable expansions of user-controlled inputs in script.sh. `${INPUT_DOTENV_LINTER_FLAGS}` (lines 26, 40) and `${INPUT_REVIEWDOG_FLAGS}` (lines 36, 45) are expanded without double-quotes, allowing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) in the input values to be interpreted by the shell. These variables are sourced from `inputs.dotenv_linter_flags` and `inputs.reviewdog_flags` respectively, which are fully attacker-controlled. The `# shellcheck disable=SC2086` comments acknowledge the unquoted expansion but do not mitigate the injection risk.

Locations:

- `script.sh:26`
- `script.sh:36`
- `script.sh:40`
- `script.sh:45`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed script.sh with two changes: (1) unsafe-shell: Replaced both `curl | sh` pipe patterns with download-to-tempfile-then-execute patterns using `curl -o <tempfile>` followed by `sh <tempfile>`, then cleanup with `rm -f`. This prevents arbitrary code execution if the remote server is compromised. (2) script-injection: Added double-quotes around all four unquoted expansions of `${INPUT_DOTENV_LINTER_FLAGS}` (lines 26, 40) and `${INPUT_REVIEWDOG_FLAGS}` (lines 36, 45), preventing shell metacharacter injection from attacker-controlled input values. The `# shellcheck disable=SC2086` comments were removed as they are no longer needed.

