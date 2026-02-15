---
name: find-permits
description: Pull building permits from city open data — filter by city, project type, date range
argument-hint: "City" [--type roofing] [--days 90] [--limit 25]
allowed-tools: Read, Bash
---

Pull building permits for: $ARGUMENTS

Use the Residential Intelligence skill and permit-cities.md reference for methodology.

## Process

### Step 1: Parse Input

Extract from "$ARGUMENTS":
- **City**: Target city (required) — e.g., "Austin", "San Antonio", "NYC", "Boston", "Detroit", "DC"
- **--type**: Project type filter (optional) — e.g., "roofing", "remodel", "addition", "plumbing", "electrical", "hvac", "solar"
- **--days N**: Lookback period in days (default: 90, max: 365)
- **--limit N**: Max permits to return (default: 25, max: 50)

### Step 2: Verify City Support

Check that the specified city is supported:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/socrata-permits-api.sh cities
```

Supported cities: Austin, San Antonio, NYC, Boston, Detroit, DC.

If the city is not supported, inform the user and list the supported cities.

### Step 3: Pull Permits

Run the permit search with all parsed parameters:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/socrata-permits-api.sh search <city> --type <type> --days <days> --limit <limit>
```

If `--type` was specified, include it. Otherwise, pull all permit types.

### Step 4: Normalize Field Names

Per permit-cities.md, field names vary by city. Normalize the raw response to the standard schema:
- **address**: Map from `original_address1`, `address`, `site_address`, `full_address`, `house__` + `street_name`
- **date**: Map from `issued_date`, `issuance_date`, `permit_issued`, `issue_date`
- **description**: Map from `work_description`, `project_description`, `job_description`, `description_of_work`, `bld_type_use`
- **value**: Map from `original_value`, `estimated_cost`, `fees_paid`
- **status**: Map from `status_current`, `permit_type`, `job_type`, `permit_type_name`

### Step 5: Output Report

```markdown
# Building Permits: [City, State]

**Search**: [type filter or "All types"] | **Period**: Last [N] days | **Date**: [YYYY-MM-DD]
**Found**: [N] permits

---

## Permits

| # | Date | Address | Description | Value | Status |
|---|------|---------|-------------|-------|--------|
| 1 | [YYYY-MM-DD] | [address] | [description] | $[amount] | [status] |
| 2 | [YYYY-MM-DD] | [address] | [description] | $[amount] | [status] |
| 3 | [YYYY-MM-DD] | [address] | [description] | $[amount] | [status] |
| ... | ... | ... | ... | ... | ... |

## Summary

- **Total permits**: [N]
- **Date range**: [earliest] to [latest]
- **Average value**: $[amount]
- **Highest value**: $[amount] at [address]
- **Most common type**: [type] ([N] permits)

---

**Next steps**:
- `/property-lookup "[address]"` — Get owner info and property value for any permit address
- `/homeowner-leads "[City]" --type [type]` — Full pipeline: permits + property enrichment + scored leads
- `/enrich-batch permits-export.csv --type residential` — Bulk enrich all permits
```
