---
name: recon-batch
description: Bulk enrich leads from CSV file (10-50 records)
argument-hint: [csv-file-path]
allowed-tools: Read, Write, Grep, Glob, Bash, WebSearch, WebFetch, Task
---

Process batch lead enrichment from CSV file: $ARGUMENTS

Use the OSINT Tradecraft skill for methodology guidance.

## Batch Processing Workflow

### Step 1: Validate Input File

Read and validate the CSV file at: @$1

Check for required columns (at minimum one of):
- `name` or `first_name` + `last_name` (for person records)
- `company` or `company_name` (for company records)

Optional columns that improve accuracy:
- `email` (existing email to verify)
- `location` or `city`, `state`
- `title` or `job_title`
- `linkedin_url`
- `website` or `domain`

If file is missing or invalid format:
- Explain expected CSV format
- Provide example:
```csv
name,company,location,title
John Smith,Acme Corp,San Francisco,VP Engineering
Jane Doe,Tech Inc,New York,CEO
```

### Step 2: Analyze Batch Type

Determine record type based on columns:
- **Person batch**: Has name columns, enrich with contact/professional info
- **Company batch**: Has company columns without names, enrich with org intel
- **Mixed batch**: Has both, enrich persons with company context

### Step 3: Rate Limit Planning

For batch of [N] records:
- Hunter.io: Max 10 requests/second
- SerpAPI: Max 10 requests/second
- Google Maps: Max 50 requests/second

Processing order:
1. Deduplicate records
2. Group by company domain (batch Hunter.io requests)
3. Process in parallel where possible
4. Track progress

### Step 4: Process Each Record

For each row in the CSV:

**Person Records**:
1. Hunter.io email finder (if company known)
2. LinkedIn search via SerpAPI
3. Calculate decision-maker score
4. Add to results

**Company Records**:
1. Google Maps verification
2. Hunter.io domain search
3. Leadership team research
4. Add to results

Track progress: "Processing [X] of [N]: [Name/Company]..."

### Step 5: Generate Enriched Output

Create enriched CSV with additional columns:

**For Person Batches**:
```csv
name,company,location,title,email,email_confidence,linkedin_url,phone,twitter,dm_score,last_updated
John Smith,Acme Corp,San Francisco,VP Engineering,john@acme.com,95,linkedin.com/in/jsmith,+1-555-1234,@jsmith,8,2026-02-04
```

**For Company Batches**:
```csv
company,location,website,phone,employee_count,industry,ceo_name,ceo_email,decision_makers,last_updated
Acme Corp,San Francisco,acme.com,+1-555-0000,250-500,Software,Jane CEO,jane@acme.com,"VP Sales: sarah@acme.com",2026-02-04
```

### Step 6: Generate Summary Report

```markdown
# Batch Enrichment Summary

## Input
- **File**: $1
- **Records**: [N] total
- **Type**: [Person/Company/Mixed]

## Results
- **Enriched**: [X] records ([%])
- **Partial**: [Y] records (some fields missing)
- **Failed**: [Z] records (could not find data)

## Enrichment Quality
| Field | Found | Rate |
|-------|-------|------|
| Email | [N] | [%] |
| Phone | [N] | [%] |
| LinkedIn | [N] | [%] |
| Title | [N] | [%] |

## High-Value Leads (DM Score ≥7)
1. [Name] at [Company] - Score: [X]
2. [Name] at [Company] - Score: [X]
3. [Name] at [Company] - Score: [X]

## API Usage
- Hunter.io: [N] requests
- SerpAPI: [N] requests
- Google Maps: [N] requests

## Output Files
- Enriched CSV: [path]
- Full reports: [path] (if generated)
```

### Step 7: Save Results

Write enriched CSV to: `[original-filename]-enriched.csv`

Ask user if they want:
1. Full intelligence reports for high-value leads
2. Export to different format (JSON)
3. Filter/sort results
