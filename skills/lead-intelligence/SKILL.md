---
name: Lead Intelligence
description: This skill should be used when the user asks to "research a company", "find leads", "prospect", "find decision makers", "check buying signals", "score ICP fit", "check financials", "enrich leads", "find emails", "deep research", or needs guidance on B2B lead generation methodology, scoring frameworks, and multi-source data enrichment.
version: 3.0.0
---

# B2B Lead Intelligence Methodology

Comprehensive framework for discovering, enriching, scoring, and prioritizing B2B leads using 8 data sources. All API calls use wrapper scripts in `${CLAUDE_PLUGIN_ROOT}/scripts/`.

## Data Source Hierarchy

Query sources in this order — most reliable and cost-effective first:

1. **Apollo.io** — Company firmographics, contacts with direct phone/email, org charts, revenue, tech stack, funding. Script: `apollo-api.sh`
2. **Hunter.io** — Email discovery with confidence scores, domain search, verification. Script: `hunter-api.sh`
3. **Google Places** — Business verification, address, phone, ratings, reviews. Script: `google-places-api.sh`
4. **SerpAPI** — Web/news/jobs search, LinkedIn profiles, hiring signals. Script: `serp-api.sh`
5. **GitHub** — Tech stack detection, team size, open-source activity. Script: `github-api.sh`
6. **SEC EDGAR** — Public company financials (10-K, 10-Q), revenue, earnings. Script: `sec-edgar-api.sh`

## Enrichment Pipeline

For every B2B lead, run this pipeline:

### 1. Discover
- `apollo-api.sh company-enrich --domain <domain>` → company firmographics
- `google-places-api.sh find "<company name> <city>"` → verify existence, get address/phone
- `hunter-api.sh domain-search <domain> --seniority executive` → executive emails

### 2. Enrich
- `apollo-api.sh org-chart --domain <domain>` → decision makers with titles, emails, phones
- `hunter-api.sh find-email --domain <domain> --first <name> --last <name>` → specific contact emails
- `serp-api.sh news "<company>" --num 10` → recent news and signals
- `serp-api.sh jobs "<company>"` → hiring activity
- `github-api.sh languages <org>` → tech stack
- `sec-edgar-api.sh search "<company>"` → financial data (public companies)

### 3. Score
Apply ICP scoring, intent scoring, and priority ranking. See `references/icp-framework.md` and `references/signal-weights.md`.

### 4. Output
Format results as a structured lead report with all gathered fields, scores, and recommended next actions.

## Decision-Maker Scoring (1-10)

| Factor | Points |
|--------|--------|
| C-level title (CEO, CTO, CFO, COO) | +4 |
| VP / SVP title | +3 |
| Director / "Head of" title | +2 |
| Manager title | +1 |
| Budget-related keywords in title (Procurement, Purchasing, Vendor) | +1 |
| 3+ years tenure at company | +1 |
| Department matches your product category | +1 |

## Verification Protocol

Never trust single-source data. Cross-reference:
- **Email confidence**: Hunter.io provides scores (accept >80%, verify 50-80%, reject <50%)
- **Phone verification**: Google Places confirms business phone, Apollo for direct dials
- **Title validation**: LinkedIn + company website + Apollo agreement
- **Recency check**: Prefer data updated within 6 months

## Data Quality Standards

| Data Type | Accept (use directly) | Verify (cross-reference) | Reject (discard) |
|-----------|----------------------|--------------------------|-------------------|
| Email | >80% confidence | 50-80% confidence | <50% confidence |
| Phone | Apollo direct dial | Google Places business | Unverified |
| Title | Multi-source match | Single source | >12 months old |
| Revenue | SEC filing | Apollo estimate | Unverified guess |

## API Rate Limits

| API | Monthly Limit | Per-Request Cost | Strategy |
|-----|---------------|-----------------|----------|
| Hunter.io | 25 (free tier) | 1 request | Verify top leads only, cache results |
| Apollo.io | 900 credits | 1 credit per person/company | Batch wisely, org-chart for bulk |
| SerpAPI | 5000 searches | 1 search | 1 per query type, cache results |
| Google Places | ~11K (free $200 credit) | $0.017 | Use for verification only |
| GitHub | 5000/hour | Free | Use freely |
| SEC EDGAR | Unlimited | Free | Rate limit to 10 req/sec |

Always prioritize free sources first. Use paid APIs (Hunter, Apollo, SerpAPI) only when free sources don't have the data.

## Output Templates

See the command files for specific output formats:
- `/prospect` — Ranked lead list with top fields
- `/deep-research` — Full company profile with all 50+ fields
- `/find-contacts` — Decision maker roster
- `/check-signals` — Buying intent report
- `/check-financials` — Financial intelligence report
