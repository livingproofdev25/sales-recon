---
name: export-leads
description: Export current session leads to JSON or CSV file
argument-hint: [json|csv] [--type b2b|residential|all] [--file filename]
allowed-tools: Read, Write
---

Export gathered leads to file: $ARGUMENTS

## Process

### Step 1: Parse Arguments

Extract from "$ARGUMENTS":
- **Format**: `json` or `csv` (default: `csv`)
- **--type**: Filter by lead type — `b2b`, `residential`, or `all` (default: `all`)
- **--file**: Custom output filename (optional — generates default if not specified)

Default filenames:
- CSV: `leads-export-[YYYY-MM-DD].csv`
- JSON: `leads-export-[YYYY-MM-DD].json`

### Step 2: Gather Session Data

Check the current conversation context for leads gathered from:
- `/prospect` results (B2B leads with company + contact data)
- `/deep-research` results (single company deep dives)
- `/find-contacts` results (contact lists)
- `/homeowner-leads` results (residential leads with property data)
- `/enrich-batch` results (bulk enriched leads)
- `/property-lookup` results (individual property lookups)
- Any other research gathered via natural conversation

If no lead data is found in the session:
- Inform user: "No lead data found in the current session."
- Suggest: "Run `/prospect`, `/homeowner-leads`, or `/enrich-batch` first, then export."
- Stop processing.

Apply `--type` filter if specified (b2b, residential, or all).

### Step 3: Format and Write — CSV

For CSV export, flatten all lead data into a tabular format.

**B2B CSV columns**:
```csv
type,company,domain,industry,employees,revenue,location,website,phone,rating,contact_name,contact_title,contact_email,email_confidence,contact_phone,linkedin,dm_score,icp_score,intent_score,priority,top_signal,last_updated
b2b,Acme Corp,acme.com,Software,250,$50M,San Francisco CA,https://acme.com,+1-555-0000,4.2,John Smith,VP Engineering,john@acme.com,95,+1-555-1234,linkedin.com/in/jsmith,8,85,72,WARM,Series B funding,2026-02-15
```

**Residential CSV columns**:
```csv
type,address,city,state,zip,owner_name,owner_type,property_type,beds,baths,sqft,year_built,estimated_value,tax_assessed,owner_occupied,permit_date,permit_description,project_value,lead_score,lead_tier,last_updated
residential,1234 Oak Hill Dr,Austin,TX,78749,John Smith,Individual,Single Family,4,3,2450,2005,525000,485000,Yes,2026-01-15,Reroof entire residence,18500,82,Priority,2026-02-15
```

**Mixed CSV** (when `--type all` and both types present): include a `type` column to distinguish.

### Step 4: Format and Write — JSON

For JSON export, create a structured document:

```json
{
  "export_metadata": {
    "timestamp": "[ISO 8601 timestamp]",
    "source": "sales-recon",
    "version": "3.0.0",
    "type_filter": "[b2b|residential|all]",
    "total_leads": [N]
  },
  "b2b_leads": [
    {
      "company": {
        "name": "Acme Corp",
        "domain": "acme.com",
        "industry": "Software",
        "employees": 250,
        "revenue_estimate": "$50M",
        "location": "San Francisco, CA",
        "website": "https://acme.com",
        "phone": "+1-555-0000",
        "rating": 4.2
      },
      "primary_contact": {
        "name": "John Smith",
        "title": "VP Engineering",
        "email": "john@acme.com",
        "email_confidence": 95,
        "phone": "+1-555-1234",
        "linkedin": "linkedin.com/in/jsmith",
        "dm_score": 8
      },
      "scores": {
        "icp_score": 85,
        "intent_score": 72,
        "priority": "WARM"
      },
      "top_signal": "Series B funding",
      "last_updated": "2026-02-15"
    }
  ],
  "residential_leads": [
    {
      "property": {
        "address": "1234 Oak Hill Dr",
        "city": "Austin",
        "state": "TX",
        "zip": "78749",
        "type": "Single Family",
        "beds": 4,
        "baths": 3,
        "sqft": 2450,
        "year_built": 2005,
        "estimated_value": 525000,
        "tax_assessed": 485000
      },
      "owner": {
        "name": "John Smith",
        "type": "Individual",
        "owner_occupied": true
      },
      "permit": {
        "date": "2026-01-15",
        "description": "Reroof entire residence",
        "value": 18500
      },
      "scores": {
        "lead_score": 82,
        "tier": "Priority"
      },
      "last_updated": "2026-02-15"
    }
  ]
}
```

### Step 5: Data Quality Check

Before writing, validate:
- All email addresses have confidence scores (B2B)
- No unexpected PII in fields
- Data is properly escaped for the chosen format
- Timestamps are ISO 8601

### Step 6: Write File and Confirm

Write the file to the specified or default path.

```markdown
## Export Complete

| Field | Value |
|-------|-------|
| Format | [CSV/JSON] |
| File | [output path] |
| Type filter | [B2B/Residential/All] |
| B2B leads | [N] |
| Residential leads | [N] |
| Total leads | [N] |
| File size | [X] KB |

### Export Contents
- High-value B2B leads (Priority HOT/WARM): [N]
- High-value residential leads (Priority/Good): [N]
- Leads with verified email: [N]
- Leads with phone number: [N]

### Import Tips
- **CRM Import**: Most CRMs accept CSV format with field mapping
- **Salesforce**: Use Data Import Wizard, map `company` to Account
- **HubSpot**: Use Import tool, map `contact_email` to Contact
- **Pipedrive**: CSV import with automatic field detection
- **Google Sheets**: Direct CSV open, use Data > Split text to columns if needed
- **API Integration**: JSON format recommended for programmatic use

File ready at: `[full path]`
```
