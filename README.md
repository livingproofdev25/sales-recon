# Prospector

B2B sales intelligence and buying intent platform for Claude Code. Transforms prospect names into actionable profiles with ICP scoring, buying signals, competitive analysis, and personalized outreach.

## Features

- **Contact Research**: Deep professional profiles including contact info, work history, social presence, decision-maker scoring
- **Company Research**: Full company profiles with leadership rosters, org charts, decision-makers, news, competitors
- **Batch Enrichment**: Enrich up to 50 leads at once from CSV files
- **ICP Scoring**: Define your Ideal Customer Profile and automatically score every prospect
- **Buying Intent Signals**: Detect hiring, funding, leadership changes, tech migrations, and competitor dissatisfaction
- **Competitive Displacement**: Identify switching triggers and generate displacement talking points
- **Outreach Generation**: Personalized multi-channel outreach with signal-led, problem-led, and connection-led variants
- **Auto-Detection**: Keyword-triggered research ("research", "find info on", "look up", "profile")
- **Export**: JSON and CSV exports for CRM integration (Salesforce, HubSpot, Pipedrive)

## Installation

```bash
# Add to your project
claude --plugin-dir /path/to/sales-recon

# Or copy to Claude plugins directory
cp -r sales-recon ~/.claude/plugins/
```

## Prerequisites

Set these environment variables before using:

```bash
export HUNTER_API_KEY="your-hunter-api-key"
export GOOGLE_MAPS_KEY="your-google-maps-api-key"
export SERPAPI_KEY="your-serpapi-key"
```

Get API keys from:
- Hunter.io: https://hunter.io/api
- Google Maps: https://console.cloud.google.com/apis/credentials
- SerpAPI: https://serpapi.com/manage-api-key

## Commands

| Command | Description |
|---------|-------------|
| `/research-contact "Name" [company]` | Build a professional profile on an individual |
| `/research-company "Company"` | Full company profile with leadership and decision-makers |
| `/enrich-batch file.csv` | Bulk enrich leads from CSV |
| `/export-leads [json\|csv]` | Export results for CRM import |
| `/set-icp` | Define your Ideal Customer Profile for scoring |
| `/check-signals "Company"` | Detect buying intent signals |
| `/check-competitors "Company"` | Competitive displacement analysis |
| `/craft-outreach "Name"` | Generate personalized outreach messages |

## Usage Examples

```
/research-contact "John Smith" Acme Corp
/research-company "Stripe"
/enrich-batch leads.csv
/export-leads csv
/set-icp
/check-signals "Databricks"
/check-competitors "Snowflake"
/craft-outreach "Sarah Chen"
```

Or use natural language:
- "Research the CEO of Tesla"
- "Find info on Jane Doe at Microsoft"
- "Look up Stripe's engineering team"
- "Check buying signals for Databricks"

## Data Sources

- **Hunter.io**: Email discovery, domain search, email verification
- **Google Maps/Places**: Business verification, locations, reviews
- **SerpAPI**: Web search, news, social profiles, job postings, reviews
- **Web Research**: LinkedIn (public), company websites, press releases

## Scoring Systems

### Decision-Maker Score (1-10)
Based on title seniority, budget authority, tenure, and purchasing history.

### ICP Score (0-100)
Weighted composite: `ICP = (company_fit * 0.6) + (contact_fit * 0.4)`
Match levels: Strong (80+), Good (60-79), Moderate (40-59), Poor (<40)

### Buying Intent Score (0-100)
Five signal types: Hiring (30%), Funding (25%), Leadership changes (20%), Tech stack changes (15%), Competitor dissatisfaction (10%)
Levels: HOT (80+), WARM (60-79), NURTURE (40-59), NOT READY (<40)

### Priority Timing
`Timing = (ICP * 0.4) + (Intent * 0.6)` with ICP gating (ICP < 50 caps at NURTURE)

## Hooks (Automation)

| Hook | Trigger | Behavior |
|------|---------|----------|
| Lead Detector | Keywords in messages | Offers to research mentioned names |
| Auto-Enricher | Edit lead CSV files | Offers to enrich new entries |
| Session Briefing | Session start | Shows available commands |
| Export Validator | Export operations | Validates data quality |

## Output Format

### Contact Profile
- Contact: Email, phone, LinkedIn, Twitter
- Professional: Current role, company, work history, education
- Presence: Social media profiles, publications, speaking engagements
- Decision-Maker Score: 1-10 rating based on title and influence indicators
- ICP Score: How well they match your ideal customer profile
- Outreach Recommendations: Best channel, personalization hooks

### Company Profile
- Overview: Name, industry, size, revenue estimate, founded
- Location: HQ address, additional offices
- Leadership: Key executives with contact info
- Decision-Makers: Identified buyers with authority levels
- Buying Signals: Detected intent indicators with freshness
- Competitive Landscape: Current vendors, dissatisfaction signals
- Priority & Timing: When to reach out and why

## License

MIT
