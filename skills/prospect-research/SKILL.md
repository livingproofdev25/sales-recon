---
name: Prospect Research
description: This skill should be used when the user asks to "research a person", "find info on", "look up", "profile a prospect", "find contact info", "find email", "enrich leads", "identify decision makers", "research a company", "build prospect list", or needs guidance on professional research methods for sales prospecting and lead generation.
version: 2.0.0
---

# Prospect Research for Sales

Comprehensive methodology for building professional profiles and company assessments using public data sources. This skill transforms raw names and company identifiers into actionable sales profiles.

## Core Principles

### Data Source Hierarchy

Query sources in order of reliability and cost-effectiveness:

1. **Hunter.io** (highest confidence for email)
   - Domain search for company emails
   - Email verification
   - Email finder with confidence scores

2. **Google Maps/Places API** (business verification)
   - Confirm company exists and is operational
   - Get verified address, phone, hours
   - Reviews indicate company health

3. **SerpAPI** (web search aggregation)
   - LinkedIn profiles (public data)
   - Company news and press releases
   - Social media presence
   - Publications and speaking engagements

4. **Direct web research** (supplementary)
   - Company websites for team pages
   - Press releases for executive changes
   - Job postings for org structure clues

### Verification Protocol

Never trust single-source data. Cross-reference using:

- **Email confidence**: Hunter.io provides confidence scores (accept >80%)
- **Phone verification**: Google Maps confirms business phone
- **Title validation**: LinkedIn + company website agreement
- **Recency check**: Prefer data updated within 6 months

## Contact Research Workflow

### Step 1: Initial Search

Start with the most specific identifiers available:
- Full name + company
- Full name + location
- Email address (if known)
- LinkedIn URL (if known)

### Step 2: Email Discovery

Use Hunter.io's email finder:
```
Domain: company.com
First name: John
Last name: Smith
-> john.smith@company.com (95% confidence)
```

Verify discovered emails before storing.

### Step 3: Professional Profile

Gather from SerpAPI LinkedIn search:
- Current title and company
- Previous roles (work history)
- Education background
- Skills and endorsements
- Mutual connections

### Step 4: Professional Presence

Search for additional profiles:
- Twitter/X (industry thought leadership)
- GitHub (technical roles)
- Medium/Substack (content creators)
- Speaking engagements (conference sites)

### Step 5: Decision-Maker Scoring

Calculate a 1-10 decision-maker score based on:

| Factor | Points |
|--------|--------|
| C-level title | +4 |
| VP/Director title | +3 |
| Manager title | +2 |
| "Head of" or "Lead" | +2 |
| Budget keywords in title | +1 |
| 5+ years at company | +1 |
| Previous purchasing roles | +1 |

## Company Research Workflow

### Step 1: Basic Verification

Use Google Maps/Places API to confirm:
- Company exists at stated location
- Current operating status
- Verified contact information
- Review sentiment analysis

### Step 2: Company Profile

Gather from multiple sources:
- Industry classification (SIC/NAICS)
- Employee count range
- Revenue estimate (if available)
- Founded date
- Headquarters location
- Additional office locations

### Step 3: Leadership Identification

Build executive roster:
1. Search "[Company] leadership team"
2. Search "[Company] executives"
3. Check company website /about or /team pages
4. Cross-reference with LinkedIn company page

### Step 4: Employee Roster

For full org analysis:
1. Hunter.io domain search (returns all known emails)
2. SerpAPI LinkedIn company employees search
3. Categorize by department and seniority
4. Identify reporting structures where possible

### Step 5: Decision-Maker Mapping

Identify buyers with authority:
- Find people with "purchasing", "procurement", "vendor" in title
- Determine who manages the relevant department
- Map C-level stakeholders
- Document the typical buying committee structure

### Step 6: Market Position

Research competitive landscape:
- Direct competitors (same product/service)
- Recent news (funding, launches, pivots)
- Job postings (indicate growth areas)
- Tech stack (BuiltWith, Wappalyzer)

## Output Formats

### Contact Profile

