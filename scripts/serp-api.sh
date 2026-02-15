#!/bin/bash
# SerpAPI wrapper — web search, news, jobs, LinkedIn profile/company lookup
# Usage: serp-api.sh <command> [args...]
# Commands:
#   search            <query> [--num N] [--time d|w|m|y]     Google web search
#   news              <query> [--num N]                      Google News search
#   jobs              <query> [--location LOC]               Google Jobs search
#   linkedin-profile  <name> [company]                       Find LinkedIn profile
#   linkedin-company  <company>                              Find LinkedIn company page
#   help                                                     Show this help

set -euo pipefail

COMMAND="${1:-help}"

# Handle help before API key check
if [ "$COMMAND" = "help" ] || [ "$COMMAND" = "--help" ] || [ "$COMMAND" = "-h" ]; then
  cat <<'HELP'
SerpAPI wrapper — web search, news, jobs, LinkedIn lookups

Usage: serp-api.sh <command> [args...]

Commands:
  search           <query> [--num N] [--time d|w|m|y]
                   Google web search. Time filters: d=day, w=week, m=month, y=year

  news             <query> [--num N]
                   Google News search

  jobs             <query> [--location LOC]
                   Google Jobs search with optional location filter

  linkedin-profile <name> [company]
                   Find a person's LinkedIn profile via Google

  linkedin-company <company>
                   Find a company's LinkedIn page via Google

  help             Show this help message

Environment:
  SERPAPI_KEY    Your SerpAPI key (or set serp_api_key in ~/.claude/sales-recon.local.md)
HELP
  exit 0
fi

# Load API key from environment or settings file
SERPAPI_KEY="${SERPAPI_KEY:-}"
SETTINGS_FILE="${HOME}/.claude/sales-recon.local.md"
if [ -z "$SERPAPI_KEY" ] && [ -f "$SETTINGS_FILE" ]; then
  SERPAPI_KEY=$(grep -oP 'serp_api_key:\s*\K\S+' "$SETTINGS_FILE" 2>/dev/null || echo "")
fi

if [ -z "$SERPAPI_KEY" ]; then
  echo '{"error": "SERPAPI_KEY not set. Export SERPAPI_KEY or add serp_api_key to ~/.claude/sales-recon.local.md"}' >&2
  exit 1
fi

BASE_URL="https://serpapi.com/search"
shift || true

url_encode() {
  python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"
}

case "$COMMAND" in
  search)
    QUERY="${1:-}"
    shift || true
    if [ -z "$QUERY" ]; then
      echo '{"error": "Usage: serp-api.sh search <query> [--num N] [--time d|w|m|y]"}' >&2
      exit 1
    fi
    NUM=10 TIME_FILTER=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --num)  NUM="$2"; shift 2 ;;
        --time) TIME_FILTER="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done
    ENCODED_Q=$(url_encode "$QUERY")
    URL="${BASE_URL}?engine=google&q=${ENCODED_Q}&num=${NUM}&api_key=${SERPAPI_KEY}"
    [ -n "$TIME_FILTER" ] && URL="${URL}&tbs=qdr:${TIME_FILTER}"
    curl -sf "$URL"
    ;;

  news)
    QUERY="${1:-}"
    shift || true
    if [ -z "$QUERY" ]; then
      echo '{"error": "Usage: serp-api.sh news <query> [--num N]"}' >&2
      exit 1
    fi
    NUM=10
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --num) NUM="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done
    ENCODED_Q=$(url_encode "$QUERY")
    curl -sf "${BASE_URL}?engine=google_news&q=${ENCODED_Q}&num=${NUM}&api_key=${SERPAPI_KEY}"
    ;;

  jobs)
    QUERY="${1:-}"
    shift || true
    if [ -z "$QUERY" ]; then
      echo '{"error": "Usage: serp-api.sh jobs <query> [--location LOC]"}' >&2
      exit 1
    fi
    LOCATION=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --location) LOCATION="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done
    ENCODED_Q=$(url_encode "$QUERY")
    URL="${BASE_URL}?engine=google_jobs&q=${ENCODED_Q}&api_key=${SERPAPI_KEY}"
    if [ -n "$LOCATION" ]; then
      ENCODED_LOC=$(url_encode "$LOCATION")
      URL="${URL}&location=${ENCODED_LOC}"
    fi
    curl -sf "$URL"
    ;;

  linkedin-profile)
    NAME="${1:-}"
    shift || true
    if [ -z "$NAME" ]; then
      echo '{"error": "Usage: serp-api.sh linkedin-profile <name> [company]"}' >&2
      exit 1
    fi
    COMPANY="${1:-}"
    shift || true
    QUERY="site:linkedin.com/in/ ${NAME}"
    [ -n "$COMPANY" ] && QUERY="${QUERY} ${COMPANY}"
    ENCODED_Q=$(url_encode "$QUERY")
    curl -sf "${BASE_URL}?engine=google&q=${ENCODED_Q}&num=5&api_key=${SERPAPI_KEY}"
    ;;

  linkedin-company)
    COMPANY="${1:-}"
    if [ -z "$COMPANY" ]; then
      echo '{"error": "Usage: serp-api.sh linkedin-company <company>"}' >&2
      exit 1
    fi
    QUERY="site:linkedin.com/company/ ${COMPANY}"
    ENCODED_Q=$(url_encode "$QUERY")
    curl -sf "${BASE_URL}?engine=google&q=${ENCODED_Q}&num=5&api_key=${SERPAPI_KEY}"
    ;;

  *)
    echo "{\"error\": \"Unknown command: $COMMAND. Run 'serp-api.sh help' for usage.\"}" >&2
    exit 1
    ;;
esac
