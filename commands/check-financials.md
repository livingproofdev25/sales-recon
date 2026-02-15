---
name: check-financials
description: Financial intelligence — revenue, earnings, funding rounds, SEC filings, valuation estimate
argument-hint: "Company Name"
allowed-tools: Read, Bash, WebSearch, WebFetch
---

Pull financial intelligence on: $ARGUMENTS

Use the Lead Intelligence skill for methodology.

## Process

### Step 1: Parse Input

Extract from "$ARGUMENTS":
- **Company name**: The target company (required)

### Step 2: Resolve Company

Get basic company data from Apollo:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/apollo-api.sh company-enrich --domain <best-guess-domain>
```

Extract: estimated revenue, employee count, funding stage, total funding, founded year.

If the domain is unknown, search via Google Places first:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/google-places-api.sh find "<company name>"
```

### Step 3: SEC EDGAR (Public Companies)

Search for the company in SEC EDGAR:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/sec-edgar-api.sh search "<company name>"
```

If a CIK is found (public company), pull financial facts:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/sec-edgar-api.sh company-facts <CIK>
bash ${CLAUDE_PLUGIN_ROOT}/scripts/sec-edgar-api.sh company-concept <CIK> Revenues
bash ${CLAUDE_PLUGIN_ROOT}/scripts/sec-edgar-api.sh company-concept <CIK> NetIncomeLoss
bash ${CLAUDE_PLUGIN_ROOT}/scripts/sec-edgar-api.sh company-concept <CIK> Assets
bash ${CLAUDE_PLUGIN_ROOT}/scripts/sec-edgar-api.sh company-concept <CIK> StockholdersEquity
bash ${CLAUDE_PLUGIN_ROOT}/scripts/sec-edgar-api.sh company-concept <CIK> ResearchAndDevelopmentExpense
```

Extract the last 3-5 years of annual data (10-K filings only).

### Step 4: Funding History (Private Companies)

Search for funding rounds and investment news:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh news "<company> funding round raises series" --num 10
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh search "<company> crunchbase funding valuation" --num 5
```

Extract: funding dates, round types, amounts, lead investors, stated valuation.

### Step 5: Growth Indicators

Search for headcount and growth signals:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh jobs "<company>"
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh search "<company> revenue growth expansion" --time y
```

Estimate growth trajectory based on:
- Job posting volume (high = growing)
- Revenue trend (from SEC or news)
- Employee count change (Apollo vs LinkedIn signals)
- Office expansion or new market entry

### Step 6: Revenue Potential Assessment

Based on gathered financial data, assess the lead's revenue potential for your product:
- **Deal size estimate**: Based on company revenue and employee count
- **Budget availability**: Based on funding stage, revenue, profitability
- **Timing**: Based on funding recency, fiscal year timing, growth phase

### Step 7: Output Report

```markdown
# Financial Intelligence: [Company Name]

**Type**: [Public (Ticker: XXX) / Private] | **Date**: [YYYY-MM-DD]

---

## Company Overview

| Field | Value |
|-------|-------|
| Founded | [year] |
| Employees | [count] |
| Industry | [industry] |
| Headquarters | [city, state] |
| Website | [url] |

## Revenue & Earnings

| Year | Revenue | Net Income | Growth |
|------|---------|------------|--------|
| [FY1] | [amount] | [amount] | — |
| [FY2] | [amount] | [amount] | [X]% |
| [FY3] | [amount] | [amount] | [X]% |

**3-Year Revenue CAGR**: [X]%
**Profit Margin**: [X]%

## Balance Sheet Highlights

| Metric | Value | Period |
|--------|-------|--------|
| Total Assets | [amount] | [year] |
| Stockholders' Equity | [amount] | [year] |
| R&D Spend | [amount] | [year] |
| R&D as % of Revenue | [X]% | [year] |

## Funding History

| Date | Round | Amount | Lead Investor(s) | Valuation |
|------|-------|--------|-------------------|-----------|
| [date] | [Seed/A/B/C/...] | [amount] | [investors] | [amount] |
| [date] | [round] | [amount] | [investors] | [amount] |

**Total Raised**: [amount]
**Last Known Valuation**: [amount or "Not disclosed"]
**Funding Stage**: [stage from Apollo]

## Growth Indicators

| Indicator | Signal | Assessment |
|-----------|--------|------------|
| Hiring velocity | [N] open roles | [Growing/Stable/Contracting] |
| Revenue trend | [X]% CAGR | [Accelerating/Steady/Decelerating] |
| Market expansion | [evidence] | [Expanding/Stable] |
| Product investment | [R&D spend trend] | [Increasing/Flat/Declining] |

## Revenue Potential Assessment

| Factor | Assessment |
|--------|------------|
| **Deal Size Estimate** | [Small (<$10K) / Mid ($10-50K) / Enterprise ($50K+)] |
| **Budget Availability** | [High / Medium / Low] — [reason] |
| **Budget Timing** | [Now / Next quarter / Next fiscal year] — [reason] |
| **Financial Health** | [Strong / Moderate / Weak] — [reason] |
| **Growth Phase** | [Startup / Growth / Mature / Declining] |

## Data Sources

| Source | Data Retrieved |
|--------|---------------|
| SEC EDGAR | [Filings found / Not public] |
| Apollo | [Revenue estimate, funding data] |
| SerpAPI | [N] news articles, [N] search results |

## Confidence

- **Revenue data**: [High (SEC filing) / Medium (Apollo estimate) / Low (news-based)]
- **Funding data**: [High (Crunchbase/SEC) / Medium (news) / Low (estimate)]
- **Growth assessment**: [High / Medium / Low]

---

**Next steps**: `/deep-research "[Company]"` | `/check-signals "[Company]"` | `/find-contacts "[Company]"`
```
