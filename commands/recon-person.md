---
name: recon-person
description: Deep intelligence profile on an individual person
argument-hint: "Name" [location]
allowed-tools: Read, Write, Grep, Glob, Bash, WebSearch, WebFetch, Task
---

Gather comprehensive intelligence on person: $ARGUMENTS

Use the OSINT Tradecraft skill for methodology guidance.

## Intelligence Gathering Process

### Step 1: Parse Input
Extract from "$ARGUMENTS":
- **Target name**: The quoted name or first words
- **Location hint**: Any location mentioned (city, state, company)

### Step 2: Multi-Source Research

Execute these data gathering steps:

**Hunter.io Email Discovery** (if company known):
Use WebFetch to query Hunter.io API for email patterns:
- Domain search for company
- Email finder with name

**SerpAPI LinkedIn Search**:
Search for "[Name] [Company/Location] site:linkedin.com" to find:
- Current title and company
- Work history
- Education
- Skills and endorsements

**Google Search for Social Presence**:
- Twitter/X profile
- GitHub (if technical role)
- Personal website or blog
- Speaking engagements
- Publications

**Google Maps Verification** (if company address needed):
Verify business location and contact info.

### Step 3: Cross-Validate Data

Verify findings across sources:
- Title consistency (Hunter vs LinkedIn)
- Company confirmation
- Recency of information

### Step 4: Calculate Decision-Maker Score

Score 1-10 based on:
| Factor | Points |
|--------|--------|
| C-level title | +4 |
| VP/Director | +3 |
| Manager | +2 |
| "Head of" or "Lead" | +2 |
| Budget keywords in title | +1 |
| 5+ years tenure | +1 |
| Previous purchasing roles | +1 |

### Step 5: Generate Report

Output a comprehensive Person Intelligence Report in this format:

```markdown
# Person Intelligence: [Full Name]

## Contact Information
- **Email**: [verified email] ([confidence]%)
- **Phone**: [if found]
- **LinkedIn**: [profile URL]
- **Twitter**: [if found]

## Professional Profile
- **Current Role**: [Title] at [Company]
- **Tenure**: [duration]
- **Location**: [City, State]

## Work History
1. [Current role] ([dates])
2. [Previous role] ([dates])
3. [Earlier role] ([dates])

## Education
- [Degree], [Institution]

## Social Presence
- [List all discovered profiles]

## Decision-Maker Score: [X]/10
- [Breakdown of scoring factors]

## Data Sources
- Hunter.io: [what was found]
- LinkedIn: [what was found]
- Other: [additional sources]

## Confidence Assessment
- Overall confidence: [High/Medium/Low]
- Verification notes: [any discrepancies]
```

If batch export is requested later, store results for `/recon-export` command.
