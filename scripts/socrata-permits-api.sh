#!/bin/bash
# Socrata Open Data API wrapper — building permits from major US cities
# Usage: socrata-permits-api.sh <command> [args...]
# Commands:
#   search        <city> [--type X] [--days N] [--limit N] [--min-value N]   Search permits
#   cities                                                                    List supported cities
#   project-types                                                             List common project types
#   help                                                                      Show this help

set -euo pipefail

# No API key needed — Socrata open data is free

# City endpoint registry
declare -A CITY_ENDPOINTS=(
  ["austin"]="https://data.austintexas.gov/resource/3syk-w9eu.json"
  ["san-antonio"]="https://data.sanantonio.gov/resource/nkgd-7gx7.json"
  ["nyc"]="https://data.cityofnewyork.us/resource/ipu4-2vj7.json"
  ["boston"]="https://data.boston.gov/resource/hfgw-p5wb.json"
  ["detroit"]="https://data.detroitmi.gov/resource/but4-ky7y.json"
  ["dc"]="https://opendata.dc.gov/resource/awqx-zupu.json"
)

normalize_city() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-'
}

# Cross-platform date calculation
date_cutoff() {
  local days="$1"
  if date -d "-${days} days" +%Y-%m-%dT00:00:00 2>/dev/null; then
    return
  fi
  # macOS fallback
  date -v-"${days}"d +%Y-%m-%dT00:00:00 2>/dev/null || echo "2020-01-01T00:00:00"
}

url_encode() {
  python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"
}

COMMAND="${1:-help}"
shift || true

case "$COMMAND" in
  search)
    CITY_INPUT="${1:-}"
    shift || true
    if [ -z "$CITY_INPUT" ]; then
      echo '{"error": "Usage: socrata-permits-api.sh search <city> [--type X] [--days N] [--limit N] [--min-value N]"}' >&2
      exit 1
    fi
    CITY=$(normalize_city "$CITY_INPUT")
    ENDPOINT="${CITY_ENDPOINTS[$CITY]:-}"
    if [ -z "$ENDPOINT" ]; then
      echo "{\"error\": \"Unsupported city: ${CITY_INPUT}. Run 'socrata-permits-api.sh cities' for supported cities.\"}" >&2
      exit 1
    fi

    TYPE="" DAYS=90 LIMIT=50 MIN_VALUE=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --type)      TYPE="$2"; shift 2 ;;
        --days)      DAYS="$2"; shift 2 ;;
        --limit)     LIMIT="$2"; shift 2 ;;
        --min-value) MIN_VALUE="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done

    CUTOFF=$(date_cutoff "$DAYS")

    # Build SoQL where clause
    WHERE="issue_date > '${CUTOFF}'"
    if [ -n "$TYPE" ]; then
      UPPER_TYPE=$(echo "$TYPE" | tr '[:lower:]' '[:upper:]')
      WHERE="${WHERE} AND upper(permit_type_definition) LIKE '%${UPPER_TYPE}%'"
    fi
    if [ -n "$MIN_VALUE" ]; then
      WHERE="${WHERE} AND original_value > ${MIN_VALUE}"
    fi

    ENCODED_WHERE=$(url_encode "$WHERE")
    curl -sf "${ENDPOINT}?\$limit=${LIMIT}&\$order=issue_date%20DESC&\$where=${ENCODED_WHERE}"
    ;;

  cities)
    cat <<'JSON'
{
  "supported_cities": {
    "austin": {
      "name": "Austin, TX",
      "endpoint": "https://data.austintexas.gov/resource/3syk-w9eu.json",
      "description": "City of Austin building permits"
    },
    "san-antonio": {
      "name": "San Antonio, TX",
      "endpoint": "https://data.sanantonio.gov/resource/nkgd-7gx7.json",
      "description": "City of San Antonio building permits"
    },
    "nyc": {
      "name": "New York City, NY",
      "endpoint": "https://data.cityofnewyork.us/resource/ipu4-2vj7.json",
      "description": "NYC Department of Buildings permits"
    },
    "boston": {
      "name": "Boston, MA",
      "endpoint": "https://data.boston.gov/resource/hfgw-p5wb.json",
      "description": "City of Boston building permits"
    },
    "detroit": {
      "name": "Detroit, MI",
      "endpoint": "https://data.detroitmi.gov/resource/but4-ky7y.json",
      "description": "City of Detroit building permits"
    },
    "dc": {
      "name": "Washington, DC",
      "endpoint": "https://opendata.dc.gov/resource/awqx-zupu.json",
      "description": "DC building permits"
    }
  }
}
JSON
    ;;

  project-types)
    cat <<'JSON'
{
  "common_project_types": [
    "roofing",
    "hvac",
    "plumbing",
    "electrical",
    "remodel",
    "addition",
    "foundation",
    "siding",
    "windows",
    "solar",
    "pool",
    "fence",
    "deck",
    "garage",
    "demolition",
    "commercial",
    "new construction",
    "renovation"
  ],
  "usage": "Use with --type flag: socrata-permits-api.sh search austin --type roofing"
}
JSON
    ;;

  help|*)
    cat <<'HELP'
Socrata Open Data API wrapper — building permits from major US cities (free, no API key needed)

Usage: socrata-permits-api.sh <command> [args...]

Commands:
  search        <city> [--type X] [--days N] [--limit N] [--min-value N]
                Search building permits for a city.
                --type:      Filter by project type (e.g., roofing, hvac, electrical)
                --days:      Look back N days (default: 90)
                --limit:     Max results (default: 50)
                --min-value: Minimum permit value in dollars

  cities        List all supported cities with endpoints

  project-types List common project types for filtering

  help          Show this help message

Supported Cities:
  austin, san-antonio, nyc, boston, detroit, dc

Examples:
  socrata-permits-api.sh search austin --type roofing --days 30
  socrata-permits-api.sh search nyc --min-value 100000 --limit 20
  socrata-permits-api.sh search boston --type hvac --days 60

Notes:
  - No API key required (free public data)
  - Data freshness varies by city
  - Default lookback is 90 days
HELP
    ;;
esac
