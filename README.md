# Sales-Recon v3.0.0

> Comprehensive lead intelligence platform for Claude Code -- research companies, find decision makers, detect buying signals, analyze financials, pull building permits, and generate personalized outreach.

## Features

- **50+ data fields** per lead across company profile, financials, contacts, signals, property
- **8 API integrations** -- Hunter.io, Apollo.io, SerpAPI, Google Places, GitHub, SEC EDGAR, Socrata, RentCast
- **14 slash commands** -- 7 B2B, 3 residential, 4 shared
- **Dual pipelines** -- B2B (companies & decision makers) + Residential (permits & homeowners)
- **Intelligent scoring** -- ICP fit, buying intent, priority ranking, decision-maker scoring
- **Cost optimized** -- ~$99/mo total (free APIs prioritized, paid APIs used strategically)

## Quick Start

### 1. Install

Add as a Claude Code plugin by pointing to the plugin directory:

```bash
claude plugin add /path/to/sales-recon
```

Or symlink into your Claude plugins directory:

```bash
ln -s /path/to/sales-recon ~/.claude/plugins/sales-recon
```

### 2. Configure API Keys

Run the settings command to configure your API keys interactively:

```
/lead-settings
```

This stores keys in `~/.claude/sales-recon.local.md`. Alternatively, set environment variables:

```bash
export HUNTER_API_KEY="your-key"       # https://hunter.io/api
export APOLLO_API_KEY="your-key"       # https://app.apollo.io/#/settings/integrations/api
export SERPAPI_KEY="your-key"           # https://serpapi.com/manage-api-key
export GOOGLE_PLACES_API_KEY="your-key" # https://console.cloud.google.com/apis/credentials
export RENTCAST_API_KEY="your-key"     # https://app.rentcast.io/app/api
```

GitHub API, SEC EDGAR, and Socrata are free and do not require keys (rate-limited by IP).

### 3. Your First Command

```
/prospect "Stripe"
```

This runs a full B2B research pipeline: company profile, leadership roster, tech stack, buying signals, ICP scoring, and outreach recommendations. Expect a detailed report in 15-30 seconds.

## Commands

### B2B Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/prospect <company>` | Full company research pipeline with scoring | `/prospect "Databricks"` |
| `/deep-research <company>` | Extended research with financials, GitHub, news | `/deep-research "Snowflake"` |
| `/find-contacts <company> [role]` | Find decision makers with emails and phones | `/find-contacts "Stripe" "VP Engineering"` |
| `/check-signals <company>` | Detect buying intent signals (hiring, funding, tech changes) | `/check-signals "Figma"` |
| `/check-financials <company>` | SEC filings, revenue, funding rounds, burn rate | `/check-financials "Palantir"` |
| `/score-icp <company>` | Score a company against your ICP criteria | `/score-icp "Vercel"` |
| `/set-icp` | Define or update your Ideal Customer Profile | `/set-icp` |

### Residential Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/find-permits <city> <state> [type]` | Search building permits by location and type | `/find-permits "Austin" "TX" "residential"` |
| `/property-lookup <address>` | Property details, valuation, owner info | `/property-lookup "123 Main St, Austin TX"` |
| `/homeowner-leads <city> <state>` | Generate homeowner leads from recent permits | `/homeowner-leads "Denver" "CO"` |

### Shared Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/enrich-batch <file>` | Bulk enrich leads from CSV (up to 50 rows) | `/enrich-batch leads.csv` |
| `/export-leads [format]` | Export current session leads as JSON or CSV | `/export-leads csv` |
| `/craft-outreach <name> [company]` | Generate personalized multi-channel outreach | `/craft-outreach "Sarah Chen" "Stripe"` |
| `/lead-settings` | View and configure API keys and preferences | `/lead-settings` |

## Data Sources

| Source | Cost | What It Provides | Script |
|--------|------|------------------|--------|
| **Hunter.io** | $49/mo (500 requests) | Email discovery, domain search, email verification | `hunter-api.sh` |
| **Apollo.io** | $49/mo (2,500 credits) | Firmographics, direct phones, org charts, technographics | `apollo-api.sh` |
| **SerpAPI** | Free tier (100/mo) | Web search, news, job postings, social profiles | `serp-api.sh` |
| **Google Places** | Free ($200 credit/mo) | Business verification, locations, reviews, hours | `google-places-api.sh` |
| **GitHub API** | Free (5,000 req/hr) | Tech stack detection, repo activity, team size | `github-api.sh` |
| **SEC EDGAR** | Free (10 req/sec) | Financial filings, revenue, insider transactions | `sec-edgar-api.sh` |
| **Socrata (Open Data)** | Free (1,000 req/hr) | Building permits, code violations, property records | `socrata-permits-api.sh` |
| **RentCast** | Free tier (50/mo) | Property valuation, rent estimates, owner info | `rentcast-api.sh` |

