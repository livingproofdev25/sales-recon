# Sales Recon

FBI-level lead intelligence gathering for Claude Code. Solves lead data decay problems with real-time, multi-source intelligence gathering.

## Features

- **Person Intelligence**: Deep profiles including contact info, work history, social media, decision-maker scoring
- **Business Intelligence**: Full org intel with employee rosters, org charts, decision-makers, news, competitors
- **Batch Processing**: Enrich up to 50 leads at once from CSV files
- **Auto-Detection**: Keyword-triggered intel gathering ("research", "find info on", "look up")
- **Export**: JSON and CSV exports for CRM integration

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
| `/recon-person "Name" [location]` | Deep profile on an individual |
| `/recon-company "Company"` | Full organization intelligence |
| `/recon-batch file.csv` | Bulk enrich leads from CSV |
| `/recon-export [json\|csv]` | Export last results |

## Usage Examples

```
/recon-person "John Smith" San Francisco
/recon-company "Acme Corp"
/recon-batch leads.csv
/recon-export csv
```

Or use natural language with trigger words:
- "Research the CEO of Tesla"
- "Find info on Jane Doe at Microsoft"
- "Look up Stripe's engineering team"

## Data Sources

- **Hunter.io**: Email discovery, domain search, email verification
- **Google Maps/Places**: Business verification, locations, reviews
- **SerpAPI**: Web search, news, social profiles
- **Web Scraping**: LinkedIn (public), company websites, press releases

## Hooks (Automation)

| Hook | Trigger | Behavior |
|------|---------|----------|
| Lead Detector | Keywords in messages | Offers to research mentioned names |
| Auto-Enricher | Edit lead CSV files | Offers to enrich new entries |
| Session Briefing | Session start | Shows pending research tasks |
| Export Validator | Export operations | Validates data quality |

## Output Format

### Person Intelligence Report
- Contact: Email, phone, LinkedIn, Twitter
- Professional: Current role, company, work history, education
- Social: Social media profiles, publications, speaking engagements
- Decision-Maker Score: 1-10 rating based on title and influence indicators

### Company Intelligence Report
- Overview: Name, industry, size, revenue estimate, founded
- Location: HQ address, additional offices
- Leadership: Key executives with contact info
- Employees: Full roster with roles and departments
- Decision-Makers: Identified buyers with authority levels
- News: Recent press, funding, product launches
- Competitors: Similar companies in space

## License

MIT
