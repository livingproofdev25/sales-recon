#!/bin/bash
# SEC EDGAR API wrapper — public company financial filings
# Usage: sec-edgar-api.sh <command> [args...]
# Commands:
#   search          <company-name>                   Search for company by name
#   filings         <cik> [--type 10-K] [--limit N]  Get company filings
#   company-facts   <cik>                            Get XBRL company facts
#   company-concept <cik> <tag>                      Get specific financial metric
#   help                                             Show this help

set -euo pipefail

# No API key needed — SEC EDGAR is free public data
USER_AGENT="SalesRecon/3.0 (dev@xai3x.com)"

COMMAND="${1:-help}"
shift || true

# Pad CIK to 10 digits
pad_cik() {
  printf "%010d" "$1"
}

url_encode() {
  python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"
}

case "$COMMAND" in
  search)
    QUERY="${1:-}"
    if [ -z "$QUERY" ]; then
      echo '{"error": "Usage: sec-edgar-api.sh search <company-name>"}' >&2
      exit 1
    fi
    ENCODED_Q=$(url_encode "$QUERY")
    curl -sf \
      -H "User-Agent: ${USER_AGENT}" \
      -H "Accept: application/json" \
      "https://efts.sec.gov/LATEST/search-index?q=${ENCODED_Q}&forms=10-K"
    ;;

  filings)
    CIK="${1:-}"
    shift || true
    if [ -z "$CIK" ]; then
      echo '{"error": "Usage: sec-edgar-api.sh filings <cik> [--type 10-K] [--limit N]"}' >&2
      exit 1
    fi
    FILING_TYPE="" LIMIT=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --type)  FILING_TYPE="$2"; shift 2 ;;
        --limit) LIMIT="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done
    PADDED_CIK=$(pad_cik "$CIK")
    RESULT=$(curl -sf \
      -H "User-Agent: ${USER_AGENT}" \
      -H "Accept: application/json" \
      "https://data.sec.gov/submissions/CIK${PADDED_CIK}.json")
    # If filtering by type or limit, post-process with python
    if [ -n "$FILING_TYPE" ] || [ -n "$LIMIT" ]; then
      echo "$RESULT" | python3 -c "
import sys, json

data = json.load(sys.stdin)
filings = data.get('filings', {}).get('recent', {})
forms = filings.get('form', [])
dates = filings.get('filingDate', [])
accessions = filings.get('accessionNumber', [])
primary_docs = filings.get('primaryDocument', [])
descriptions = filings.get('primaryDocDescription', [])

results = []
for i in range(len(forms)):
    entry = {
        'form': forms[i] if i < len(forms) else '',
        'filingDate': dates[i] if i < len(dates) else '',
        'accessionNumber': accessions[i] if i < len(accessions) else '',
        'primaryDocument': primary_docs[i] if i < len(primary_docs) else '',
        'description': descriptions[i] if i < len(descriptions) else ''
    }
    filing_type = '${FILING_TYPE}'
    if filing_type and entry['form'] != filing_type:
        continue
    results.append(entry)

limit = ${LIMIT:-0}
if limit > 0:
    results = results[:limit]

output = {
    'cik': data.get('cik', ''),
    'entityName': data.get('name', ''),
    'filings': results,
    'total_filtered': len(results)
}
json.dump(output, sys.stdout, indent=2)
"
    else
      echo "$RESULT"
    fi
    ;;

  company-facts)
    CIK="${1:-}"
    if [ -z "$CIK" ]; then
      echo '{"error": "Usage: sec-edgar-api.sh company-facts <cik>"}' >&2
      exit 1
    fi
    PADDED_CIK=$(pad_cik "$CIK")
    curl -sf \
      -H "User-Agent: ${USER_AGENT}" \
      -H "Accept: application/json" \
      "https://data.sec.gov/api/xbrl/companyfacts/CIK${PADDED_CIK}.json"
    ;;

  company-concept)
    CIK="${1:-}"
    TAG="${2:-}"
    if [ -z "$CIK" ] || [ -z "$TAG" ]; then
      echo '{"error": "Usage: sec-edgar-api.sh company-concept <cik> <tag>"}' >&2
      echo '{"hint": "Common tags: Revenues, NetIncomeLoss, Assets, StockholdersEquity, EarningsPerShareBasic"}' >&2
      exit 1
    fi
    PADDED_CIK=$(pad_cik "$CIK")
    curl -sf \
      -H "User-Agent: ${USER_AGENT}" \
      -H "Accept: application/json" \
      "https://data.sec.gov/api/xbrl/companyconcept/CIK${PADDED_CIK}/us-gaap/${TAG}.json"
    ;;

  help|*)
    cat <<'HELP'
SEC EDGAR API wrapper — public company financial filings (free, no API key needed)

Usage: sec-edgar-api.sh <command> [args...]

Commands:
  search          <company-name>
                  Search for a company in SEC EDGAR by name

  filings         <cik> [--type 10-K] [--limit N]
                  Get company filings by CIK number
                  Common types: 10-K (annual), 10-Q (quarterly), 8-K (events), DEF 14A (proxy)

  company-facts   <cik>
                  Get all XBRL financial facts for a company

  company-concept <cik> <tag>
                  Get a specific financial metric over time
                  Common tags: Revenues, NetIncomeLoss, Assets,
                    StockholdersEquity, EarningsPerShareBasic

  help            Show this help message

Notes:
  - No API key required (free public API)
  - CIK numbers are automatically padded to 10 digits
  - Rate limit: 10 requests per second per IP
  - Find CIK numbers via the search command or at sec.gov/cgi-bin/browse-edgar
HELP
    ;;
esac