Utility scripts: `export-leads.py` (CSV/JSON export), `format-report.py` (Markdown report generation).

## Scoring Systems

### ICP Score (0-100)

Weighted composite of company and contact fit:

```
ICP = (company_fit * 0.6) + (contact_fit * 0.4)
```

- **Strong fit (80-100):** High priority, matches most ICP criteria
- **Good fit (60-79):** Worth pursuing, matches core criteria
- **Moderate fit (40-59):** Conditional, monitor for changes
- **Poor fit (0-39):** Deprioritize unless signals change

Company fit factors: industry match, employee count range, revenue range, tech stack overlap, geography.
Contact fit factors: title seniority, department match, tenure, decision authority.

### Intent Score (0-100)

Five weighted signal types detect buying readiness:

| Signal | Weight | Examples |
|--------|--------|----------|
| Hiring patterns | 30% | Job posts for roles your product supports |
| Funding events | 25% | Recent raise, IPO filing, acquisition |
| Leadership changes | 20% | New CXO, VP, department head |
| Tech stack changes | 15% | Migration signals, new tool adoption |
| Competitor dissatisfaction | 10% | Negative reviews, churn indicators |

Levels: **HOT** (80+), **WARM** (60-79), **NURTURE** (40-59), **NOT READY** (<40).

### Priority Score

Combines ICP and intent with gating logic:

```
Priority = (ICP * 0.4) + (Intent * 0.6)
```

**ICP gating:** If ICP < 50, priority is capped at NURTURE regardless of intent. This prevents wasting outreach on poor-fit companies even when they show buying signals.

### Decision-Maker Score (1-10)

Scores individual contacts on purchasing influence:

- **Title seniority** (C-level = 10, VP = 8, Director = 6, Manager = 4)
- **Budget authority** (direct budget control adds +2)
- **Department relevance** (match to your product category)
- **Tenure** (>2 years = established influence)

### Residential Lead Score (0-100)

Four weighted factors for homeowner leads:

| Factor | Weight | Description |
|--------|--------|-------------|
| Permit value | 35% | Higher permit value = larger project budget |
| Permit recency | 25% | Recent permits indicate active projects |
| Property value | 25% | Higher property value = higher spend capacity |
| Permit type match | 15% | Alignment with your service category |

## Configuration

### Settings File

Location: `~/.claude/sales-recon.local.md`

The settings file uses YAML-style key-value pairs inside a Markdown document:

```markdown
# Sales-Recon Settings

## API Keys
hunter_api_key: sk-hunter-xxxxx
apollo_api_key: ak-apollo-xxxxx
serp_api_key: xxxxx
google_places_api_key: AIza-xxxxx
rentcast_api_key: xxxxx

## ICP Definition
target_industry: SaaS, FinTech
employee_range: 50-500
revenue_range: 5M-100M
target_titles: VP Engineering, CTO, Head of Platform
target_geography: US, Canada
tech_stack_match: React, Node.js, AWS
```

### API Keys

