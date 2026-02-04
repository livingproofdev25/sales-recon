---
name: recon-export
description: Export intelligence results to JSON or CSV format
argument-hint: [json|csv] [output-file]
allowed-tools: Read, Write, Bash
---

Export gathered intelligence to specified format: $ARGUMENTS

## Export Process

### Step 1: Parse Arguments

Extract from "$ARGUMENTS":
- **Format**: `$1` - Either "json" or "csv" (default: json)
- **Output file**: `$2` - Custom filename (optional, will generate default)

Default filenames:
- JSON: `intel-export-[timestamp].json`
- CSV: `intel-export-[timestamp].csv`

### Step 2: Gather Available Data

Check conversation context for:
- Recent `/recon-person` results
- Recent `/recon-company` results
- Recent `/recon-batch` results
- Any intelligence gathered via natural language queries

If no recent intelligence data found:
- Inform user: "No recent intelligence data to export."
- Suggest: "Run /recon-person or /recon-company first, then export."

### Step 3: Format Data

**JSON Export Format**:

```json
{
  "export_metadata": {
    "timestamp": "2026-02-04T12:00:00Z",
    "source": "sales-recon",
    "version": "1.0.0"
  },
  "persons": [
    {
      "name": "John Smith",
      "email": "john@acme.com",
      "email_confidence": 95,
      "phone": "+1-555-1234",
      "linkedin_url": "linkedin.com/in/jsmith",
      "twitter": "@jsmith",
      "current_title": "VP Engineering",
      "current_company": "Acme Corp",
      "location": "San Francisco, CA",
      "work_history": [
        {"title": "VP Engineering", "company": "Acme Corp", "start": "2022", "end": "present"},
        {"title": "Director", "company": "Previous Co", "start": "2019", "end": "2022"}
      ],
      "education": [
        {"degree": "MS Computer Science", "institution": "Stanford"}
      ],
      "decision_maker_score": 8,
      "data_sources": ["hunter.io", "linkedin", "twitter"],
      "last_updated": "2026-02-04"
    }
  ],
  "companies": [
    {
      "name": "Acme Corp",
      "website": "acme.com",
      "industry": "Software",
      "sic_code": "7372",
      "employee_count": "250-500",
      "revenue_estimate": "$50M-$100M",
      "founded": 2015,
      "headquarters": {
        "address": "123 Main St, San Francisco, CA 94102",
        "phone": "+1-555-0000"
      },
      "leadership": [
        {"name": "Jane CEO", "title": "CEO", "email": "jane@acme.com", "dm_score": 10},
        {"name": "John CTO", "title": "CTO", "email": "john@acme.com", "dm_score": 9}
      ],
      "decision_makers": [
        {"name": "Sarah VP", "title": "VP Sales", "email": "sarah@acme.com", "role": "budget_holder"}
      ],
      "employee_count_by_dept": {
        "engineering": 120,
        "sales": 45,
        "marketing": 25
      },
      "competitors": ["Competitor A", "Competitor B"],
      "recent_news": [
        {"date": "2026-01", "headline": "Series C Funding", "source": "TechCrunch"}
      ],
      "data_sources": ["google_maps", "hunter.io", "linkedin", "crunchbase"],
      "last_updated": "2026-02-04"
    }
  ]
}
```

**CSV Export Format** (flattened for spreadsheet use):

```csv
type,name,email,email_confidence,phone,linkedin,twitter,title,company,location,dm_score,industry,employee_count,website,last_updated
person,John Smith,john@acme.com,95,+1-555-1234,linkedin.com/in/jsmith,@jsmith,VP Engineering,Acme Corp,San Francisco,8,,,,2026-02-04
company,Acme Corp,jane@acme.com (CEO),95,+1-555-0000,,,,,San Francisco,,Software,250-500,acme.com,2026-02-04
```

### Step 4: Data Quality Check

Before export, validate:
- All email addresses have confidence scores
- No PII in unexpected fields
- Data is properly escaped for format
- Timestamps are ISO 8601 format

### Step 5: Write Export File

Write to specified or default output path.

Report:
```markdown
## Export Complete

- **Format**: [JSON/CSV]
- **File**: [output-path]
- **Records**: [N] persons, [M] companies
- **File size**: [X] KB

### Export Contents
- Person records: [N]
- Company records: [M]
- High-value leads (DM ≥7): [X]

### Import Tips
- **CRM Import**: Most CRMs accept CSV format
- **Salesforce**: Use Data Import Wizard
- **HubSpot**: Use Import tool with field mapping
- **API Integration**: JSON format recommended

File ready at: [full-path]
```

### Step 6: Offer Next Actions

After export, ask if user wants to:
1. Filter results (by DM score, company, location)
2. Generate a different format
3. Create targeted list (e.g., "only VPs in California")
4. Continue gathering more intelligence
