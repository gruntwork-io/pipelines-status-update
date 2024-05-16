#!/usr/bin/env bash

set -euo pipefail

echo '{}' > state.json
if [[ -n "${ORCHESTRATE_JOBS:-}" ]]; then
    echo "$ORCHESTRATE_JOBS" > jobs.json
    NUM_JOBS=$(jq -c '. | length' jobs.json)
    if [[ $NUM_JOBS -gt 0 ]]; then
    echo "jobs.json is not empty..."
    for i in $(seq 0 $((NUM_JOBS - 1))); do
        job="$(jq -c ".[$i]" jobs.json)"
        echo "$job"
        change_type="$(jq -r '.ChangeType' <<< "$job")"
        echo "change_type=$change_type"
        working_directory=$(jq -r '.WorkingDirectory' <<< "$job")
        echo "working_directory=$working_directory"

        # shellcheck disable=SC2001
        name="$(sed 's/[A-Z]/ \U&/g' <<< "$change_type" | xargs)"

        echo "name=$name"
        key="$name|$working_directory"
        echo "building new json object.."
        NEWJSON="$(jq --null-input \
            --arg 'key' "$key" \
            --arg 'name' "$name" \
            --arg 'status' "in_progress" \
            --arg 'status_icon' "🔄" \
            --arg 'details_preview' "Output" \
            --arg 'details' "🔄 Running Terragrunt..." \
            --arg 'working_directory' "$working_directory" \
            '{ ($key): { name: $name, status: $status, status_icon: $status_icon, details_preview: $details_preview, details: $details, working_directory: $working_directory }}'
        )"
        echo "$NEWJSON"
        echo "building new state..."
        jq ". + $NEWJSON" state.json > updated_state.json
        mv updated_state.json state.json
    done
    fi
fi
