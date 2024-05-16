#!/usr/bin/env bash

set -euo pipefail

: "${GITHUB_OUTPUT:?Environment variable GITHUB_OUTPUT must be set}"

name="$(echo "${STEP_NAME:-}" | sed -E 's/([a-z])([A-Z])/\1 \2/g' | xargs)"
echo "formatted_name=$name" >> "$GITHUB_OUTPUT"
