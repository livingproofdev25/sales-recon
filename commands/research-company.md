---
name: research-company
description: Full company profile with leadership team and decision-makers
argument-hint: "Company Name" [location]
allowed-tools: Read, Write, Grep, Glob, Bash, WebSearch, WebFetch, Task
---

Build a comprehensive company profile on: $ARGUMENTS

Use the Prospect Research skill for methodology guidance.

## Research Process

### Step 1: Parse Input
Extract from "$ARGUMENTS":
- **Company name**: The quoted name or primary identifier
- **Location hint**: Any location context (city, HQ location)

### Step 2: Business Verification

**Google Maps/Places API**:
Search for company to verify:
- Exact business name
- Physical address (HQ)
- Phone number
- Website URL
- Operating hours
- Review sentiment

### Step 3: Company Profile Research

**SerpAPI Company Search**:
- "[Company] about page"
- "[Company] company info"
- "[Company] LinkedIn company"
- "[Company] Crunchbase" (for funding/size)

Gather:
- Industry classification
- Employee count range
- Revenue estimate (if available)
- Founded date
- Funding history
- Tech stack (BuiltWith)

### Step 4: Leadership Identification

**Executive Research**:
- Search "[Company] leadership team"
- Search "[Company] executives"
- Check company website /about, /team, /leadership pages
- LinkedIn company page "People" section

Build executive roster with:
- Name
- Title
- Email (via Hunter.io)
- LinkedIn profile
- Decision-maker score

### Step 5: Full Employee Roster

**Hunter.io Domain Search**:
Query company domain for all known emails.

**LinkedIn Company Employees**:
Search "site:linkedin.com [Company] [department]" for:
- Engineering
- Sales
- Marketing
- Product
- Operations
- Finance

Categorize by:
- Department
- Seniority level
- Potential buyer role

### Step 6: Decision-Maker Mapping

Identify key buyers:
- Who has purchasing/procurement in title?
- Department heads for your product category
- C-level stakeholders
- Typical buying committee structure

### Step 7: Market Position

Research:
- Direct competitors (same product/service)
- Recent news (funding, launches, pivots)
- Job postings (growth indicators)
- Customer reviews (pain points)

### Step 8: Basic Signal Check

Run a quick buying intent scan (abbreviated version of `/check-signals`):
- Search for recent funding news (last 6 months)
- Check for leadership changes
- Look for relevant hiring activity
- Summarize top 1-3 signals found
- Include intent score if enough signals detected

### Step 9: ICP Scoring (if configured)

Check if `.prospector/icp.json` exists:
- If found, calculate company-level ICP score
- Score: industry match + size match + tech stack match
- Classify: Strong (80+), Good (60-79), Moderate (40-59), Poor (<40)
- If not configured, skip and add note: "Run /set-icp to enable ICP scoring"

### Step 9: Generate Report

Output a comprehensive Company Profile:

```markdown
# Company Profile: [Company Name]

## Overview
- **Industry**: [Industry] (SIC/NAICS: [code])
- **Founded**: [Year]
- **Employees**: [Range]
- **Revenue**: [Estimate]
- **Funding**: [Total raised, last round]
- **Website**: [URL]

## Headquarters
- **Address**: [Full address]
- **Phone**: [Verified phone]
- **Google Rating**: [X/5] ([N] reviews)

## Leadership Team

| Name | Title | Email | LinkedIn | DM Score |
|------|-------|-------|----------|----------|
| [Name] | CEO | [email] | [URL] | 10 |
| [Name] | CTO | [email] | [URL] | 9 |
| [Name] | VP Sales | [email] | [URL] | 8 |

## Department Breakdown

| Department | Count | Key Contacts |
|------------|-------|--------------|
| Engineering | [N] | [Names] |
| Sales | [N] | [Names] |
| Marketing | [N] | [Names] |
| Product | [N] | [Names] |

## Decision Makers (Buying Committee)
1. **Primary Budget Holder**: [Name, Title]
2. **Technical Evaluator**: [Name, Title]
3. **Executive Sponsor**: [Name, Title]
4. **End Users**: [Department/Roles]

## Recent News
- [Date] [Headline] ([Source])
- [Date] [Headline] ([Source])
- [Date] [Headline] ([Source])

## Competitors
| Company | Size | Positioning |
|---------|------|-------------|
| [Competitor 1] | [Size] | [Focus] |
| [Competitor 2] | [Size] | [Focus] |

## Competitive Landscape (Brief)
- **Known vendors**: [List detected tools/vendors from job posts and web]
- **Displacement opportunity**: [High/Medium/Low/Unknown]
- **Key pain point** (if detected): [Brief description]
> Run `/check-competitors "[Company]"` for full displacement analysis

## Buying Signals
| Signal | Score | Finding |
|--------|-------|---------|
| [Type] | [X]/100 | [Brief description] |
| [Type] | [X]/100 | [Brief description] |

**Intent Score**: [X]/100 — [HOT/WARM/NURTURE/NOT READY]
> Run `/check-signals "[Company]"` for full signal analysis

## Tech Stack
[List detected technologies from website]

## ICP Fit: [X]/100 ([Strong/Good/Moderate/Poor] Match)
- Industry: [X]/100
- Size: [X]/100
- Tech stack: [X]/100

## Growth Indicators
- Open positions: [Count by department]
- Recent hires: [Notable additions]
- Expansion signs: [New offices, products]

## Priority & Timing

**Timing Score**: [X]/100 — [Priority Level]
- Formula: `Timing = (ICP * 0.4) + (Intent * 0.6)`
- ICP Gate: [Applied/Not applied] (ICP < 50 caps at NURTURE)

**Recommended Action**: [Specific next step]
**Timeline**: [Immediate / This week / This month / Next quarter]

### Signal Timeline
1. [Date]: [Event description]
2. [Date]: [Event description]
3. [Date]: [Event description]

## Data Sources
- Google Maps: [Verified address/phone]
- Hunter.io: [X emails found]
- LinkedIn: [Employee data source]
- News: [Sources used]

## Confidence Assessment
- Company verification: [High/Medium/Low]
- Employee data freshness: [Recent/Moderate/Stale]
- Notes: [Any data quality concerns]
```

Store results for potential `/export-leads` later.