```markdown
# Contact Profile: [Full Name]

## Contact Information
- **Email**: verified@company.com (95% confidence)
- **Phone**: +1-555-123-4567 (business)
- **LinkedIn**: linkedin.com/in/username
- **Twitter**: @handle

## Professional Profile
- **Current Role**: VP of Engineering at Acme Corp
- **Tenure**: 3 years, 4 months
- **Location**: San Francisco, CA

## Work History
1. VP Engineering, Acme Corp (2022-present)
2. Director Engineering, Previous Co (2019-2022)
3. Senior Engineer, First Job (2015-2019)

## Education
- MS Computer Science, Stanford University
- BS Engineering, UC Berkeley

## Professional Presence
- Active on Twitter (12k followers)
- GitHub contributor (open source projects)
- Conference speaker (DevCon 2024)

## Decision-Maker Score: 8/10
- VP title (+3)
- 3+ years tenure (+1)
- Technical budget authority implied (+2)
- Previously evaluated vendors (+2)
```

### Company Profile

```markdown
# Company Profile: [Company Name]

## Overview
- **Industry**: Enterprise Software (SIC: 7372)
- **Founded**: 2015
- **Employees**: 250-500
- **Revenue**: $50M-$100M (estimated)
- **Funding**: Series C ($45M)

## Location
- **HQ**: 123 Main St, San Francisco, CA 94102
- **Phone**: +1-555-000-0000
- **Website**: https://company.com

## Leadership
| Name | Title | Email | DM Score |
|------|-------|-------|----------|
| Jane CEO | CEO | jane@company.com | 10 |
| John CTO | CTO | john@company.com | 9 |
| Sarah VP Sales | VP Sales | sarah@company.com | 8 |

## Department Breakdown
- Engineering: 120 employees
- Sales: 45 employees
- Marketing: 25 employees
- Operations: 35 employees

## Decision Makers (Your Product Category)
1. **Primary**: Sarah VP Sales (budget holder)
2. **Technical**: John CTO (technical approval)
3. **Executive**: Jane CEO (final sign-off)

## Recent News
- [2024-01] Announced Series C funding
- [2024-02] Launched new product line
- [2024-03] Expanded to European market

## Competitors
- Competitor A (larger, enterprise focus)
- Competitor B (similar size, SMB focus)
- Competitor C (emerging, AI-native)
```

## ICP Scoring

When an ICP configuration exists (`.prospector/icp.json`, created via `/set-icp`), apply scoring to all research results.

### Formula
```
ICP Score = (company_fit * 0.6) + (contact_fit * 0.4)
```

### Company Fit (0-100)
- Industry match: Primary = 100, Secondary = 75, Adjacent = 40
- Size match: Within range = 100, Within 2x = 60, Outside = 20
- Tech stack: (matched / total indicators) * 100

### Contact Fit (0-100)
- Title match: Exact P1 = 100, Exact P2-3 = 85, Partial = 60, Related = 40
- Seniority: Exact = 100, One level off = 70, Two+ = 20

### Match Levels
- **Strong** (80+): Prioritize outreach
- **Good** (60-79): Include in campaigns
- **Moderate** (40-59): Consider if intent signals are strong
- **Poor** (<40): Deprioritize

See `references/icp-methodology.md` for detailed scoring rubrics.

## Buying Intent Signals

When researching companies, check for these 5 signal types:

1. **Hiring signals** (30% weight) — Job postings suggesting need for your product
2. **Funding signals** (25% weight) — Recent capital raise = spending budget
3. **Leadership changes** (20% weight) — New exec = new priorities, 90-day buying window
4. **Tech stack changes** (15% weight) — Migrations or evaluations underway
5. **Competitor dissatisfaction** (10% weight) — Negative reviews, switching mentions

### Intent Score (0-100)
```
Intent = (hiring * 0.30) + (funding * 0.25) + (leadership * 0.20) + (tech * 0.15) + (dissatisfaction * 0.10)
```

Apply recency multiplier: 30 days = 1.0x, 90 days = 0.8x, 180 days = 0.6x, 365 days = 0.4x

