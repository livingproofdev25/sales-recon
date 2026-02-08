---
name: research-contact
description: Build a comprehensive professional profile on an individual
argument-hint: "Name" [company/location]
allowed-tools: Read, Write, Grep, Glob, Bash, WebSearch, WebFetch, Task
---

Build a comprehensive professional profile on: $ARGUMENTS

Use the Prospect Research skill for methodology guidance.

## Research Process

### Step 1: Parse Input
Extract from "$ARGUMENTS":
- **Person name**: The quoted name or first words
- **Context**: Any company, location, or role mentioned

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

**Google Search for Professional Presence**:
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

### Step 5: ICP Scoring (if configured)

Check if `.prospector/icp.json` exists:
- If found, calculate ICP score using the methodology in `references/icp-methodology.md`
- Score contact fit: title match + seniority match
- Score company fit: industry + size + tech stack (if company data available)
- Compute composite: `ICP = (company_fit * 0.6) + (contact_fit * 0.4)`
- Classify: Strong (80+), Good (60-79), Moderate (40-59), Poor (<40)
- If not configured, skip and add note: "Run /set-icp to enable ICP scoring"

### Step 6: Generate Report

Output a comprehensive Contact Profile in this format:

```markdown
# Contact Profile: [Full Name]

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

## Professional Presence
- [List all discovered profiles]

## Decision-Maker Score: [X]/10
- [Breakdown of scoring factors]

## ICP Score: [X]/100 ([Strong/Good/Moderate/Poor] Match)
- Company fit: [X]/100 (industry: [X], size: [X], tech: [X])
- Contact fit: [X]/100 (title: [X], seniority: [X])

## Outreach Recommendations
- **Best channel**: [Email/LinkedIn/Twitter] — [Why]
- **Top hooks**:
  1. [Hook type]: [Specific personalization angle]
  2. [Hook type]: [Specific personalization angle]
- **Suggested approach**: [Signal-led / Problem-led / Connection-led]
> Run `/craft-outreach "[Name]"` to generate full message variants

## Data Sources
- Hunter.io: [what was found]
- LinkedIn: [what was found]
- Other: [additional sources]

## Confidence Assessment
- Overall confidence: [High/Medium/Low]
- Verification notes: [any discrepancies]
```

If batch export is requested later, store results for `/export-leads` command.
