# ICP Scoring Methodology

How Prospector calculates Ideal Customer Profile fit scores for prospects and companies.

## Overview

ICP scoring produces a 0-100 composite score that measures how closely a prospect matches your defined ideal customer. The score combines company-level and contact-level attributes with configurable weights.

## Composite Formula

```
ICP Score = (company_fit * company_weight) + (contact_fit * contact_weight)

Default weights:
  company_weight = 0.6
  contact_weight = 0.4
```

## Company Fit Score (0-100)

### Industry Match (default 25% of total)

```
Scoring:
  - Primary industry match:     100 points
  - Secondary industry match:    75 points
  - Adjacent industry:           40 points
  - No match:                     0 points
```

Industry adjacency examples:
- SaaS ↔ Cloud Infrastructure (adjacent)
- FinTech ↔ Banking (adjacent)
- E-commerce ↔ Retail Tech (adjacent)

### Company Size Match (default 20% of total)

```
Scoring:
  - Within ideal range:         100 points
  - Within 2x of range bounds:  60 points
  - Outside 2x range:           20 points
  - Unknown size:                50 points (neutral)
```

Example with ideal range 50-1000:
- 200 employees → 100
- 1500 employees (within 2x of 1000) → 60
- 5000 employees (outside 2x) → 20

### Tech Stack Match (default 15% of total)

```
Scoring:
  matched_count = number of ICP tech indicators found
  total_indicators = number of ICP tech indicators defined

  tech_score = (matched_count / total_indicators) * 100

  If no tech data found: 50 points (neutral)
```

Tech stack sources:
- Job postings mentioning specific technologies
- BuiltWith / Wappalyzer data via WebSearch
- Company engineering blog mentions

## Contact Fit Score (0-100)

### Title Match (default 25% of total)

```
Scoring:
  - Exact title match (priority 1):    100 points
  - Exact title match (priority 2-3):   85 points
  - Partial title match:                 60 points
  - Related title:                       40 points
  - No match:                            10 points
```

Partial match examples:
- ICP: "VP Engineering" → Match: "VP of Software Engineering" (partial, 60)
- ICP: "CTO" → Match: "Co-founder & CTO" (exact, 100)
- ICP: "Head of DevOps" → Match: "DevOps Manager" (related, 40)

### Seniority Match (default 15% of total)

```
Scoring:
  - Exact seniority match:    100 points
  - One level above:           80 points
  - One level below:           60 points
  - Two+ levels away:          20 points
```

Seniority hierarchy:
```
C-level (CEO, CTO, CFO, CIO, CISO)
  ↓
VP (VP of X, SVP)
  ↓
Director (Director of X, Senior Director)
  ↓
Manager (Manager, Senior Manager, Head of)
  ↓
Individual Contributor (Engineer, Analyst, Specialist)
```

## Match Level Classification

| Score | Level | Color | Action |
|-------|-------|-------|--------|
| 80-100 | Strong Match | Green | Prioritize outreach |
| 60-79 | Good Match | Blue | Include in campaigns |
| 40-59 | Moderate Match | Yellow | Consider if signals are strong |
| 0-39 | Poor Match | Red | Deprioritize |

## ICP Score in Context

### With Buying Intent

When combined with buying intent signals:
```
Timing Score = (ICP * 0.4) + (Intent * 0.6)

ICP Gate: If ICP < 50, cap Timing at NURTURE regardless of intent
```

This prevents wasting resources on high-intent prospects who are a poor fit.

### In Batch Processing

When enriching batches, ICP scores are used to:
1. Sort leads by priority (highest ICP first)
2. Add `icp_score` and `icp_match` columns to output
3. Generate an ICP distribution summary

### In Reports

ICP scores appear in:
- Contact profiles: "ICP Score: 85 (Strong Match)"
- Company profiles: Company-level ICP fit
- Batch summaries: Distribution of match levels
- Priority rankings: Combined with intent for timing

## Configuration

ICP configuration is stored in `.prospector/icp.json` and created via the `/set-icp` command. All scoring commands automatically check for this file and include ICP scores when available.

If no ICP is configured, research commands still work but skip ICP scoring and show a note suggesting `/set-icp`.

## Updating ICP

Run `/set-icp` again to update your profile. Common reasons to update:
- Expanding to new markets (add industries)
- Moving upmarket/downmarket (adjust size range)
- New product line (different buyer titles)
- Seasonal adjustments

The `updated` timestamp in the config tracks when the ICP was last modified.