### Classification
- **HOT** (80+): Immediate outreach
- **WARM** (60-79): Active campaign
- **NURTURE** (40-59): Check back in 30 days
- **NOT READY** (<40): Low priority

See `references/intent-signals.md` for detailed search queries and scoring rubrics.

## Priority Timing

Combines ICP fit and buying intent into a single priority score.

### Formula
```
Timing Score = (ICP * 0.4) + (Intent * 0.6)
```

### ICP Gating
If ICP Score < 50, Timing is capped at NURTURE regardless of Intent. This prevents pursuing poor-fit prospects even when intent signals are strong.

### Priority Levels
| Timing Score | Level | Action | Timeline |
|-------------|-------|--------|----------|
| 80-100 | Immediate | Personalized outreach referencing top signal | Today |
| 60-79 | High | Add to active campaign sequence | This week |
| 40-59 | Medium | Nurture sequence, monitor for new signals | This month |
| 0-39 | Low | Park and re-check in 90 days | Next quarter |

### In Batch Reports
When processing batches, leads are grouped by timing priority and sorted within each group. The summary shows the distribution across priority buckets and the top signal for each lead.

## Competitive Displacement

When analyzing companies, assess competitive displacement opportunities:

1. **Vendor detection**: Map current tech stack from job postings, BuiltWith, blog mentions
2. **Dissatisfaction signals**: Check G2/Capterra reviews, community complaints, switching discussions
3. **Switching triggers**: Pricing changes, feature gaps, support issues, scale limitations
4. **Talking points**: Generate displacement arguments based on detected pain points

Competitive analysis is included briefly in `/research-company` and available in full via `/check-competitors`.

## API Integration Patterns

### Hunter.io

```python
# Email finder
GET https://api.hunter.io/v2/email-finder
  ?domain=company.com
  &first_name=John
  &last_name=Smith
  &api_key=$HUNTER_API_KEY

# Domain search (all emails)
GET https://api.hunter.io/v2/domain-search
  ?domain=company.com
  &api_key=$HUNTER_API_KEY
```

### Google Maps/Places

```python
# Place search
GET https://maps.googleapis.com/maps/api/place/findplacefromtext/json
  ?input=Acme+Corp+San+Francisco
  &inputtype=textquery
  &fields=name,formatted_address,formatted_phone_number
  &key=$GOOGLE_MAPS_KEY

# Place details
GET https://maps.googleapis.com/maps/api/place/details/json
  ?place_id=ChIJ...
  &fields=name,formatted_address,formatted_phone_number,website,reviews
  &key=$GOOGLE_MAPS_KEY
```

### SerpAPI

```python
# LinkedIn profile search
GET https://serpapi.com/search
  ?engine=google
  &q=John+Smith+VP+Engineering+site:linkedin.com
  &api_key=$SERPAPI_KEY

# Company news search
GET https://serpapi.com/search
  ?engine=google
  &q="Acme+Corp"+news
  &tbs=qdr:m  # Past month
  &api_key=$SERPAPI_KEY
```

## Data Quality Standards

### Confidence Thresholds

| Data Type | Accept | Verify | Reject |
|-----------|--------|--------|--------|
| Email | >80% | 50-80% | <50% |
| Phone | Verified | Google Maps | Unverified |
| Title | Multi-source | Single source | Outdated |
| Address | Google Maps | Company site | Unverified |

### Freshness Requirements

- **Contact info**: Verify if >6 months old
- **Job titles**: May change frequently, cross-reference
- **Company data**: Revenue/size estimates valid ~1 year
- **News**: Focus on past 6 months for relevance

## Additional Resources

### Reference Files

For detailed techniques and patterns:
- **`references/data-sources.md`** - Complete API documentation and rate limits
- **`references/research-patterns.md`** - Web research techniques and data extraction patterns

### Scripts

Utility scripts in `$CLAUDE_PLUGIN_ROOT/scripts/`:
- **`format-report.py`** - Format profiles into markdown/JSON/CSV
- **`export-leads.py`** - Export batch results to various formats
