#!/bin/sh

set -e -u

cd "${GITHUB_WORKSPACE}" || exit 1

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
REVIEWDOG_INSTALL_SCRIPT="$(mktemp)"
curl -sfL -o "${REVIEWDOG_INSTALL_SCRIPT}" https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh
sh "${REVIEWDOG_INSTALL_SCRIPT}" -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
rm -f "${REVIEWDOG_INSTALL_SCRIPT}"
echo '::endgroup::'

echo '::group::⚡️ Installing dotenv-linter ... https://github.com/dotenv-linter/dotenv-linter'
DOTENV_LINTER_INSTALL_SCRIPT="$(mktemp)"
curl -sSfL -o "${DOTENV_LINTER_INSTALL_SCRIPT}" https://raw.githubusercontent.com/dotenv-linter/dotenv-linter/master/install.sh
sh "${DOTENV_LINTER_INSTALL_SCRIPT}" -b "${TEMP_PATH}" "${DOTENV_LINTER_VERSION}" 2>&1
rm -f "${DOTENV_LINTER_INSTALL_SCRIPT}"
echo '::endgroup::'

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

if [ "${INPUT_REPORTER}" = "github-code-suggestions" ]
then
      echo '::group::Running ⚡️ dotenv-linter with code suggestions 🐶 ...'
      dotenv-linter fix --no-color "${INPUT_DOTENV_LINTER_FLAGS}"

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
        "${INPUT_REVIEWDOG_FLAGS}" < "${TMPFILE}"
else
      echo '::group::Running ⚡️ dotenv-linter with reviewdog 🐶 ...'
      dotenv-linter --quiet --no-color "${INPUT_DOTENV_LINTER_FLAGS}" \
        | reviewdog -f=dotenv-linter \
          -name="${INPUT_TOOL_NAME}" \
          -reporter="${INPUT_REPORTER}" \
          -filter-mode="${INPUT_FILTER_MODE}" \
          -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
          "${INPUT_REVIEWDOG_FLAGS}"
fi

EXIT_CODE=$?
echo '::endgroup::'
exit ${EXIT_CODE}
