<!-- markdownlint-disable -->

# Hardening Report: dotenv-linter--action-dotenv-linter/v2.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **dotenv-linter--action-dotenv-linter/v2.23.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes remote content directly to a shell interpreter in two places. Line 11-12: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- ...` and line 16-17: `curl -sSfL https://raw.githubusercontent.com/dotenv-linter/dotenv-linter/master/install.sh | sh -s -- ...`. If the remote URL is compromised or the connection is intercepted, arbitrary code will be executed on the runner.

Locations:

- `script.sh:11`
- `script.sh:16`

### script-injection (severity: high)

Rule (b) violation: Unquoted shell variable expansions of untrusted input-derived env vars in script.sh. `${INPUT_DOTENV_LINTER_FLAGS}` (sourced from `inputs.dotenv_linter_flags`) and `${INPUT_REVIEWDOG_FLAGS}` (sourced from `inputs.reviewdog_flags`) are expanded without double-quotes, allowing an attacker to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) via the action inputs. Affected lines: line 26 (`dotenv-linter fix --no-color ${INPUT_DOTENV_LINTER_FLAGS}`), line 38 (`${INPUT_REVIEWDOG_FLAGS} < "${TMPFILE}"`), line 42 (`dotenv-linter --quiet --no-color ${INPUT_DOTENV_LINTER_FLAGS}`), line 47 (`${INPUT_REVIEWDOG_FLAGS}`). The `# shellcheck disable=SC2086` comments confirm the author was aware of the unquoted expansions but did not treat them as a security concern.

Locations:

- `script.sh:26`
- `script.sh:38`
- `script.sh:42`
- `script.sh:47`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed script.sh with two changes: (1) unsafe-shell: Replaced both `curl ... | sh -s -- ...` patterns with a download-then-execute approach — each install script is downloaded to a temp file with `curl -o`, executed with `sh`, then removed. (2) script-injection: Double-quoted all four unquoted variable expansions of `${INPUT_DOTENV_LINTER_FLAGS}` (lines 26, 42) and `${INPUT_REVIEWDOG_FLAGS}` (lines 38, 47), and removed the `# shellcheck disable=SC2086` comments that were suppressing the warnings.

