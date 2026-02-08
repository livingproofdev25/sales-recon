#!/bin/bash
# Session Briefing Hook for Prospector
# Runs at session start to show available research commands

set -euo pipefail

# Check for required API keys and provide setup guidance
missing_keys=()

if [ -z "${HUNTER_API_KEY:-}" ]; then
  missing_keys+=("HUNTER_API_KEY")
fi

if [ -z "${GOOGLE_MAPS_KEY:-}" ]; then
  missing_keys+=("GOOGLE_MAPS_KEY")
fi

if [ -z "${SERPAPI_KEY:-}" ]; then
  missing_keys+=("SERPAPI_KEY")
fi

# Build the briefing message
briefing="Prospector plugin loaded. "

if [ ${#missing_keys[@]} -gt 0 ]; then
  briefing+="Missing API keys: ${missing_keys[*]}. "
  briefing+="Set these environment variables for full functionality. "
else
  briefing+="All API keys configured. "
fi

briefing+="Commands: /research-contact, /research-company, /enrich-batch, /export-leads, /set-icp, /check-signals, /check-competitors, /craft-outreach. "
briefing+="Or use natural language: 'research [name]', 'look up [company]', 'check signals for [company]'."

# Output as JSON for Claude
cat << EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "$briefing"
}
EOF
