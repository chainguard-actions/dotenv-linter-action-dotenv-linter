<!-- markdownlint-disable -->

# Hardening Report: dotenv-linter--action-dotenv-linter/v2.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **dotenv-linter--action-dotenv-linter/v2.24.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh downloads remote install scripts and pipes them directly to `sh` without first saving to a file. This allows a compromised or malicious remote server to execute arbitrary code on the runner. Offending lines:
- Line 11-12: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- ...`
- Line 16-17: `curl -sSfL https://raw.githubusercontent.com/dotenv-linter/dotenv-linter/master/install.sh | sh -s -- ...`

Locations:

- `script.sh:11`
- `script.sh:16`

### script-injection (severity: high)

Rule (b) violation: Unquoted shell variable expansions of untrusted (user-controlled) input values in script.sh. The variables `${INPUT_DOTENV_LINTER_FLAGS}` and `${INPUT_REVIEWDOG_FLAGS}` are sourced from `inputs.dotenv_linter_flags` and `inputs.reviewdog_flags` respectively, and are expanded unquoted in shell commands. This allows shell metacharacter injection (`;`, `|`, `&`, `$(...)`, etc.). The `# shellcheck disable=SC2086` comments confirm the unquoted usage is intentional but it remains a security risk. Offending usages:
- Line 24: `dotenv-linter fix --no-color ${INPUT_DOTENV_LINTER_FLAGS}` (unquoted)
- Line 33: `${INPUT_REVIEWDOG_FLAGS} < "${TMPFILE}"` (unquoted)
- Line 39: `dotenv-linter --quiet --no-color ${INPUT_DOTENV_LINTER_FLAGS} \` (unquoted)
- Line 44: `${INPUT_REVIEWDOG_FLAGS}` (unquoted)

Locations:

- `script.sh:24`
- `script.sh:33`
- `script.sh:39`
- `script.sh:44`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed script.sh: (1) unsafe-shell: replaced `curl | sh` patterns with download-to-tempfile then execute separately for both reviewdog and dotenv-linter install scripts; (2) script-injection: replaced unquoted ${INPUT_DOTENV_LINTER_FLAGS} and ${INPUT_REVIEWDOG_FLAGS} expansions with bash arrays (read -ra ARRAY <<< "$VAR") expanded as "${ARRAY[@]+"${ARRAY[@]}"}" to safely handle empty and non-empty flag lists without shell metacharacter injection. Changed shebang from #!/bin/sh to #!/bin/bash and updated action.yml shell from 'sh' to 'bash' to support bash array features.

