---
name: set-icp
description: Define your Ideal Customer Profile for automated prospect scoring
argument-hint: [industry/size/stack]
allowed-tools: Read, Write, Bash
---

Define or update your Ideal Customer Profile (ICP) for automated scoring.

Use the Prospect Research skill's ICP methodology for guidance.

## ICP Builder Process

### Step 1: Check Existing Configuration

Check if `.prospector/icp.json` exists in the current project:
- If found, display the current ICP configuration and ask if the user wants to update it
- If not found, start the interactive builder

### Step 2: Interactive ICP Builder

Guide the user through defining their ideal customer. If arguments were provided ("$ARGUMENTS"), use them as starting context. Otherwise, ask about each dimension:

**Company Fit Dimensions (60% of total ICP score):**

1. **Target Industries** (weight: 25%)
   - Ask: "What industries are your best customers in?"
   - Examples: SaaS, FinTech, Healthcare, E-commerce, Manufacturing
   - Support multiple selections with priority ranking

2. **Company Size** (weight: 20%)
   - Ask: "What's your ideal company size range?"
   - Ranges: 1-10, 11-50, 51-200, 201-1000, 1001-5000, 5000+
   - Support min-max range

3. **Tech Stack Indicators** (weight: 15%)
   - Ask: "What technologies indicate a good fit?"
   - Examples: AWS, Kubernetes, React, Salesforce, Snowflake
   - These will be matched against job postings and BuiltWith data

**Contact Fit Dimensions (40% of total ICP score):**

4. **Target Titles/Roles** (weight: 25%)
   - Ask: "What titles do your buyers typically have?"
   - Examples: VP Engineering, CTO, Head of DevOps, Director of IT
   - Support multiple with priority

5. **Seniority Level** (weight: 15%)
   - Ask: "What seniority level is your primary buyer?"
   - Options: C-level, VP, Director, Manager, Individual Contributor

### Step 3: Set Scoring Weights

Present the default weights and allow customization:

```
Company Fit (60% of total):
  - Industry match:  25%
  - Size match:      20%
  - Tech stack match: 15%

Contact Fit (40% of total):
  - Title match:     25%
  - Seniority match: 15%
```

Ask: "Would you like to adjust these weights, or use the defaults?"

### Step 4: Save Configuration

Save to `.prospector/icp.json`:

```json
{
  "version": "1.0",
  "created": "2026-02-08",
  "updated": "2026-02-08",
  "company_fit": {
    "weight": 0.6,
    "industries": {
      "weight": 0.25,
      "targets": ["SaaS", "FinTech"],
      "priority": {"SaaS": 1, "FinTech": 2}
    },
    "size": {
      "weight": 0.20,
      "min_employees": 50,
      "max_employees": 1000
    },
    "tech_stack": {
      "weight": 0.15,
      "indicators": ["AWS", "Kubernetes", "React"]
    }
  },
  "contact_fit": {
    "weight": 0.4,
    "titles": {
      "weight": 0.25,
      "targets": ["VP Engineering", "CTO", "Head of DevOps"],
      "priority": {"VP Engineering": 1, "CTO": 2, "Head of DevOps": 3}
    },
    "seniority": {
      "weight": 0.15,
      "targets": ["VP", "C-level", "Director"]
    }
  }
}
```

### Step 5: Confirm and Display

Show the configured ICP with scoring examples:

```markdown
## Your Ideal Customer Profile

### Company Fit (60%)
- **Industries**: SaaS (primary), FinTech (secondary)
- **Size**: 50-1,000 employees
- **Tech Stack**: AWS, Kubernetes, React

### Contact Fit (40%)
- **Titles**: VP Engineering, CTO, Head of DevOps
- **Seniority**: VP, C-level, Director

### Scoring Examples
- SaaS company, 200 employees, uses AWS, VP Engineering → **ICP: 95 (Strong)**
- FinTech company, 5000 employees, uses Azure, Director → **ICP: 62 (Good)**
- Manufacturing, 50 employees, unknown stack, Manager → **ICP: 35 (Poor)**

Your ICP is saved. All `/research-contact`, `/research-company`, and `/enrich-batch` commands will now include ICP scores automatically.
```
