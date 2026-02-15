---
name: set-icp
description: Define your Ideal Customer Profile — industries, company size, revenue, geography, tech stack, target titles
argument-hint:
allowed-tools: Read, Write
---

Define or update your Ideal Customer Profile (ICP) for automated prospect scoring.

Use the Lead Intelligence skill and icp-framework.md reference for methodology.

## Process

### Step 1: Check Existing Configuration

Check if `~/.claude/sales-recon.local.md` exists and contains an ICP configuration.

Read the file and look for the `default_icp` section in the YAML frontmatter.

If an ICP already exists, display the current configuration and ask the user:
- "You have an existing ICP configured. Would you like to **update** specific fields, or **replace** the entire ICP?"

If no file exists or no ICP is configured, proceed to Step 2.

### Step 2: Interactive ICP Builder

Walk the user through each ICP dimension. If "$ARGUMENTS" contains any initial context, use it as a starting point.

Ask about each dimension one at a time:

**Dimension 1: Target Industries**
- Ask: "What industries are your best customers in? List your top 2-5."
- Examples: SaaS, FinTech, Healthcare, E-commerce, Manufacturing, Construction, Real Estate, Professional Services
- Store as priority-ordered list (first = primary)

**Dimension 2: Company Size Range**
- Ask: "What's your ideal company size range (by employee count)?"
- Suggest ranges: 1-10, 11-50, 51-200, 201-1000, 1001-5000, 5000+
- Store as min_employees and max_employees

**Dimension 3: Revenue Range**
- Ask: "What annual revenue range are you targeting?"
- Suggest ranges: <$1M, $1-10M, $10-50M, $50-100M, $100M-1B, $1B+
- Store as min_revenue and max_revenue strings

**Dimension 4: Target Geography**
- Ask: "What locations/regions are you targeting?"
- Examples: "Austin TX", "Texas", "US Southwest", "United States"
- Support multiple selections

**Dimension 5: Target Titles (Priority Order)**
- Ask: "What job titles do your buyers typically have? List in priority order."
- Examples: VP Engineering, CTO, Head of DevOps, Director of IT, Owner, General Manager
- Store as priority 1, 2, 3 list

**Dimension 6: Target Departments**
- Ask: "What departments are your buyers in?"
- Examples: Engineering, Sales, Marketing, Operations, Finance, Executive, IT
- Store as list

**Dimension 7: Tech Stack Indicators (optional)**
- Ask: "Any specific technologies that indicate a good fit? (optional)"
- Examples: AWS, Kubernetes, Salesforce, React, Python
- Store as list (can be empty)

**Dimension 8: Pain Points / Use Cases (optional)**
- Ask: "What pain points or use cases does your product solve? (optional)"
- Examples: "scaling engineering teams", "reducing churn", "automating outreach"
- Store as list (can be empty)

### Step 3: Write Configuration

Write the ICP to `~/.claude/sales-recon.local.md`. If the file already exists, update only the `default_icp` section in the YAML frontmatter while preserving other settings (API keys, output_format, etc.).

If the file does not exist, create it with the full template:

```yaml
---
hunter_api_key: ""
apollo_api_key: ""
serp_api_key: ""
google_places_api_key: ""
rentcast_api_key: ""
default_icp:
  industries:
    - "[Primary industry]"
    - "[Secondary industry]"
  min_employees: [N]
  max_employees: [N]
  min_revenue: "[range]"
  max_revenue: "[range]"
  geo:
    - "[location 1]"
    - "[location 2]"
  target_titles:
    - "[Priority 1 title]"
    - "[Priority 2 title]"
    - "[Priority 3 title]"
  target_departments:
    - "[dept 1]"
    - "[dept 2]"
  tech_stack:
    - "[tech 1]"
    - "[tech 2]"
  pain_points:
    - "[pain point 1]"
    - "[pain point 2]"
output_format: "markdown"
---
# Sales-Recon Settings
This file stores your sales-recon plugin configuration.
API keys are stored locally and never committed to git.
```

### Step 4: Confirm and Display

Show the saved ICP with scoring examples:

```markdown
## Your Ideal Customer Profile — Saved

### Company Fit (60% of ICP score)
- **Industries**: [list with primary/secondary labels]
- **Size**: [min]-[max] employees
- **Revenue**: [min]-[max]
- **Geography**: [list]

### Contact Fit (40% of ICP score)
- **Titles**: [priority-ordered list]
- **Departments**: [list]
- **Seniority**: [inferred from titles]

### Tech Stack Indicators
- [list or "None specified"]

### Pain Points
- [list or "None specified"]

### Scoring Examples
- [Primary industry], [mid-range size], [target title] -> **ICP: ~90 (Strong)**
- [Secondary industry], [edge-of-range size], [related title] -> **ICP: ~65 (Good)**
- [Non-target industry], [outside range], [unrelated title] -> **ICP: ~25 (Poor)**

Your ICP is saved to `~/.claude/sales-recon.local.md`.
All `/prospect`, `/deep-research`, `/score-icp`, and `/enrich-batch` commands will now include ICP scores automatically.
```
