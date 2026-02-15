# ICP Scoring Framework

## Formula

```
ICP Score = (company_fit * 0.6) + (contact_fit * 0.4)
```

## Company Fit (0-100)

### Industry Match (40% of company fit)
- Primary industry match: 100
- Secondary/adjacent industry: 75
- Related but different: 40
- No match: 0

### Company Size (30% of company fit)
- Within defined range: 100
- Within 2x of range: 60
- Outside range: 20

### Revenue Match (20% of company fit)
- Within defined range: 100
- Within 2x: 60
- Outside or unknown: 30

### Geography (10% of company fit)
- Target geography: 100
- Adjacent market: 60
- Outside target: 20

## Contact Fit (0-100)

### Title Match (50% of contact fit)
- Exact priority 1 title: 100
- Exact priority 2-3 title: 85
- Partial match: 60
- Related but different: 40

### Seniority Match (30% of contact fit)
- Exact level: 100
- One level off: 70
- Two+ levels: 20

### Department Match (20% of contact fit)
- Target department: 100
- Related department: 60
- Unrelated: 20

## Classification

| Score Range | Level | Action |
|-------------|-------|--------|
| 80-100 | Strong | Prioritize outreach immediately |
| 60-79 | Good | Include in active campaigns |
| 40-59 | Moderate | Consider only if intent signals are strong |
| 0-39 | Poor | Deprioritize |
