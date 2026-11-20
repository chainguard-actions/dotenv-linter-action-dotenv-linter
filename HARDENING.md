<!-- markdownlint-disable -->

# Hardening Report: dotenv-linter--action-dotenv-linter/v3.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **dotenv-linter--action-dotenv-linter/v3.0.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh (run by the composite action) downloads reviewdog's install.sh from the mutable master branch and pipes it straight into sh: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}"`. Download the script to a file first, check it against a pinned commit or checksum, then run it.

Locations:

- `script.sh:11`

### unsafe-shell (severity: high)

script.sh downloads dotenv-linter's install.sh from the mutable master branch and pipes it straight into sh: `curl -sSfL https://raw.githubusercontent.com/dotenv-linter/dotenv-linter/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${DOTENV_LINTER_VERSION}"`. Download the script to a file first, check it against a pinned commit or checksum, then run it.

Locations:

- `script.sh:16`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/action.yml b/action.yml
index ac5ec47..9f965b8 100644
--- a/action.yml
+++ b/action.yml
@@ -1,5 +1,5 @@
 name: 'Run dotenv-linter with reviewdog'
-description: '🐶 Run dotenv-linter with reviewdog on pull requests to improve code review experience.'
+description: "\U0001F436 Run dotenv-linter with reviewdog on pull requests to improve code review experience."
 author: 'mgrachev (reviewdog)'
 inputs:
   github_token:
@@ -33,6 +33,23 @@ inputs:
 runs:
   using: 'composite'
   steps:
     - run: $GITHUB_ACTION_PATH/script.sh
       shell: sh
       env:

```

Locations:

- `action.yml`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed script.sh without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/script.sh b/script.sh
index e7f85a1..33abd58 100755
--- a/script.sh
+++ b/script.sh
@@ -8,13 +8,19 @@ TEMP_PATH="$(mktemp -d)"
 PATH="${TEMP_PATH}:$PATH"
 
 echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
+REVIEWDOG_INSTALL_SCRIPT="$(mktemp)"
 curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh \
-  | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
+  -o "${REVIEWDOG_INSTALL_SCRIPT}"
+sh "${REVIEWDOG_INSTALL_SCRIPT}" -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
+rm -f "${REVIEWDOG_INSTALL_SCRIPT}"
 echo '::endgroup::'
 
 echo '::group::⚡️ Installing dotenv-linter ... https://github.com/dotenv-linter/dotenv-linter'
+DOTENV_LINTER_INSTALL_SCRIPT="$(mktemp)"
 curl -sSfL https://raw.githubusercontent.com/dotenv-linter/dotenv-linter/master/install.sh \
-  | sh -s -- -b "${TEMP_PATH}" "${DOTENV_LINTER_VERSION}" 2>&1
+  -o "${DOTENV_LINTER_INSTALL_SCRIPT}"
+sh "${DOTENV_LINTER_INSTALL_SCRIPT}" -b "${TEMP_PATH}" "${DOTENV_LINTER_VERSION}" 2>&1
+rm -f "${DOTENV_LINTER_INSTALL_SCRIPT}"
 echo '::endgroup::'
 
 export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"
@@ -22,15 +28,13 @@ export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"
 if [ "${INPUT_REPORTER}" = "github-code-suggestions" ]
 then
       echo '::group::Running ⚡️ dotenv-linter with code suggestions 🐶 ...'
-      # shellcheck disable=SC2086
-      dotenv-linter fix --plain ${INPUT_DOTENV_LINTER_FLAGS} .
+      dotenv-linter fix --plain "${INPUT_DOTENV_LINTER_FLAGS}" .
 
       TMPFILE=$(mktemp)
       git diff > "${TMPFILE}"
       git stash -u || true
       git stash drop || true
 
-      # shellcheck disable=SC2086
       reviewdog \
         -name="${INPUT_TOOL_NAME}" \
         -f=diff \
@@ -38,17 +42,16 @@ then
         -reporter="github-pr-review" \
         -filter-mode="${INPUT_FILTER_MODE}" \
         -fail-level="${INPUT_FAIL_LEVEL}" \
-        ${INPUT_REVIEWDOG_FLAGS} < "${TMPFILE}"
+        "${INPUT_REVIEWDOG_FLAGS}" < "${TMPFILE}"
 else
       echo '::group::Running ⚡️ dotenv-linter with reviewdog 🐶 ...'
-      # shellcheck disable=SC2086
-      dotenv-linter check --quiet --plain ${INPUT_DOTENV_LINTER_FLAGS} . \
+      dotenv-linter check --quiet --plain "${INPUT_DOTENV_LINTER_FLAGS}" . \
         | reviewdog -f=dotenv-linter \
           -name="${INPUT_TOOL_NAME}" \
           -reporter="${INPUT_REPORTER}" \
           -filter-mode="${INPUT_FILTER_MODE}" \
           -fail-level="${INPUT_FAIL_LEVEL}" \
-          ${INPUT_REVIEWDOG_FLAGS}
+          "${INPUT_REVIEWDOG_FLAGS}"
 fi
 
 EXIT_CODE=$?

```

Locations:

- `script.sh`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, prior-fix

**Notes:**

script.sh used to pipe both reviewdog's and dotenv-linter's install.sh from master straight into sh. It now downloads each script into a temp file and runs it with sh. The '-s --' is gone and the arguments '-b "$TEMP_PATH" "$VERSION"' are kept. Each URL is now pinned to a commit instead of master: reviewdog df70ed74df59de7ebfd9276afabd62ea2de4d7dd (tag v0.21.0) and dotenv-linter f9076b02daed89f54ed0bd23951a4cfa5ccceac4 (tag v4.0.0). These match the REVIEWDOG_VERSION and DOTENV_LINTER_VERSION the action installs. I didn't check that install.sh exists at the dotenv-linter commit. If it doesn't, curl -f will fail and the step will stop. I didn't add a checksum check; the commit pin is the only integrity control. Prior-fix items: I re-applied the download-to-file change. I did not re-apply quoting of INPUT_DOTENV_LINTER_FLAGS and INPUT_REVIEWDOG_FLAGS. Those inputs are whitespace-separated flag lists that upstream deliberately expands unquoted from env vars. Quoting them would merge several flags into one argument, and an unquoted env var expansion is not script injection. The previous action.yml change only re-encoded the emoji in the description, which has no security effect, so I left action.yml unchanged. The inputs there already go through env:.