| API | Env Variable | Settings Key | Signup URL | Free Tier |
|-----|-------------|--------------|------------|-----------|
| Hunter.io | `HUNTER_API_KEY` | `hunter_api_key` | [hunter.io/api](https://hunter.io/api) | 25 requests/mo |
| Apollo.io | `APOLLO_API_KEY` | `apollo_api_key` | [apollo.io](https://app.apollo.io/#/settings/integrations/api) | 50 credits/mo |
| SerpAPI | `SERPAPI_KEY` | `serp_api_key` | [serpapi.com](https://serpapi.com/manage-api-key) | 100 searches/mo |
| Google Places | `GOOGLE_PLACES_API_KEY` | `google_places_api_key` | [console.cloud.google.com](https://console.cloud.google.com/apis/credentials) | $200 credit/mo |
| RentCast | `RENTCAST_API_KEY` | `rentcast_api_key` | [rentcast.io](https://app.rentcast.io/app/api) | 50 requests/mo |
| GitHub | -- | -- | -- | 5,000 req/hr (no key) |
| SEC EDGAR | -- | -- | -- | 10 req/sec (no key) |
| Socrata | -- | -- | -- | 1,000 req/hr (no key) |

Environment variables take precedence over settings file values.

## Rate Limits & Costs

| API | Monthly Limit (Paid) | Cost | Strategy |
|-----|---------------------|------|----------|
| Hunter.io | 500 requests | $49/mo | Cache results, batch domain searches |
| Apollo.io | 2,500 credits | $49/mo | Use for verified contacts only, cache aggressively |
| SerpAPI | 5,000 searches | $50/mo (or free 100) | Use free tier for low volume, upgrade as needed |
| Google Places | ~$200 credit | Free (credit) | Stays within free tier for most usage |
| GitHub | 5,000/hr | Free | No key required, generous limits |
| SEC EDGAR | 10/sec | Free | Rate-limit with 100ms delay between requests |
| Socrata | 1,000/hr | Free | Paginate large result sets |
| RentCast | 50-500/mo | Free-$29/mo | Use sparingly, cache property data |

**Total estimated cost: ~$99/mo** for moderate usage (50-100 prospects/month). Free APIs (GitHub, SEC EDGAR, Socrata) are used first; paid APIs are called only when needed for verified data.

## Plugin Structure

```
sales-recon/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest (v3.0.0)
├── commands/                    # 14 slash commands
│   ├── prospect.md              # /prospect — full B2B pipeline
│   ├── deep-research.md         # /deep-research — extended research
│   ├── find-contacts.md         # /find-contacts — decision maker search
│   ├── check-signals.md         # /check-signals — buying intent
│   ├── check-financials.md      # /check-financials — SEC/funding data
│   ├── score-icp.md             # /score-icp — ICP scoring
│   ├── set-icp.md               # /set-icp — define ICP criteria
│   ├── find-permits.md          # /find-permits — building permit search
│   ├── property-lookup.md       # /property-lookup — property details
│   ├── homeowner-leads.md       # /homeowner-leads — residential leads
│   ├── enrich-batch.md          # /enrich-batch — bulk enrichment
│   ├── export-leads.md          # /export-leads — CSV/JSON export
│   ├── craft-outreach.md        # /craft-outreach — outreach generation
│   └── lead-settings.md         # /lead-settings — configuration
├── scripts/                     # API wrappers and utilities
│   ├── hunter-api.sh            # Hunter.io email discovery
│   ├── apollo-api.sh            # Apollo.io firmographics & contacts
│   ├── serp-api.sh              # SerpAPI web/news search
│   ├── google-places-api.sh     # Google Places business data
│   ├── github-api.sh            # GitHub tech stack detection
│   ├── sec-edgar-api.sh         # SEC EDGAR financial filings
│   ├── socrata-permits-api.sh   # Socrata building permits
│   ├── rentcast-api.sh          # RentCast property data
│   ├── export-leads.py          # Lead export (CSV/JSON)
│   └── format-report.py         # Markdown report formatting
├── skills/                      # Skill definitions
│   ├── lead-intelligence/
│   │   ├── SKILL.md             # B2B research skill
│   │   └── references/          # B2B reference files
│   └── residential-intelligence/
│       ├── SKILL.md             # Residential research skill
│       └── references/          # Residential reference files
├── hooks/
│   ├── hooks.json               # Session startup hook
│   └── scripts/
│       └── session-briefing.sh  # API key check and command listing
├── .gitignore
└── README.md
```

## Changelog

### v3.0.0 (2026-02-15)

- Complete rebuild with 8 API integrations (was 3)
- Added Apollo.io for firmographics, direct phones, org charts
- Added SEC EDGAR for public company financials
- Added GitHub for tech stack detection
- Added residential pipeline (Socrata permits + RentCast property data)
- 14 commands (was 8)
- New: `/prospect`, `/deep-research`, `/find-contacts`, `/check-financials`, `/score-icp`, `/find-permits`, `/property-lookup`, `/homeowner-leads`, `/lead-settings`
- Updated: `/check-signals`, `/set-icp`, `/enrich-batch`, `/export-leads`, `/craft-outreach`
- Removed: `/research-contact`, `/research-company`, `/check-competitors` (functionality merged into new commands)
- Removed autonomous agents (now fully command-driven)
- New scoring: residential lead scoring, enhanced ICP framework
- Settings moved to `~/.claude/sales-recon.local.md`

### v2.0.0

- Initial release with Hunter.io, SerpAPI, Google Maps
- 8 commands, 2 agents, 1 skill

## License

MIT
