---
name: prospect
description: Full B2B lead generation pipeline — discover, enrich, score, and rank leads for a target query
argument-hint: "industry/niche in location" [--limit N]
allowed-tools: Read, Write, Bash, WebSearch, WebFetch
---

Run the full B2B lead generation pipeline for: $ARGUMENTS

Use the Lead Intelligence skill for methodology.

## Process

### Step 1: Parse Input

Extract from "$ARGUMENTS":
- **Industry/niche**: The target vertical or business type (e.g., "roofing companies", "SaaS startups", "dental practices")
- **Location**: City, state, or region (e.g., "Austin TX", "San Francisco Bay Area")
- **--limit N**: Max leads to return (default: 10, max: 25)

If the query is ambiguous, ask the user to clarify before proceeding.

### Step 2: Discover Companies

Search for companies matching the query using Google Places text-search:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/google-places-api.sh text-search "<industry> <location>" --radius 50000
```

If fewer than the requested limit are found, supplement with SerpAPI:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh search "<industry> companies in <location>" --num 10
```

Deduplicate by company name and domain. Collect up to `--limit` unique companies.

### Step 3: Enrich Each Company

For each discovered company, run the following enrichment sequence:

**3a. Apollo Company Enrich** — firmographics, revenue, employee count, tech stack:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/apollo-api.sh company-enrich --domain <domain>
```

**3b. Apollo Org Chart** — top 5 decision makers:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/apollo-api.sh org-chart --domain <domain> --limit 5
```

**3c. Hunter Email Verify** — cross-reference and verify top contact emails:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/hunter-api.sh verify <email>
```

**3d. SerpAPI News + Jobs** — buying signals:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh news "<company> funding hiring expansion" --num 3
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh jobs "<company>" --location "<location>"
```

**3e. GitHub Tech Stack** (if tech company):
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/github-api.sh languages <org-name>
```

**3f. SEC EDGAR** (if public company):
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/sec-edgar-api.sh search "<company>"
bash ${CLAUDE_PLUGIN_ROOT}/scripts/sec-edgar-api.sh company-facts <CIK>
```

### Step 4: Score Each Lead

For each enriched company, calculate:

- **ICP Score** (0-100): If ICP is configured in `~/.claude/sales-recon.local.md`, score per icp-framework.md. Otherwise, skip.
- **Intent Score** (0-100): Based on detected signals per signal-weights.md.
- **DM Score** (1-10): Rate the best decision maker contact per skill methodology.
- **Priority Score**: `(ICP * 0.4) + (Intent * 0.6)` — if no ICP, use Intent as Priority.

Classify each lead:
- 80-100: HOT
- 60-79: WARM
- 40-59: NURTURE
- 0-39: COLD

### Step 5: Rank and Output

Sort leads by Priority Score descending. Store results in session memory for `/export-leads`.

Output the following report:

```markdown
# Prospect Report: [Industry/Niche] in [Location]

**Search query**: [original query]
**Found**: [N] companies | **Enriched**: [N] leads | **Date**: [YYYY-MM-DD]
**API usage**: Apollo [N] | Hunter [N] | SerpAPI [N] | Google Places [N] | GitHub [N] | SEC [N]

---

## Ranked Leads

### 1. [Company Name] — [Priority Level]

| Field | Value |
|-------|-------|
| Industry | [industry] |
| Employees | [count] |
| Revenue | [estimate] |
| Location | [city, state] |
| Website | [url] |
| Phone | [number] |
| Rating | [X]/5 ([N] reviews) |
| ICP Score | [X]/100 ([Strong/Good/Moderate/Poor]) |
| Intent Score | [X]/100 |
| Priority | [X]/100 — [HOT/WARM/NURTURE/COLD] |

**Top Decision Maker**: [Name], [Title] — [email] (Confidence: [X]%) | DM Score: [X]/10
**Top Signal**: [strongest buying signal detected]
**Recommended Action**: [specific next step based on priority level]

---

### 2. [Company Name] — [Priority Level]
[...repeat for each lead...]

---

## Summary

| Priority | Count | Companies |
|----------|-------|-----------|
| HOT | [N] | [names] |
| WARM | [N] | [names] |
| NURTURE | [N] | [names] |
| COLD | [N] | [names] |

## Next Steps

- `/deep-research "Company Name"` — Deep dive on any HOT lead
- `/craft-outreach "Contact Name" --style warm` — Generate outreach for top contacts
- `/export-leads csv` — Export all leads to CSV for CRM import
- `/check-signals "Company Name"` — Detailed signal analysis on any lead
```
