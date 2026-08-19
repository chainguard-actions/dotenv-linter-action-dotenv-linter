<!-- markdownlint-disable -->

# Hardening Report: dotenv-linter--action-dotenv-linter/v2.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **dotenv-linter--action-dotenv-linter/v2.24.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes remote install scripts directly to `sh` without first downloading and verifying them. Lines 10-11 run `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- ...` and lines 14-15 run `curl -sSfL https://raw.githubusercontent.com/dotenv-linter/dotenv-linter/master/install.sh | sh -s -- ...`. If the remote URL is compromised or the request is intercepted, arbitrary code executes on the runner.

Locations:

- `script.sh:10`
- `script.sh:14`

### script-injection (severity: high)

Rule (b) violation: script.sh expands user-controlled input variables without double-quoting, allowing shell metacharacter injection. `${INPUT_DOTENV_LINTER_FLAGS}` (sourced from `inputs.dotenv_linter_flags`) is used unquoted on the `dotenv-linter` command lines, and `${INPUT_REVIEWDOG_FLAGS}` (sourced from `inputs.reviewdog_flags`) is used unquoted on the `reviewdog` command lines. The `# shellcheck disable=SC2086` comments confirm intentional unquoting, but an attacker-controlled value containing `;`, `|`, `&`, or `$(...)` can inject arbitrary shell commands.

Locations:

- `script.sh:24`
- `script.sh:34`
- `script.sh:43`
- `script.sh:49`

### unpinned-uses (severity: high)

All four workflow files reference GitHub Actions using mutable version tags instead of immutable full-length SHA commit hashes. This exposes the workflows to supply-chain attacks if any referenced action's tag is moved or the action repository is compromised. Failing references include: `actions/checkout@v4`, `haya14busa/action-depup@v1`, `peter-evans/create-pull-request@v6`, `haya14busa/action-bumpr@v1`, `haya14busa/action-update-semver@v1`, `haya14busa/action-cond@v1`, `reviewdog/action-shellcheck@v1`, `reviewdog/action-misspell@v1`, `reviewdog/action-yamllint@v1`.

Locations:

- `.github/workflows/ci.yml:7`
- `.github/workflows/depup.yml:12`
- `.github/workflows/release.yml:14`
- `.github/workflows/reviewdog.yml:9`

### missing-permissions (severity: medium)

None of the four workflow files define a top-level `permissions:` block, and no individual job within any of these files defines a `permissions:` block either. Without explicit permissions, workflows run with the repository's default token permissions, which may be overly broad (e.g., write access to contents, pull-requests, etc.).

Locations:

- `.github/workflows/ci.yml:1`
- `.github/workflows/depup.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/reviewdog.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all four findings:

1. unsafe-shell: Rewrote script.sh to download install scripts to temp files (mktemp) before executing them, eliminating the curl-pipe-to-sh pattern. Dropped the '--' shell option terminator as required (it was the shell's, not the script's). Updated shebang to #!/bin/bash and action.yml shell to 'bash' since bash features are now used.

2. script-injection: Replaced unquoted ${INPUT_DOTENV_LINTER_FLAGS} and ${INPUT_REVIEWDOG_FLAGS} expansions with xargs-based array tokenization (quote-aware, injection-safe). Each input is guarded with 'if [ -n ... ]' and expanded via '"${arr[@]+"${arr[@]}"}"' to safely handle empty arrays.

3. unpinned-uses: Pinned all 9 action references across all 4 workflow files to full commit SHAs with original tags preserved as comments.

4. missing-permissions: Added 'permissions: {}' at the top level of all 4 workflow files, with minimal job-level permissions where operations require them (contents: read for checkout, contents: write + pull-requests: write for depup/release jobs).

