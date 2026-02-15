---
name: homeowner-leads
description: Full residential pipeline — permits to property enrichment to owner contacts to scored leads
argument-hint: "City" --type <project> [--days 60] [--limit 15]
allowed-tools: Read, Write, Bash
---

Run the full residential lead generation pipeline for: $ARGUMENTS

Use the Residential Intelligence skill and property-enrichment.md reference for methodology.

## Process

### Step 1: Parse Input

Extract from "$ARGUMENTS":
- **City**: Target city (required)
- **--type**: Project type filter (required) — e.g., "roofing", "remodel", "addition", "plumbing", "electrical", "hvac", "solar", "foundation"
- **--days N**: Lookback period in days (default: 60, max: 365)
- **--limit N**: Max leads to return (default: 15, max: 50)

If `--type` is not provided, ask the user what project type they are targeting. This is required for the residential pipeline.

### Step 2: Pull Permits

Search for building permits matching the criteria:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/socrata-permits-api.sh search <city> --type <type> --days <days> --limit <limit>
```

If fewer results than expected, try broadening the type or extending the date range.

Normalize field names per permit-cities.md.

### Step 3: Enrich Each Permit with Property Data

For each permit address, pull property details and valuation from RentCast:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/rentcast-api.sh property "<permit address>"
bash ${CLAUDE_PLUGIN_ROOT}/scripts/rentcast-api.sh value "<permit address>"
```

Extract: owner name, owner type, property type, bedrooms, bathrooms, sqft, year built, estimated value, tax assessed value, owner-occupied status.

Note: RentCast has rate limits. Track API call count and warn if approaching limits.

### Step 4: Score Each Lead

Score each lead per property-enrichment.md scoring methodology:

**Property Value (30% weight)**:
- >$500K: 100
- $300-500K: 75
- $150-300K: 50
- <$150K: 25

**Permit Recency (25% weight)**:
- <30 days: 100
- 30-60 days: 80
- 60-90 days: 60
- >90 days: 40

**Project Value (25% weight)**:
- >$20K: 100
- $10-20K: 75
- $5-10K: 50
- <$5K: 25

**Owner-Occupied (20% weight)**:
- Owner-occupied: 100
- Investor/rental: 50
- Unknown: 60

```
Lead Score = (property_value * 0.30) + (recency * 0.25) + (project_value * 0.25) + (owner_occupied * 0.20)
```

Classify:
- 80+: Priority — immediate outreach
- 60-79: Good — include in campaign
- 40-59: Fair — follow up if capacity allows
- <40: Low — skip unless batch is thin

### Step 5: Rank and Output

Sort leads by Lead Score descending. Store results in session memory for `/export-leads`.

```markdown
# Homeowner Leads: [Type] in [City]

**Project type**: [type] | **Period**: Last [N] days | **Date**: [YYYY-MM-DD]
**Permits found**: [N] | **Enriched**: [N] | **API calls**: RentCast [N]

---

## Ranked Leads

### 1. [Owner Name] — [Lead Score]/100 ([Priority/Good/Fair/Low])

**Permit Info**:

| Field | Value |
|-------|-------|
| Permit Date | [YYYY-MM-DD] |
| Address | [full address] |
| Description | [work description] |
| Project Value | $[amount] |
| Status | [Issued/Active/Final] |

**Property Details**:

| Field | Value |
|-------|-------|
| Owner | [name] |
| Property Type | [type] |
| Beds/Baths | [N]bd / [N]ba |
| SqFt | [N] |
| Year Built | [year] |
| Estimated Value | $[amount] |
| Owner-Occupied | [Yes/No] |

**Score Breakdown**:

| Factor | Weight | Raw | Weighted |
|--------|--------|-----|----------|
| Property Value | 30% | [X] | [X] |
| Permit Recency | 25% | [X] | [X] |
| Project Value | 25% | [X] | [X] |
| Owner-Occupied | 20% | [X] | [X] |
| **Total** | | | **[X]** |

---

### 2. [Owner Name] — [Lead Score]/100 ([Level])
[...repeat for each lead...]

---

## Summary by Tier

| Tier | Count | Leads |
|------|-------|-------|
| Priority (80+) | [N] | [addresses] |
| Good (60-79) | [N] | [addresses] |
| Fair (40-59) | [N] | [addresses] |
| Low (<40) | [N] | [addresses] |

## Pipeline Stats

- **Average lead score**: [X]
- **Average property value**: $[amount]
- **Average project value**: $[amount]
- **Owner-occupied rate**: [X]%
- **Highest-value property**: $[amount] at [address]

## API Usage

- Socrata (free): [N] permit records
- RentCast: [N] property lookups + [N] valuations = [N] total calls

---

**Next steps**:
- `/craft-outreach "[Owner Name]" --style doorknock` — Generate door knock script for top leads
- `/craft-outreach "[Owner Name]" --style cold` — Generate cold outreach for mail campaign
- `/property-lookup "[Address]"` — Deep dive on any property (sale history, comps, market)
- `/export-leads csv --type residential` — Export all leads to CSV
```
