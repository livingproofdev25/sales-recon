---
name: recon-company
description: Full organization intelligence with employee roster and decision-makers
argument-hint: "Company Name" [location]
allowed-tools: Read, Write, Grep, Glob, Bash, WebSearch, WebFetch, Task
---

Gather comprehensive organization intelligence on: $ARGUMENTS

Use the OSINT Tradecraft skill for methodology guidance.

## Intelligence Gathering Process

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

### Step 7: Competitive Intelligence

Research:
- Direct competitors (same product/service)
- Recent news (funding, launches, pivots)
- Job postings (growth indicators)
- Customer reviews (pain points)

### Step 8: Generate Report

Output a comprehensive Company Intelligence Report:

```markdown
# Company Intelligence: [Company Name]

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

## Tech Stack
[List detected technologies from website]

## Growth Indicators
- Open positions: [Count by department]
- Recent hires: [Notable additions]
- Expansion signs: [New offices, products]

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

Store results for potential `/recon-export` later.
