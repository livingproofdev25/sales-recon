#!/bin/bash
# GitHub API wrapper — org data, repos, tech stack, contributors
# Usage: github-api.sh <command> [args...]
# Commands:
#   org           <org-name>                                  Get organization info
#   repos         <org-name> [--limit N] [--sort X]           List org repositories
#   languages     <org-name>                                  Aggregate tech stack across repos
#   contributors  <org/repo> [--limit N]                      List repo contributors
#   search-org    <company-name>                              Search for org by company name
#   help                                                      Show this help

set -euo pipefail

# Load optional token from environment or settings file (works without it at 60 req/hr)
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
SETTINGS_FILE="${HOME}/.claude/sales-recon.local.md"
if [ -z "$GITHUB_TOKEN" ] && [ -f "$SETTINGS_FILE" ]; then
  GITHUB_TOKEN=$(grep -oP 'github_token:\s*\K\S+' "$SETTINGS_FILE" 2>/dev/null || echo "")
fi

BASE_URL="https://api.github.com"
COMMAND="${1:-help}"
shift || true

# Build common headers
HEADERS=(-H "Accept: application/vnd.github+json")
if [ -n "$GITHUB_TOKEN" ]; then
  HEADERS+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

gh_get() {
  curl -sf "${HEADERS[@]}" "$1"
}

case "$COMMAND" in
  org)
    ORG="${1:-}"
    if [ -z "$ORG" ]; then
      echo '{"error": "Usage: github-api.sh org <org-name>"}' >&2
      exit 1
    fi
    gh_get "${BASE_URL}/orgs/${ORG}"
    ;;

  repos)
    ORG="${1:-}"
    shift || true
    if [ -z "$ORG" ]; then
      echo '{"error": "Usage: github-api.sh repos <org-name> [--limit N] [--sort stars|updated|pushed]"}' >&2
      exit 1
    fi
    LIMIT=30 SORT="updated"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --limit) LIMIT="$2"; shift 2 ;;
        --sort)  SORT="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done
    # GitHub API uses sort=stars as stargazers_count, or updated/pushed directly
    SORT_PARAM="$SORT"
    if [ "$SORT" = "stars" ]; then
      SORT_PARAM="stargazers_count"
      # For stars, we need to use a different approach — sort by stars descending
      gh_get "${BASE_URL}/orgs/${ORG}/repos?per_page=${LIMIT}&sort=created&direction=desc" | \
        python3 -c "
import sys, json
repos = json.load(sys.stdin)
repos.sort(key=lambda r: r.get('stargazers_count', 0), reverse=True)
json.dump(repos[:${LIMIT}], sys.stdout, indent=2)
"
    else
      gh_get "${BASE_URL}/orgs/${ORG}/repos?per_page=${LIMIT}&sort=${SORT_PARAM}&direction=desc"
    fi
    ;;

  languages)
    ORG="${1:-}"
    if [ -z "$ORG" ]; then
      echo '{"error": "Usage: github-api.sh languages <org-name>"}' >&2
      exit 1
    fi
    # Get top 10 repos by stars, then aggregate languages
    REPOS_JSON=$(gh_get "${BASE_URL}/orgs/${ORG}/repos?per_page=10&sort=stargazers_count&direction=desc")
    # For each repo, fetch languages and aggregate
    python3 -c "
import sys, json, subprocess

repos = json.loads('''${REPOS_JSON}''')
aggregate = {}
headers = ['-H', 'Accept: application/vnd.github+json']
token = '${GITHUB_TOKEN}'
if token:
    headers += ['-H', f'Authorization: Bearer {token}']

for repo in repos[:10]:
    full_name = repo.get('full_name', '')
    if not full_name:
        continue
    cmd = ['curl', '-sf'] + headers + [f'${BASE_URL}/repos/{full_name}/languages']
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode == 0:
        try:
            langs = json.loads(result.stdout)
            for lang, bytes_count in langs.items():
                aggregate[lang] = aggregate.get(lang, 0) + bytes_count
        except json.JSONDecodeError:
            pass

# Sort by total bytes descending
sorted_langs = dict(sorted(aggregate.items(), key=lambda x: x[1], reverse=True))
output = {
    'organization': '${ORG}',
    'repos_analyzed': min(len(repos), 10),
    'languages': sorted_langs,
    'primary_language': next(iter(sorted_langs), None)
}
json.dump(output, sys.stdout, indent=2)
"
    ;;

  contributors)
    REPO="${1:-}"
    shift || true
    if [ -z "$REPO" ]; then
      echo '{"error": "Usage: github-api.sh contributors <org/repo> [--limit N]"}' >&2
      exit 1
    fi
    LIMIT=30
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --limit) LIMIT="$2"; shift 2 ;;
        *) echo "{\"error\": \"Unknown flag: $1\"}" >&2; exit 1 ;;
      esac
    done
    gh_get "${BASE_URL}/repos/${REPO}/contributors?per_page=${LIMIT}"
    ;;

  search-org)
    COMPANY="${1:-}"
    if [ -z "$COMPANY" ]; then
      echo '{"error": "Usage: github-api.sh search-org <company-name>"}' >&2
      exit 1
    fi
    ENCODED_Q=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${COMPANY}'))")
    gh_get "${BASE_URL}/search/users?q=${ENCODED_Q}+type:org"
    ;;

  help|*)
    cat <<'HELP'
GitHub API wrapper — organization data, repos, and tech stack analysis

Usage: github-api.sh <command> [args...]

Commands:
  org           <org-name>
                Get organization profile (bio, location, blog, members count)

  repos         <org-name> [--limit N] [--sort stars|updated|pushed]
                List organization repositories sorted by criteria

  languages     <org-name>
                Aggregate programming languages across top 10 repos (tech stack)

  contributors  <org/repo> [--limit N]
                List contributors for a specific repository

  search-org    <company-name>
                Search for a GitHub organization by company name

  help          Show this help message

Environment:
  GITHUB_TOKEN    Optional GitHub personal access token for higher rate limits
                  Without token: 60 requests/hour. With token: 5,000 requests/hour.
                  (or set github_token in ~/.claude/sales-recon.local.md)
HELP
    ;;
esac
