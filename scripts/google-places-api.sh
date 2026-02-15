#!/bin/bash
# Google Places API wrapper — business verification, details, and search
# Usage: google-places-api.sh <command> [args...]
# Commands:
#   find        <query> [--fields X]                             Find a place by query
#   details     <place_id> [--fields X]                          Get place details
#   text-search <query> [--location lat,lng] [--radius meters]   Search places by text
#   help                                                         Show this help

set -euo pipefail

COMMAND="${1:-help}"

# Handle help before API key check
if [ "$COMMAND" = "help" ] || [ "$COMMAND" = "--help" ] || [ "$COMMAND" = "-h" ]; then
  cat <<'HELP'
Google Places API wrapper — business verification and search

Usage: google-places-api.sh <command> [args...]

Commands:
  find        <query> [--fields X]
              Find a place by text query. Returns best match.
              Default fields: name,formatted_address,formatted_phone_number,
                website,place_id,rating,user_ratings_total,business_status,types

  details     <place_id> [--fields X]
              Get detailed info for a specific place.
              Default fields: name,formatted_address,formatted_phone_number,
                international_phone_number,website,url,rating,reviews,
                user_ratings_total,types,opening_hours,business_status

  text-search <query> [--location lat,lng] [--radius meters]
              Search for places matching a text query, optionally near a location.

  help        Show this help message

Environment:
  GOOGLE_PLACES_API_KEY    Your Google Places API key
                           (or set google_places_api_key in ~/.claude/sales-recon.local.md)
HELP
  exit 0
fi

# Load API key from environment or settings file
GOOGLE_PLACES_API_KEY="${GOOGLE_PLACES_API_KEY:-}"
SETTINGS_FILE="${HOME}/.claude/sales-recon.local.md"
if [ -z "$GOOGLE_PLACES_API_KEY" ] && [ -f "$SETTINGS_FILE" ]; then
  GOOGLE_PLACES_API_KEY=$(grep -oP 'google_places_api_key:\s*\K\S+' "$SETTINGS_FILE" 2>/dev/null || echo "")
fi

if [ -z "$GOOGLE_PLACES_API_KEY" ]; then
  echo '{"error": "GOOGLE_PLACES_API_KEY not set. Export GOOGLE_PLACES_API_KEY or add google_places_api_key to ~/.claude/sales-recon.local.md"}' >&2
  exit 1
fi

BASE_URL="https://maps.googleapis.com/maps/api/place"
shift || true

url_encode() {
  python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"
}

DEFAULT_FIND_FIELDS="name,formatted_address,formatted_phone_number,website,place_id,rating,user_ratings_total,business_status,types"
DEFAULT_DETAILS_FIELDS="name,formatted_address,formatted_phone_number,international_phone_number,website,url,rating,reviews,user_ratings_total,types,opening_hours,business_status"

case "$COMMAND" in
  find)
    QUERY="${1:-}"
    shift || true
    if [ -z "$QUERY" ]; then
      echo '{"error": "Usage: google-places-api.sh find <query> [--fields X]"}' >&2
      exit 1
    fi
    FIELDS="$DEFAULT_FIND_FIELDS"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --fields) FIELDS="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done
    ENCODED_Q=$(url_encode "$QUERY")
    curl -sf "${BASE_URL}/findplacefromtext/json?input=${ENCODED_Q}&inputtype=textquery&fields=${FIELDS}&key=${GOOGLE_PLACES_API_KEY}"
    ;;

  details)
    PLACE_ID="${1:-}"
    shift || true
    if [ -z "$PLACE_ID" ]; then
      echo '{"error": "Usage: google-places-api.sh details <place_id> [--fields X]"}' >&2
      exit 1
    fi
    FIELDS="$DEFAULT_DETAILS_FIELDS"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --fields) FIELDS="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done
    curl -sf "${BASE_URL}/details/json?place_id=${PLACE_ID}&fields=${FIELDS}&key=${GOOGLE_PLACES_API_KEY}"
    ;;

  text-search)
    QUERY="${1:-}"
    shift || true
    if [ -z "$QUERY" ]; then
      echo '{"error": "Usage: google-places-api.sh text-search <query> [--location lat,lng] [--radius meters]"}' >&2
      exit 1
    fi
    LOCATION="" RADIUS=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --location) LOCATION="$2"; shift 2 ;;
        --radius)   RADIUS="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done
    ENCODED_Q=$(url_encode "$QUERY")
    URL="${BASE_URL}/textsearch/json?query=${ENCODED_Q}&key=${GOOGLE_PLACES_API_KEY}"
    [ -n "$LOCATION" ] && URL="${URL}&location=${LOCATION}"
    [ -n "$RADIUS" ] && URL="${URL}&radius=${RADIUS}"
    curl -sf "$URL"
    ;;

  *)
    echo "{\"error\": \"Unknown command: $COMMAND. Run 'google-places-api.sh help' for usage.\"}" >&2
    exit 1
    ;;
esac
