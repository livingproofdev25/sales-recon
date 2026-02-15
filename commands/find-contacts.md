---
name: find-contacts
description: Find decision makers at a company with emails, phones, LinkedIn, and seniority scores
argument-hint: "Company Name" [title filter]
allowed-tools: Read, Write, Bash, WebSearch, WebFetch
---

Find decision makers and key contacts at: $ARGUMENTS

Use the Lead Intelligence skill for methodology.

## Process

### Step 1: Parse Input

Extract from "$ARGUMENTS":
- **Company name**: The target company (required)
- **Title filter** (optional): Filter by role, e.g., "VP Engineering", "Marketing", "C-level"

### Step 2: Resolve Domain

Find the company domain. Try Apollo first:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/apollo-api.sh company-enrich --domain <best-guess-domain>
```

If the domain is unknown or Apollo returns no match, use Google Places:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/google-places-api.sh find "<company name>"
```

Extract domain from the website URL.

### Step 3: Pull Org Chart

Get leadership and senior contacts:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/apollo-api.sh org-chart --domain <domain> --limit 25
```

If a title filter was provided, also run a targeted search:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/apollo-api.sh people-search --org "<company>" --title "<title filter>" --limit 10
```

### Step 4: Cross-Reference with Hunter

For the top 5 most relevant contacts, cross-reference emails with Hunter:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/hunter-api.sh find-email --domain <domain> --first <first> --last <last>
```

If Apollo and Hunter emails differ, note both and flag the higher-confidence one.

### Step 5: Domain Search for Additional Contacts

Pull additional contacts not found in the org chart:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/hunter-api.sh domain-search <domain> --limit 10
```

Merge with Apollo results, deduplicating by email address.

### Step 6: Score Decision Makers

Score each contact on a 1-10 Decision Maker scale per the Lead Intelligence skill:

- **10**: C-level executive (CEO, CTO, CFO) at a company in your ICP sweet spot
- **9**: VP-level with direct budget authority in your target department
- **8**: Director-level or Head of relevant department
- **7**: Senior Manager with influence over purchasing decisions
- **6**: Manager with team oversight in relevant area
- **5**: Senior individual contributor or technical lead
- **4**: Mid-level role, some influence
- **3**: Junior role, limited influence
- **2**: Support/admin role
- **1**: Intern/temp or irrelevant department

Factor in:
- Title seniority (C-level > VP > Director > Manager)
- Department relevance to your product
- Verified email availability (contacts with verified emails score higher)
- LinkedIn presence (active profiles indicate reachability)

### Step 7: Output Report

Group contacts by department. Store results in session memory for `/export-leads`.

```markdown
# Contacts Report: [Company Name]

**Domain**: [domain] | **Date**: [YYYY-MM-DD]
**Contacts found**: [N] total | **With verified email**: [N] | **With phone**: [N]

---

## Decision Makers

| # | Name | Title | Email | Confidence | Phone | LinkedIn | DM Score |
|---|------|-------|-------|------------|-------|----------|----------|
| 1 | [name] | [title] | [email] | [X]% | [phone] | [url] | [X]/10 |
| 2 | [name] | [title] | [email] | [X]% | [phone] | [url] | [X]/10 |
| 3 | [name] | [title] | [email] | [X]% | [phone] | [url] | [X]/10 |
| ... | ... | ... | ... | ... | ... | ... | ... |

## By Department

### Executive
| Name | Title | Email | DM Score |
|------|-------|-------|----------|
| [name] | [title] | [email] | [X]/10 |

### Engineering
| Name | Title | Email | DM Score |
|------|-------|-------|----------|
| [name] | [title] | [email] | [X]/10 |

### Sales & Marketing
| Name | Title | Email | DM Score |
|------|-------|-------|----------|
| [name] | [title] | [email] | [X]/10 |

### Finance & Operations
| Name | Title | Email | DM Score |
|------|-------|-------|----------|
| [name] | [title] | [email] | [X]/10 |

### Other
| Name | Title | Email | DM Score |
|------|-------|-------|----------|
| [name] | [title] | [email] | [X]/10 |

## Recommended Outreach Targets

1. **Primary** (highest DM score): [Name], [Title] — [email]
   - **Why**: [reason — e.g., "VP Engineering with budget authority, verified email"]
   - **Approach**: [suggested channel and hook]

2. **Secondary** (backup decision maker): [Name], [Title] — [email]
   - **Why**: [reason]
   - **Approach**: [suggested channel and hook]

3. **Influencer** (technical evaluator or champion): [Name], [Title] — [email]
   - **Why**: [reason]
   - **Approach**: [suggested channel and hook]

## Email Pattern

- **Detected pattern**: [e.g., {first}@domain.com, {first}.{last}@domain.com]
- **Pattern confidence**: [X]%
- **Accept-all domain**: [Yes/No]

## Data Sources

- Apollo org chart: [N] contacts
- Apollo people search: [N] contacts
- Hunter domain search: [N] contacts
- Hunter email finder: [N] lookups
- Total unique contacts: [N]

---

**Next steps**: `/craft-outreach "[Primary Target Name]"` | `/deep-research "[Company]"` | `/export-leads`
```
