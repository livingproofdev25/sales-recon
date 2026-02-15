---
name: enrich-batch
description: Bulk enrich a CSV of companies or addresses — auto-detects B2B vs residential by column headers
argument-hint: <file.csv> [--type b2b|residential] [--limit 50]
allowed-tools: Read, Write, Bash, WebSearch, WebFetch
---

Bulk enrich leads from CSV file: $ARGUMENTS

Use the Lead Intelligence skill for B2B methodology and the Residential Intelligence skill for residential methodology.

## Process

### Step 1: Parse Input

Extract from "$ARGUMENTS":
- **File path**: Path to the CSV file (required)
- **--type**: Force type detection — `b2b` or `residential` (optional — auto-detected if not specified)
- **--limit N**: Max records to process (default: 50, max: 100)

Read the CSV file. If the file does not exist or is not valid CSV, inform the user and provide expected format examples.

### Step 2: Auto-Detect Type

Detect the lead type by inspecting column headers:

**B2B indicators** (any of these columns present):
- `company`, `company_name`, `organization`, `domain`, `website`
- Plus optional: `name`, `first_name`, `last_name`, `title`, `email`, `location`

**Residential indicators** (any of these columns present):
- `address`, `street_address`, `property_address`, `full_address`
- Plus optional: `city`, `state`, `zip`, `owner`, `permit_date`, `permit_type`

If both types of columns exist and `--type` was not specified, ask the user to clarify.

Show the detected type and column mapping to the user before proceeding.

### Step 3: API Limit Check

Calculate estimated API calls for the batch:

**B2B batch** (per record):
- Apollo company-enrich: 1 call
- Apollo org-chart (top 3): 1 call
- Hunter email verify (top contact): 1 call
- SerpAPI news (quick signal check): 1 call
- Total per record: ~4 calls

**Residential batch** (per record):
- RentCast property: 1 call
- RentCast value: 1 call
- Total per record: ~2 calls

Warn if total estimated calls exceed monthly API limits:
- Apollo: 900 credits/mo (free)
- Hunter: 25 searches/mo (free), 50 verifications/mo (free)
- SerpAPI: 100 searches/mo (free)
- RentCast: 50 calls/mo (free)

If the batch would exceed limits, suggest reducing `--limit` or skipping certain enrichment steps.

### Step 4: Process B2B Batch

For each row in the CSV:

**4a. Company Enrich**:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/apollo-api.sh company-enrich --domain <domain>
```

**4b. Top Decision Maker**:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/apollo-api.sh org-chart --domain <domain> --limit 3
```

**4c. Email Verification** (top contact only):
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/hunter-api.sh find-email --domain <domain> --first <first> --last <last>
```

**4d. Quick Signal Check**:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh news "<company>" --num 3
```

**4e. Score**: Calculate ICP Score (if configured) and quick Intent Score.

Track progress: "Enriching [X] of [N]: [Company Name]..."

### Step 5: Process Residential Batch

For each row in the CSV:

**5a. Property Details**:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/rentcast-api.sh property "<address>"
```

**5b. Property Value**:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/rentcast-api.sh value "<address>"
```

**5c. Score**: Calculate residential lead score per property-enrichment.md methodology.

Track progress: "Enriching [X] of [N]: [Address]..."

### Step 6: Write Enriched CSV

Write the enriched output to `[original-filename]-enriched.csv`.

**B2B enriched columns**:
```csv
company,domain,industry,employees,revenue,location,website,phone,rating,top_contact,top_email,email_confidence,top_title,dm_score,intent_score,icp_score,priority,top_signal,last_updated
```

**Residential enriched columns**:
```csv
address,city,state,zip,owner_name,owner_type,property_type,beds,baths,sqft,year_built,estimated_value,tax_assessed,owner_occupied,permit_date,permit_type,project_value,lead_score,lead_tier,last_updated
```

### Step 7: Output Summary

```markdown
# Batch Enrichment Summary

## Input
- **File**: [original filename]
- **Type**: [B2B/Residential] ([auto-detected/user-specified])
- **Records**: [N] total | **Processed**: [N] | **Skipped**: [N]

## Results

| Metric | Value |
|--------|-------|
| Successfully enriched | [N] ([X]%) |
| Partial (some fields missing) | [N] ([X]%) |
| Failed (no data found) | [N] ([X]%) |

## Enrichment Quality (B2B)

| Field | Found | Rate |
|-------|-------|------|
| Industry | [N] | [X]% |
| Employee Count | [N] | [X]% |
| Revenue | [N] | [X]% |
| Top Contact Email | [N] | [X]% |
| Phone | [N] | [X]% |
| Intent Score | [N] | [X]% |

## Enrichment Quality (Residential)

| Field | Found | Rate |
|-------|-------|------|
| Owner Name | [N] | [X]% |
| Property Value | [N] | [X]% |
| Property Details | [N] | [X]% |
| Owner-Occupied | [N] | [X]% |

## Top Leads by Score

| # | [Company/Address] | Score | Top Signal/Tier |
|---|-------------------|-------|-----------------|
| 1 | [name] | [X] | [signal/tier] |
| 2 | [name] | [X] | [signal/tier] |
| 3 | [name] | [X] | [signal/tier] |
| 4 | [name] | [X] | [signal/tier] |
| 5 | [name] | [X] | [signal/tier] |

## API Usage

| API | Calls Used | Monthly Limit | Remaining |
|-----|-----------|---------------|-----------|
| Apollo | [N] | 900 | [N] |
| Hunter | [N] | 25/50 | [N] |
| SerpAPI | [N] | 100 | [N] |
| RentCast | [N] | 50 | [N] |
| Google Places | [N] | ~11,700 | [N] |

## Output File
- **Enriched CSV**: [path to enriched file]
- **File size**: [X] KB
- **Columns added**: [N]

---

**Next steps**:
- `/deep-research "[Top Company]"` — Deep dive on top B2B leads
- `/property-lookup "[Top Address]"` — Deep dive on top residential leads
- `/craft-outreach "[Top Contact]"` — Generate outreach for best leads
- `/export-leads json` — Re-export in JSON format
```
