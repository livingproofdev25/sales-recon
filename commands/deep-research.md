---
name: deep-research
description: Deep-dive intelligence on a single company — firmographics, financials, decision makers, tech stack, signals, competitive landscape
argument-hint: "Company Name" [domain]
allowed-tools: Read, Write, Bash, WebSearch, WebFetch
---

Perform a comprehensive deep-dive intelligence report on: $ARGUMENTS

Use the Lead Intelligence skill for methodology.

## Process

### Step 1: Parse Input

Extract from "$ARGUMENTS":
- **Company name**: The target company (required)
- **Domain**: Company website domain (optional — will be resolved if not provided)

### Step 2: Resolve Domain

If no domain was provided, resolve it:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/apollo-api.sh company-enrich --domain <best-guess-domain>
```

If Apollo does not return a match, fall back to Google Places:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/google-places-api.sh find "<company name>"
```

Extract the domain from the website field in the response.

### Step 3: Company Profile

Pull firmographic data from Apollo:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/apollo-api.sh company-enrich --domain <domain>
```

Extract: name, industry, employee count, revenue estimate, founded year, funding stage, total funding, technologies, city, state, LinkedIn URL.

### Step 4: Google Places Verification

Verify business details and get additional data:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/google-places-api.sh find "<company name> <city>"
bash ${CLAUDE_PLUGIN_ROOT}/scripts/google-places-api.sh details "<place_id>"
```

Extract: verified address, phone, rating, review count, business status, opening hours.

### Step 5: Leadership & Org Chart

Pull the leadership team:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/apollo-api.sh org-chart --domain <domain> --limit 15
```

For the top 5 contacts, verify emails:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/hunter-api.sh find-email --domain <domain> --first <first> --last <last>
bash ${CLAUDE_PLUGIN_ROOT}/scripts/hunter-api.sh verify <email>
```

### Step 6: Full Employee Roster

Search for all public emails on the domain:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/hunter-api.sh domain-search <domain> --limit 20
```

Categorize contacts by department: Executive, Engineering, Sales, Marketing, Finance, Operations, HR, Legal, Other.

### Step 7: Decision-Maker Mapping

From the org chart and employee roster, identify the buying committee:
- **Primary Budget Holder**: The person who signs off on purchases (usually VP/C-level)
- **Technical Evaluator**: The person who evaluates technical fit (Director/Manager level)
- **Executive Sponsor**: The person who champions the initiative (C-level)

Score each decision maker 1-10 per the Lead Intelligence skill methodology.

### Step 8: Financial Intelligence

Check if the company is publicly traded:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/sec-edgar-api.sh search "<company name>"
```

If public (CIK found):

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/sec-edgar-api.sh company-facts <CIK>
bash ${CLAUDE_PLUGIN_ROOT}/scripts/sec-edgar-api.sh company-concept <CIK> Revenues
bash ${CLAUDE_PLUGIN_ROOT}/scripts/sec-edgar-api.sh company-concept <CIK> NetIncomeLoss
```

If private, use Apollo revenue estimate and search for funding news:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh news "<company> funding round raises" --num 5
```

### Step 9: Buying Signals

Run the 5-signal detection per signal-weights.md:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh jobs "<company>"
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh news "<company> funding" --num 5
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh news "<company> appoints new CTO VP" --num 5
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh search "<company> migrating evaluating platform" --time m
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh search "<company> problems switching alternative"
```

Score each signal 0-100, apply recency multiplier, calculate weighted Intent Score.

### Step 10: Tech Stack

If the company has a GitHub presence:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/github-api.sh search-org "<company>"
bash ${CLAUDE_PLUGIN_ROOT}/scripts/github-api.sh languages <org>
bash ${CLAUDE_PLUGIN_ROOT}/scripts/github-api.sh repos <org> --limit 5 --sort stars
```

Supplement with Apollo technologies field and web research for non-tech companies.

### Step 11: Competitive Landscape

Search for competitors and market position:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh search "<company> competitors alternatives vs" --num 5
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh search "<company> market share industry ranking" --num 5
```

### Step 12: ICP Scoring

If ICP is configured in `~/.claude/sales-recon.local.md`, calculate ICP Score per icp-framework.md:
- company_fit (industry, size, revenue, geography)
- contact_fit (title, seniority, department) for the top decision maker

### Step 13: Priority & Timing Assessment

Calculate Priority Score: `(ICP * 0.4) + (Intent * 0.6)`
If no ICP configured, use Intent Score as Priority.

Assess timing: optimal outreach window based on signal freshness.

### Step 14: Output Report

```markdown
# Deep Research: [Company Name]

**Domain**: [domain] | **Date**: [YYYY-MM-DD] | **Confidence**: [High/Medium/Low]

---

## Company Overview

| Field | Value |
|-------|-------|
| Legal Name | [name] |
| Industry | [industry] |
| Founded | [year] |
| Employees | [count] |
| Revenue | [estimate or actual] |
| Funding Stage | [stage] |
| Total Funding | [amount] |
| Website | [url] |
| LinkedIn | [url] |
| Business Status | [Operational/Closed] |

