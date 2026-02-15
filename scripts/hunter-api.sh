#!/bin/bash
# Hunter.io API wrapper — email discovery, domain search, email verification
# Usage: hunter-api.sh <command> [args...]
# Commands:
#   find-email   --domain <domain> --first <first> --last <last>   Find email for a person
#   domain-search <domain> [--limit N] [--seniority X] [--department X]   Search emails at domain
#   verify       <email>                                            Verify an email address
#   account-info                                                    Get account info & quota
#   help                                                            Show this help

set -euo pipefail

COMMAND="${1:-help}"

# Handle help before API key check
if [ "$COMMAND" = "help" ] || [ "$COMMAND" = "--help" ] || [ "$COMMAND" = "-h" ]; then
  cat <<'HELP'
Hunter.io API wrapper — email discovery and verification

Usage: hunter-api.sh <command> [args...]

Commands:
  find-email    --domain <domain> --first <first> --last <last>
                Find the most likely email for a person at a company

  domain-search <domain> [--limit N] [--seniority X] [--department X]
                List email addresses found for a domain
                Seniority: junior, senior, executive
                Department: executive, it, finance, management, sales, legal,
                            support, hr, marketing, communication, education, design, health, operations

  verify        <email>
                Verify deliverability of an email address

  account-info  Show account details and remaining quota

  help          Show this help message

Environment:
  HUNTER_API_KEY    Your Hunter.io API key (or set hunter_api_key in ~/.claude/sales-recon.local.md)
HELP
  exit 0
fi

# Load API key from environment or settings file
HUNTER_API_KEY="${HUNTER_API_KEY:-}"
SETTINGS_FILE="${HOME}/.claude/sales-recon.local.md"
if [ -z "$HUNTER_API_KEY" ] && [ -f "$SETTINGS_FILE" ]; then
  HUNTER_API_KEY=$(grep -oP 'hunter_api_key:\s*\K\S+' "$SETTINGS_FILE" 2>/dev/null || echo "")
fi

if [ -z "$HUNTER_API_KEY" ]; then
  echo '{"error": "HUNTER_API_KEY not set. Export HUNTER_API_KEY or add hunter_api_key to ~/.claude/sales-recon.local.md"}' >&2
  exit 1
fi

BASE_URL="https://api.hunter.io/v2"
shift || true

case "$COMMAND" in
  find-email)
    DOMAIN="" FIRST="" LAST=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --domain) DOMAIN="$2"; shift 2 ;;
        --first)  FIRST="$2"; shift 2 ;;
        --last)   LAST="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done
    if [ -z "$DOMAIN" ] || [ -z "$FIRST" ] || [ -z "$LAST" ]; then
      echo '{"error": "Usage: hunter-api.sh find-email --domain example.com --first John --last Doe"}' >&2
      exit 1
    fi
    ENCODED_FIRST=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$FIRST'))")
    ENCODED_LAST=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$LAST'))")
    curl -sf "${BASE_URL}/email-finder?domain=${DOMAIN}&first_name=${ENCODED_FIRST}&last_name=${ENCODED_LAST}&api_key=${HUNTER_API_KEY}"
    ;;

  domain-search)
    DOMAIN="${1:-}"
    shift || true
    if [ -z "$DOMAIN" ]; then
      echo '{"error": "Usage: hunter-api.sh domain-search <domain> [--limit N] [--seniority X] [--department X]"}' >&2
      exit 1
    fi
    LIMIT=10 SENIORITY="" DEPARTMENT=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --limit)      LIMIT="$2"; shift 2 ;;
        --seniority)  SENIORITY="$2"; shift 2 ;;
        --department) DEPARTMENT="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done
    URL="${BASE_URL}/domain-search?domain=${DOMAIN}&limit=${LIMIT}&api_key=${HUNTER_API_KEY}"
    [ -n "$SENIORITY" ] && URL="${URL}&seniority=${SENIORITY}"
    [ -n "$DEPARTMENT" ] && URL="${URL}&department=${DEPARTMENT}"
    curl -sf "$URL"
    ;;

  verify)
    EMAIL="${1:-}"
    if [ -z "$EMAIL" ]; then
      echo '{"error": "Usage: hunter-api.sh verify <email>"}' >&2
      exit 1
    fi
    curl -sf "${BASE_URL}/email-verifier?email=${EMAIL}&api_key=${HUNTER_API_KEY}"
    ;;

  account-info)
    curl -sf "${BASE_URL}/account?api_key=${HUNTER_API_KEY}"
    ;;

  *)
    echo "{\"error\": \"Unknown command: $COMMAND. Run 'hunter-api.sh help' for usage.\"}" >&2
    exit 1
    ;;
esac
