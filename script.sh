#!/bin/sh

set -e -u

cd "${GITHUB_WORKSPACE}" || exit 1

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
# install.sh pinned to the commit of reviewdog v0.21.0
REVIEWDOG_INSTALL_SCRIPT="$(mktemp)"
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74df59de7ebfd9276afabd62ea2de4d7dd/install.sh \
  -o "${REVIEWDOG_INSTALL_SCRIPT}"
sh "${REVIEWDOG_INSTALL_SCRIPT}" -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
rm -f "${REVIEWDOG_INSTALL_SCRIPT}"
echo '::endgroup::'

echo '::group::⚡️ Installing dotenv-linter ... https://github.com/dotenv-linter/dotenv-linter'
# install.sh pinned to the commit of dotenv-linter v4.0.0
DOTENV_LINTER_INSTALL_SCRIPT="$(mktemp)"
curl -sSfL https://raw.githubusercontent.com/dotenv-linter/dotenv-linter/f9076b02daed89f54ed0bd23951a4cfa5ccceac4/install.sh \
  -o "${DOTENV_LINTER_INSTALL_SCRIPT}"
sh "${DOTENV_LINTER_INSTALL_SCRIPT}" -b "${TEMP_PATH}" "${DOTENV_LINTER_VERSION}" 2>&1
rm -f "${DOTENV_LINTER_INSTALL_SCRIPT}"
echo '::endgroup::'

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

if [ "${INPUT_REPORTER}" = "github-code-suggestions" ]
then
      echo '::group::Running ⚡️ dotenv-linter with code suggestions 🐶 ...'
      # shellcheck disable=SC2086
      dotenv-linter fix --plain ${INPUT_DOTENV_LINTER_FLAGS} .

      TMPFILE=$(mktemp)
      git diff > "${TMPFILE}"
      git stash -u || true
      git stash drop || true

      # shellcheck disable=SC2086
      reviewdog \
        -name="${INPUT_TOOL_NAME}" \
        -f=diff \
        -f.diff.strip=1 \
        -reporter="github-pr-review" \
        -filter-mode="${INPUT_FILTER_MODE}" \
        -fail-level="${INPUT_FAIL_LEVEL}" \
        ${INPUT_REVIEWDOG_FLAGS} < "${TMPFILE}"
else
      echo '::group::Running ⚡️ dotenv-linter with reviewdog 🐶 ...'
      # shellcheck disable=SC2086
      dotenv-linter check --quiet --plain ${INPUT_DOTENV_LINTER_FLAGS} . \
        | reviewdog -f=dotenv-linter \
          -name="${INPUT_TOOL_NAME}" \
          -reporter="${INPUT_REPORTER}" \
          -filter-mode="${INPUT_FILTER_MODE}" \
          -fail-level="${INPUT_FAIL_LEVEL}" \
          ${INPUT_REVIEWDOG_FLAGS}
fi

EXIT_CODE=$?
echo '::endgroup::'
exit ${EXIT_CODE}