## Headquarters

| Field | Value |
|-------|-------|
| Address | [full address] |
| Phone | [number] |
| Google Rating | [X]/5 ([N] reviews) |
| Hours | [summary] |

## Leadership Team

| # | Name | Title | Email | Confidence | Phone | LinkedIn | DM Score |
|---|------|-------|-------|------------|-------|----------|----------|
| 1 | [name] | [title] | [email] | [X]% | [phone] | [url] | [X]/10 |
| 2 | [name] | [title] | [email] | [X]% | [phone] | [url] | [X]/10 |
| ... | ... | ... | ... | ... | ... | ... | ... |

## Department Breakdown

| Department | Contacts Found | Key Person |
|------------|---------------|------------|
| Executive | [N] | [name, title] |
| Engineering | [N] | [name, title] |
| Sales | [N] | [name, title] |
| Marketing | [N] | [name, title] |
| Finance | [N] | [name, title] |
| Operations | [N] | [name, title] |

## Decision Makers (Buying Committee)

- **Primary Budget Holder**: [Name], [Title] — [email] (DM: [X]/10)
- **Technical Evaluator**: [Name], [Title] — [email] (DM: [X]/10)
- **Executive Sponsor**: [Name], [Title] — [email] (DM: [X]/10)

## Financials

| Metric | Value | Period |
|--------|-------|--------|
| Revenue | [amount] | [year] |
| Net Income | [amount] | [year] |
| Revenue Growth | [%] YoY | [year vs year] |
| Total Assets | [amount] | [year] |

### Funding History

| Date | Round | Amount | Investors |
|------|-------|--------|-----------|
| [date] | [Series X] | [amount] | [names] |

**Total Raised**: [amount]
**Estimated Valuation**: [amount or "Private — not disclosed"]

## Buying Signals

**Intent Score**: [X]/100 — [HOT/WARM/NURTURE/NOT READY]

| Signal | Score | Weight | Weighted | Key Finding |
|--------|-------|--------|----------|-------------|
| Hiring | [X] | 30% | [X] | [summary] |
| Funding | [X] | 25% | [X] | [summary] |
| Leadership | [X] | 20% | [X] | [summary] |
| Tech Changes | [X] | 15% | [X] | [summary] |
| Competitor Issues | [X] | 10% | [X] | [summary] |

### Signal Timeline

1. **[Date]** [Signal type]: [Description] (Source: [URL])
2. **[Date]** [Signal type]: [Description] (Source: [URL])
3. **[Date]** [Signal type]: [Description] (Source: [URL])

## Tech Stack

| Category | Technologies |
|----------|-------------|
| Languages | [list] |
| Frameworks | [list] |
| Infrastructure | [list] |
| Data/Analytics | [list] |
| Other | [list] |

**GitHub Presence**: [N] public repos | [N] contributors | Primary language: [lang]

## Competitors

| Competitor | Key Differentiator | Market Position |
|-----------|-------------------|----------------|
| [name] | [differentiator] | [position] |
| [name] | [differentiator] | [position] |

## ICP Fit

**ICP Score**: [X]/100 — [Strong/Good/Moderate/Poor]

| Factor | Company | ICP Target | Score |
|--------|---------|-----------|-------|
| Industry | [actual] | [target] | [X] |
| Size | [actual] | [target range] | [X] |
| Revenue | [actual] | [target range] | [X] |
| Geography | [actual] | [target] | [X] |
| Title (top DM) | [actual] | [target] | [X] |
| Seniority | [actual] | [target] | [X] |

## Growth Indicators

- [Indicator 1: e.g., "Hiring 15 engineers — rapid team expansion"]
- [Indicator 2: e.g., "Revenue grew 35% YoY — strong growth trajectory"]
- [Indicator 3: e.g., "Opened new office in Austin — geographic expansion"]

## Priority & Timing

- **Priority Score**: [X]/100 — [HOT/WARM/NURTURE/COLD]
- **Optimal Outreach Window**: [assessment based on signal freshness]
- **Recommended Approach**: [specific strategy]
- **Key Hook**: [strongest signal or connection point for outreach]

## Data Sources

| Source | Calls | Data Retrieved |
|--------|-------|---------------|
| Apollo | [N] | Company profile, org chart |
| Google Places | [N] | Address, phone, rating |
| Hunter | [N] | Email discovery, verification |
| SerpAPI | [N] | News, jobs, signals |
| GitHub | [N] | Tech stack, repos |
| SEC EDGAR | [N] | Financials, filings |

## Confidence Assessment

- **Company data**: [High/Medium/Low] — [reason]
- **Contact data**: [High/Medium/Low] — [reason]
- **Financial data**: [High/Medium/Low] — [reason]
- **Signal data**: [High/Medium/Low] — [reason]

---

**Next steps**: `/craft-outreach "[Top DM Name]"` | `/check-signals "[Company]"` | `/export-leads`
```
