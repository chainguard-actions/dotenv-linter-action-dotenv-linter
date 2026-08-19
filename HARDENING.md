<!-- markdownlint-disable -->

# Hardening Report: dotenv-linter--action-dotenv-linter/v3.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **dotenv-linter--action-dotenv-linter/v3.0.0** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes remote content directly to a shell interpreter in two places. Line 11-12: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b ...` and line 16-17: `curl -sSfL https://raw.githubusercontent.com/dotenv-linter/dotenv-linter/master/install.sh | sh -s -- -b ...`. An attacker who can intercept or tamper with the remote URL (e.g., via a compromised CDN or MITM) can execute arbitrary code on the runner. The script should be downloaded to a file first, its integrity verified (e.g., checksum), and then executed separately.

Locations:

- `script.sh:11`
- `script.sh:16`

### unpinned-uses (severity: high)

All workflow files reference GitHub Actions using mutable version tags instead of pinned 40-character commit SHAs. If any of these actions are compromised or their tags are moved, malicious code could be injected into the workflow. Failing references include: `actions/checkout@v6` (ci.yml, depup.yml, release.yml, reviewdog.yml), `haya14busa/action-depup@v1` (depup.yml), `peter-evans/create-pull-request@v8` (depup.yml), `haya14busa/action-bumpr@v1` (release.yml), `haya14busa/action-update-semver@v1` (release.yml), `haya14busa/action-cond@v1` (release.yml), `reviewdog/action-shellcheck@v1` (reviewdog.yml), `reviewdog/action-misspell@v1` (reviewdog.yml), `reviewdog/action-yamllint@v1` (reviewdog.yml). Each should be pinned to a full SHA, e.g. `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4`.

Locations:

- `.github/workflows/ci.yml:6`
- `.github/workflows/depup.yml:9`
- `.github/workflows/release.yml:8`
- `.github/workflows/reviewdog.yml:7`

### missing-permissions (severity: medium)

None of the four workflow files define a top-level `permissions:` block, and no individual job defines its own `permissions:` block. Without explicit permissions, workflows run with the repository's default token permissions, which may be overly broad (e.g., write access to contents, pull-requests, etc.). Each workflow should declare the minimum required permissions explicitly.

Locations:

- `.github/workflows/ci.yml:1`
- `.github/workflows/depup.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/reviewdog.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, missing-permissions

**Notes:**

1. script.sh: Fixed two curl-pipe-to-shell patterns by downloading each install script to a temp file with curl -o, executing the file separately with sh, then removing it. 2. All workflow files: Pinned all actions/checkout@v6 references to actions/checkout@11d5960a326750d5838078e36cf38b85af677262 # v4, and pinned all other action references (haya14busa/action-depup, peter-evans/create-pull-request, haya14busa/action-bumpr, haya14busa/action-update-semver, haya14busa/action-cond, reviewdog/action-shellcheck, reviewdog/action-misspell, reviewdog/action-yamllint) to their respective full commit SHAs. 3. Added top-level permissions blocks to all four workflow files with minimum required permissions: ci.yml and reviewdog.yml get contents:read + pull-requests:write; depup.yml and release.yml get contents:write + pull-requests:write.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed all four unquoted variable expansions in hardened/action/script.sh:
1. `dotenv-linter fix --plain ${INPUT_DOTENV_LINTER_FLAGS} .` → `dotenv-linter fix --plain "${INPUT_DOTENV_LINTER_FLAGS}" .`
2. `${INPUT_REVIEWDOG_FLAGS} < "${TMPFILE}"` → `"${INPUT_REVIEWDOG_FLAGS}" < "${TMPFILE}"`
3. `dotenv-linter check --quiet --plain ${INPUT_DOTENV_LINTER_FLAGS} .` → `dotenv-linter check --quiet --plain "${INPUT_DOTENV_LINTER_FLAGS}" .`
4. `${INPUT_REVIEWDOG_FLAGS}` at end of reviewdog pipe → `"${INPUT_REVIEWDOG_FLAGS}"`

Also removed the `# shellcheck disable=SC2086` comments that were explicitly acknowledging the unquoted expansions. The variables are now properly double-quoted, preventing shell metacharacter injection from user-controlled action inputs.

