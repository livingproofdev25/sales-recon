#!/bin/bash
# Session Briefing Hook for Sales Recon
# Runs at session start to provide context about available intelligence tools

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
briefing="Sales Recon plugin loaded. "

if [ ${#missing_keys[@]} -gt 0 ]; then
  briefing+="⚠️ Missing API keys: ${missing_keys[*]}. "
  briefing+="Set these environment variables for full functionality. "
else
  briefing+="✓ All API keys configured. "
fi

briefing+="Available commands: /recon-person, /recon-company, /recon-batch, /recon-export. "
briefing+="Or use natural language with trigger words: 'research', 'find info on', 'look up'."

# Output as JSON for Claude
cat << EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "$briefing"
}
EOF
