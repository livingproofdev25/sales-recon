---
name: score-icp
description: Score a company against your saved ICP definition with detailed fit breakdown
argument-hint: "Company Name"
allowed-tools: Read, Bash, WebSearch, WebFetch
---

Score a company against your Ideal Customer Profile: $ARGUMENTS

Use the Lead Intelligence skill and icp-framework.md reference for methodology.

## Process

### Step 1: Load ICP Configuration

Read the ICP configuration from `~/.claude/sales-recon.local.md`.

Look for the `default_icp` section in the YAML frontmatter:
- `industries` — target industries list
- `min_employees` / `max_employees` — company size range
- `min_revenue` / `max_revenue` — revenue range (if set)
- `geo` — target geography list
- `target_titles` — priority-ordered title list
- `target_departments` — target department list

If no ICP is configured or the file does not exist:
- Tell the user: "No ICP configured. Run `/set-icp` first to define your Ideal Customer Profile."
- Stop processing.

### Step 2: Get Company Data

Enrich the company via Apollo:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/apollo-api.sh company-enrich --domain <best-guess-domain>
```

If the domain is unknown, resolve via Google Places:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/google-places-api.sh find "<company name>"
```

Extract: industry, employee count, estimated revenue, city, state, technologies.

### Step 3: Get Top Decision Maker

Pull the org chart to find the most relevant contact:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/apollo-api.sh org-chart --domain <domain> --limit 5
```

Identify the contact whose title best matches the ICP target titles.

### Step 4: Calculate Company Fit (0-100)

Per icp-framework.md:

**Industry Match (40% of company fit)**:
- Primary industry match: 100
- Secondary/adjacent industry: 75
- Related but different: 40
- No match: 0

**Company Size (30% of company fit)**:
- Within defined range: 100
- Within 2x of range: 60
- Outside range: 20

**Revenue Match (20% of company fit)**:
- Within defined range: 100
- Within 2x: 60
- Outside or unknown: 30

**Geography (10% of company fit)**:
- Target geography: 100
- Adjacent market: 60
- Outside target: 20

```
company_fit = (industry * 0.40) + (size * 0.30) + (revenue * 0.20) + (geography * 0.10)
```

### Step 5: Calculate Contact Fit (0-100)

Per icp-framework.md:

**Title Match (50% of contact fit)**:
- Exact priority 1 title: 100
- Exact priority 2-3 title: 85
- Partial match: 60
- Related but different: 40

**Seniority Match (30% of contact fit)**:
- Exact level: 100
- One level off: 70
- Two+ levels: 20

**Department Match (20% of contact fit)**:
- Target department: 100
- Related department: 60
- Unrelated: 20

```
contact_fit = (title * 0.50) + (seniority * 0.30) + (department * 0.20)
```

### Step 6: Calculate Total ICP Score

```
ICP Score = (company_fit * 0.6) + (contact_fit * 0.4)
```

Classify:
- 80-100: Strong
- 60-79: Good
- 40-59: Moderate
- 0-39: Poor

### Step 7: Output Report

```markdown
# ICP Score: [Company Name]

**ICP Score**: [X]/100 — [Strong/Good/Moderate/Poor]
**Date**: [YYYY-MM-DD]

---

## Company Fit: [X]/100

| Factor | Weight | Company Value | ICP Target | Score |
|--------|--------|---------------|-----------|-------|
| Industry | 40% | [actual industry] | [target industries] | [X]/100 |
| Company Size | 30% | [actual employees] | [min-max range] | [X]/100 |
| Revenue | 20% | [actual or estimate] | [min-max range] | [X]/100 |
| Geography | 10% | [city, state] | [target geos] | [X]/100 |

**Company Fit Weighted Score**: [X]/100

## Contact Fit: [X]/100

**Best-match contact**: [Name], [Title]

| Factor | Weight | Contact Value | ICP Target | Score |
|--------|--------|---------------|-----------|-------|
| Title | 50% | [actual title] | [target titles] | [X]/100 |
| Seniority | 30% | [actual level] | [target level] | [X]/100 |
| Department | 20% | [actual dept] | [target depts] | [X]/100 |

**Contact Fit Weighted Score**: [X]/100

## Total Score Calculation

```
ICP Score = (Company Fit [X] * 0.6) + (Contact Fit [X] * 0.4) = [X]/100
```

## Comparison Summary

| Attribute | Company | Your ICP | Match |
|-----------|---------|----------|-------|
| Industry | [actual] | [target] | [Match/Partial/Miss] |
| Employees | [actual] | [range] | [Match/Partial/Miss] |
| Revenue | [actual] | [range] | [Match/Partial/Miss] |
| Location | [actual] | [target] | [Match/Partial/Miss] |
| Top Title | [actual] | [target] | [Match/Partial/Miss] |
| Seniority | [actual] | [target] | [Match/Partial/Miss] |
| Department | [actual] | [target] | [Match/Partial/Miss] |

## Recommendation

- **Strong (80+)**: Prioritize this company for immediate outreach. Excellent ICP match.
- **Good (60-79)**: Include in active campaigns. Good fit with minor gaps.
- **Moderate (40-59)**: Consider only if buying signals are strong. Worth monitoring.
- **Poor (<40)**: Deprioritize. Significant mismatch with your ICP.

**Specific recommendation**: [tailored advice based on the score breakdown — e.g., "Strong company fit but contact fit is weak — search for a better-matched decision maker with /find-contacts"]

---

**Next steps**: `/check-signals "[Company]"` | `/find-contacts "[Company]"` | `/deep-research "[Company]"`
```
