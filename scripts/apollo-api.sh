#!/bin/bash
# Apollo.io API wrapper — firmographics, contacts, org charts
# Usage: apollo-api.sh <command> [args...]
# Commands:
#   people-search  --query <q> [--org <org>] [--title <title>] [--limit N]   Search people
#   company-enrich --domain <domain>                                          Enrich company data
#   people-enrich  --email <email>                                            Enrich person by email
#   org-chart      --domain <domain> [--limit N]                              Get leadership org chart
#   help                                                                      Show this help

set -euo pipefail

COMMAND="${1:-help}"

# Handle help before API key check
if [ "$COMMAND" = "help" ] || [ "$COMMAND" = "--help" ] || [ "$COMMAND" = "-h" ]; then
  cat <<'HELP'
Apollo.io API wrapper — firmographics, contacts, and org charts

Usage: apollo-api.sh <command> [args...]

Commands:
  people-search  --query <q> [--org <org>] [--title <title>] [--limit N]
                 Search for people by keyword, organization, or title

  company-enrich --domain <domain>
                 Enrich company data by domain (firmographics, tech stack, etc.)

  people-enrich  --email <email>
                 Enrich a person's profile by email address

  org-chart      --domain <domain> [--limit N]
                 Get leadership/org chart for a company
                 Returns: owners, founders, C-suite, partners, VPs, heads, directors

  help           Show this help message

Environment:
  APOLLO_API_KEY    Your Apollo.io API key (or set apollo_api_key in ~/.claude/sales-recon.local.md)
HELP
  exit 0
fi

# Load API key from environment or settings file
APOLLO_API_KEY="${APOLLO_API_KEY:-}"
SETTINGS_FILE="${HOME}/.claude/sales-recon.local.md"
if [ -z "$APOLLO_API_KEY" ] && [ -f "$SETTINGS_FILE" ]; then
  APOLLO_API_KEY=$(grep -oP 'apollo_api_key:\s*\K\S+' "$SETTINGS_FILE" 2>/dev/null || echo "")
fi

if [ -z "$APOLLO_API_KEY" ]; then
  echo '{"error": "APOLLO_API_KEY not set. Export APOLLO_API_KEY or add apollo_api_key to ~/.claude/sales-recon.local.md"}' >&2
  exit 1
fi

BASE_URL="https://api.apollo.io/v1"
shift || true

case "$COMMAND" in
  people-search)
    QUERY="" ORG="" TITLE="" LIMIT=10
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --query) QUERY="$2"; shift 2 ;;
        --org)   ORG="$2"; shift 2 ;;
        --title) TITLE="$2"; shift 2 ;;
        --limit) LIMIT="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done
    if [ -z "$QUERY" ] && [ -z "$ORG" ] && [ -z "$TITLE" ]; then
      echo '{"error": "Usage: apollo-api.sh people-search --query <q> [--org <org>] [--title <title>] [--limit N]"}' >&2
      exit 1
    fi
    JSON_BODY="{\"api_key\": \"${APOLLO_API_KEY}\", \"per_page\": ${LIMIT}"
    [ -n "$QUERY" ] && JSON_BODY="${JSON_BODY}, \"q_keywords\": \"${QUERY}\""
    [ -n "$ORG" ] && JSON_BODY="${JSON_BODY}, \"q_organization_name\": \"${ORG}\""
    [ -n "$TITLE" ] && JSON_BODY="${JSON_BODY}, \"person_titles\": [\"${TITLE}\"]"
    JSON_BODY="${JSON_BODY}}"
    curl -sf -X POST "${BASE_URL}/mixed_people/search" \
      -H "Content-Type: application/json" \
      -d "$JSON_BODY"
    ;;

  company-enrich)
    DOMAIN=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --domain) DOMAIN="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done
    if [ -z "$DOMAIN" ]; then
      echo '{"error": "Usage: apollo-api.sh company-enrich --domain <domain>"}' >&2
      exit 1
    fi
    curl -sf -X POST "${BASE_URL}/organizations/enrich" \
      -H "Content-Type: application/json" \
      -d "{\"api_key\": \"${APOLLO_API_KEY}\", \"domain\": \"${DOMAIN}\"}"
    ;;

  people-enrich)
    EMAIL=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --email) EMAIL="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done
    if [ -z "$EMAIL" ]; then
      echo '{"error": "Usage: apollo-api.sh people-enrich --email <email>"}' >&2
      exit 1
    fi
    curl -sf -X POST "${BASE_URL}/people/match" \
      -H "Content-Type: application/json" \
      -d "{\"api_key\": \"${APOLLO_API_KEY}\", \"email\": \"${EMAIL}\"}"
    ;;

  org-chart)
    DOMAIN="" LIMIT=25
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --domain) DOMAIN="$2"; shift 2 ;;
        --limit)  LIMIT="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done
    if [ -z "$DOMAIN" ]; then
      echo '{"error": "Usage: apollo-api.sh org-chart --domain <domain> [--limit N]"}' >&2
      exit 1
    fi
    curl -sf -X POST "${BASE_URL}/mixed_people/search" \
      -H "Content-Type: application/json" \
      -d "{\"api_key\": \"${APOLLO_API_KEY}\", \"q_organization_domains\": \"${DOMAIN}\", \"person_seniorities\": [\"owner\", \"founder\", \"c_suite\", \"partner\", \"vp\", \"head\", \"director\"], \"per_page\": ${LIMIT}}"
    ;;

  *)
    echo "{\"error\": \"Unknown command: $COMMAND. Run 'apollo-api.sh help' for usage.\"}" >&2
    exit 1
    ;;
esac
