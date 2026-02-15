#!/bin/bash
# RentCast API wrapper — property data, valuations, sale history, market stats
# Usage: rentcast-api.sh <command> [args...]
# Commands:
#   property     <address>    Get property details
#   value        <address>    Get automated valuation (AVM)
#   sale-history <address>    Get sale/transaction history
#   market       <zipcode>    Get market statistics for a zip code
#   help                      Show this help

set -euo pipefail

COMMAND="${1:-help}"

# Handle help before API key check
if [ "$COMMAND" = "help" ] || [ "$COMMAND" = "--help" ] || [ "$COMMAND" = "-h" ]; then
  cat <<'HELP'
RentCast API wrapper — property data, valuations, and market statistics

Usage: rentcast-api.sh <command> [args...]

Commands:
  property     <address>
               Get property details (beds, baths, sqft, year built, lot size, etc.)

  value        <address>
               Get automated valuation model (AVM) estimate for a property

  sale-history <address>
               Get sale and transaction history for a property

  market       <zipcode>
               Get market statistics for a zip code (median prices, rents, trends)

  help         Show this help message

Environment:
  RENTCAST_API_KEY    Your RentCast API key, passed as X-Api-Key header
                      (or set rentcast_api_key in ~/.claude/sales-recon.local.md)

Examples:
  rentcast-api.sh property "123 Main St, Austin, TX 78701"
  rentcast-api.sh value "456 Oak Ave, Boston, MA 02101"
  rentcast-api.sh sale-history "789 Elm Dr, Detroit, MI 48201"
  rentcast-api.sh market 78701
HELP
  exit 0
fi

# Load API key from environment or settings file
RENTCAST_API_KEY="${RENTCAST_API_KEY:-}"
SETTINGS_FILE="${HOME}/.claude/sales-recon.local.md"
if [ -z "$RENTCAST_API_KEY" ] && [ -f "$SETTINGS_FILE" ]; then
  RENTCAST_API_KEY=$(grep -oP 'rentcast_api_key:\s*\K\S+' "$SETTINGS_FILE" 2>/dev/null || echo "")
fi

if [ -z "$RENTCAST_API_KEY" ]; then
  echo '{"error": "RENTCAST_API_KEY not set. Export RENTCAST_API_KEY or add rentcast_api_key to ~/.claude/sales-recon.local.md"}' >&2
  exit 1
fi

BASE_URL="https://api.rentcast.io/v1"
shift || true

url_encode() {
  python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"
}

rc_get() {
  curl -sf -H "X-Api-Key: ${RENTCAST_API_KEY}" "$1"
}

case "$COMMAND" in
  property)
    ADDRESS="${1:-}"
    if [ -z "$ADDRESS" ]; then
      echo '{"error": "Usage: rentcast-api.sh property <address>"}' >&2
      exit 1
    fi
    ENCODED_ADDR=$(url_encode "$ADDRESS")
    rc_get "${BASE_URL}/properties?address=${ENCODED_ADDR}"
    ;;

  value)
    ADDRESS="${1:-}"
    if [ -z "$ADDRESS" ]; then
      echo '{"error": "Usage: rentcast-api.sh value <address>"}' >&2
      exit 1
    fi
    ENCODED_ADDR=$(url_encode "$ADDRESS")
    rc_get "${BASE_URL}/avm/value?address=${ENCODED_ADDR}"
    ;;

  sale-history)
    ADDRESS="${1:-}"
    if [ -z "$ADDRESS" ]; then
      echo '{"error": "Usage: rentcast-api.sh sale-history <address>"}' >&2
      exit 1
    fi
    ENCODED_ADDR=$(url_encode "$ADDRESS")
    rc_get "${BASE_URL}/sales/history?address=${ENCODED_ADDR}"
    ;;

  market)
    ZIPCODE="${1:-}"
    if [ -z "$ZIPCODE" ]; then
      echo '{"error": "Usage: rentcast-api.sh market <zipcode>"}' >&2
      exit 1
    fi
    rc_get "${BASE_URL}/markets?zipCode=${ZIPCODE}"
    ;;

  *)
    echo "{\"error\": \"Unknown command: $COMMAND. Run 'rentcast-api.sh help' for usage.\"}" >&2
    exit 1
    ;;
esac
