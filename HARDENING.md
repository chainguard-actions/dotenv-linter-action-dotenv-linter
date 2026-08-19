<!-- markdownlint-disable -->

# Hardening Report: dotenv-linter--action-dotenv-linter/v2.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **dotenv-linter--action-dotenv-linter/v2.23.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes remote install scripts directly to `sh` without first downloading and verifying them. This allows a compromised or MITM'd remote server to execute arbitrary code on the runner. Affected lines:
- Line 11-12: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- ...`
- Line 16-17: `curl -sSfL https://raw.githubusercontent.com/dotenv-linter/dotenv-linter/master/install.sh | sh -s -- ...`

Locations:

- `script.sh:11`
- `script.sh:16`

### script-injection (severity: high)

Rule (b) violation: script.sh expands composite-action input env vars without double-quoting, allowing shell metacharacter injection. `${INPUT_DOTENV_LINTER_FLAGS}` and `${INPUT_REVIEWDOG_FLAGS}` are sourced from `inputs.dotenv_linter_flags` and `inputs.reviewdog_flags` respectively (set via the calling workflow's `env:` block in action.yml), and are used unquoted in shell commands. An attacker-controlled input value containing `;`, `|`, `&`, `$(...)`, or glob characters would be interpreted by the shell. Offending lines:
- `dotenv-linter fix --no-color ${INPUT_DOTENV_LINTER_FLAGS}` (line ~23)
- `${INPUT_REVIEWDOG_FLAGS} < "${TMPFILE}"` (line ~32)
- `dotenv-linter --quiet --no-color ${INPUT_DOTENV_LINTER_FLAGS}` (line ~38)
- `${INPUT_REVIEWDOG_FLAGS}` (line ~44)

Locations:

- `script.sh:23`
- `script.sh:32`
- `script.sh:38`
- `script.sh:44`

### unpinned-uses (severity: high)

All four workflow files use `uses:` references pinned to mutable tags or version strings rather than immutable 40-character commit SHAs. This exposes the workflows to supply-chain attacks if any referenced action's tag is moved or compromised. Unpinned references include:
- `actions/checkout@v4` (all 4 files)
- `haya14busa/action-depup@v1` (depup.yml)
- `peter-evans/create-pull-request@v6` (depup.yml)
- `haya14busa/action-bumpr@v1` (release.yml)
- `haya14busa/action-update-semver@v1` (release.yml)
- `haya14busa/action-cond@v1` (release.yml)
- `reviewdog/action-shellcheck@v1` (reviewdog.yml)
- `reviewdog/action-misspell@v1` (reviewdog.yml)
- `reviewdog/action-yamllint@v1` (reviewdog.yml)

Locations:

- `.github/workflows/ci.yml:8`
- `.github/workflows/depup.yml:10`
- `.github/workflows/release.yml:13`
- `.github/workflows/reviewdog.yml:8`

### missing-permissions (severity: medium)

None of the four workflow files define a top-level `permissions:` block, and no individual job within any of these files defines a `permissions:` block either. Without explicit permissions, workflows inherit the default repository token permissions (which may be broad), violating the principle of least privilege.

Locations:

- `.github/workflows/ci.yml:1`
- `.github/workflows/depup.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/reviewdog.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all 4 findings:

1. unsafe-shell (script.sh lines 11-12, 16-17): Replaced both `curl ... | sh -s -- ...` patterns with download-then-execute: curl downloads to a temp file, then `sh <tempfile> -b <path> <version>` executes it. The `--` shell option terminator was correctly dropped (it was the shell's, not the script's).

2. script-injection (script.sh lines 23, 32, 38, 44): Replaced unquoted `${INPUT_DOTENV_LINTER_FLAGS}` and `${INPUT_REVIEWDOG_FLAGS}` with xargs-based bash array tokenization (quote-aware, handles quoted subcommands). Arrays are expanded as `"${array[@]}"`. Changed shell from `sh` to `bash` in action.yml and updated the script shebang to `#!/bin/bash` since bash arrays and process substitution are required.

3. unpinned-uses: Pinned all 9 action references to full 40-char SHAs with tag comments: actions/checkout@11d5960a (v4), haya14busa/action-depup@99f7aecf (v1), peter-evans/create-pull-request@c5a7806 (v6), haya14busa/action-bumpr@faf6f474 (v1), haya14busa/action-update-semver@7d2c5586 (v1), haya14busa/action-cond@94f77f7a (v1), reviewdog/action-shellcheck@4c07458 (v1), reviewdog/action-misspell@d6429416 (v1), reviewdog/action-yamllint@de68272f (v1).

4. missing-permissions: Added top-level permissions blocks to all 4 workflows with minimal required permissions (ci.yml: contents:read; depup.yml: contents:write+pull-requests:write; release.yml: contents:write; reviewdog.yml: contents:read+pull-requests:write).

