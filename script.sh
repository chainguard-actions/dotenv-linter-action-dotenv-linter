#!/bin/bash

set -e -u

cd "${GITHUB_WORKSPACE}" || exit 1

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
REVIEWDOG_INSTALL_SCRIPT="$(mktemp)"
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh \
  -o "${REVIEWDOG_INSTALL_SCRIPT}"
sh "${REVIEWDOG_INSTALL_SCRIPT}" -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

echo '::group::⚡️ Installing dotenv-linter ... https://github.com/dotenv-linter/dotenv-linter'
DOTENV_LINTER_INSTALL_SCRIPT="$(mktemp)"
curl -sSfL https://raw.githubusercontent.com/dotenv-linter/dotenv-linter/master/install.sh \
  -o "${DOTENV_LINTER_INSTALL_SCRIPT}"
sh "${DOTENV_LINTER_INSTALL_SCRIPT}" -b "${TEMP_PATH}" "${DOTENV_LINTER_VERSION}" 2>&1
echo '::endgroup::'

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# Tokenize list-type inputs into arrays (quote-aware, handles sh -c "..." etc.)
dotenv_linter_flags=()
if [ -n "${INPUT_DOTENV_LINTER_FLAGS}" ]; then
  while IFS= read -r -d '' t; do dotenv_linter_flags+=("$t"); done \
    < <(printf '%s' "${INPUT_DOTENV_LINTER_FLAGS}" | xargs printf '%s\0')
fi

reviewdog_flags=()
if [ -n "${INPUT_REVIEWDOG_FLAGS}" ]; then
  while IFS= read -r -d '' t; do reviewdog_flags+=("$t"); done \
    < <(printf '%s' "${INPUT_REVIEWDOG_FLAGS}" | xargs printf '%s\0')
fi

if [ "${INPUT_REPORTER}" = "github-code-suggestions" ]
then
      echo '::group::Running ⚡️ dotenv-linter with code suggestions 🐶 ...'
      dotenv-linter fix --no-color "${dotenv_linter_flags[@]}"

      TMPFILE=$(mktemp)
      git diff > "${TMPFILE}"
      git stash -u || true
      git stash drop || true

      reviewdog \
        -name="${INPUT_TOOL_NAME}" \
        -f=diff \
        -f.diff.strip=1 \
        -reporter="github-pr-review" \
        -filter-mode="${INPUT_FILTER_MODE}" \
        -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
        "${reviewdog_flags[@]}" < "${TMPFILE}"
else
      echo '::group::Running ⚡️ dotenv-linter with reviewdog 🐶 ...'
      dotenv-linter --quiet --no-color "${dotenv_linter_flags[@]}" \
        | reviewdog -f=dotenv-linter \
          -name="${INPUT_TOOL_NAME}" \
          -reporter="${INPUT_REPORTER}" \
          -filter-mode="${INPUT_FILTER_MODE}" \
          -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
          "${reviewdog_flags[@]}"
fi

EXIT_CODE=$?
echo '::endgroup::'
exit ${EXIT_CODE}
