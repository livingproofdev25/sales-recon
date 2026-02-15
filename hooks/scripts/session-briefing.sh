#!/bin/bash
set -euo pipefail

SETTINGS_FILE="${HOME}/.claude/sales-recon.local.md"
missing_keys=()
configured_keys=()

check_key() {
  local key_name="$1"
  local env_name="$2"
  if [ -n "${!env_name:-}" ]; then
    configured_keys+=("$key_name")
  elif [ -f "$SETTINGS_FILE" ] && grep -qP "${key_name}:\s*\S+" "$SETTINGS_FILE" 2>/dev/null; then
    configured_keys+=("$key_name")
  else
    missing_keys+=("$key_name")
  fi
}

check_key "hunter_api_key" "HUNTER_API_KEY"
check_key "apollo_api_key" "APOLLO_API_KEY"
check_key "serp_api_key" "SERPAPI_KEY"
check_key "google_places_api_key" "GOOGLE_PLACES_API_KEY"
check_key "rentcast_api_key" "RENTCAST_API_KEY"

total=$((${#configured_keys[@]} + ${#missing_keys[@]}))
briefing="Sales-Recon v3 loaded. "

if [ ${#missing_keys[@]} -gt 0 ]; then
  briefing+="Missing API keys: ${missing_keys[*]}. Run /lead-settings to configure. "
fi

briefing+="${#configured_keys[@]}/${total} APIs configured. "
briefing+="B2B: /prospect, /deep-research, /find-contacts, /check-signals, /check-financials, /score-icp, /set-icp. "
briefing+="Residential: /find-permits, /property-lookup, /homeowner-leads. "
briefing+="Shared: /enrich-batch, /export-leads, /craft-outreach, /lead-settings."

cat << EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "$briefing"
}
EOF
