# Buying Intent Signal Weights

## Formula

```
Intent Score = (
  hiring_score      * 0.30 +
  funding_score     * 0.25 +
  leadership_score  * 0.20 +
  tech_change_score * 0.15 +
  dissatisfaction   * 0.10
) * recency_multiplier
```

## Signal Scoring (each 0-100)

### 1. Hiring Signals (30% weight)
- 80+: Multiple relevant roles posted in last 30 days
- 60-79: Some relevant hiring activity
- 40-59: General hiring, not specifically relevant
- <40: No relevant hiring signals

Search queries:
- `serp-api.sh jobs "<company>"` for job postings
- `serp-api.sh search "<company> hiring <role>" --time m` for recent postings

### 2. Funding Signals (25% weight)
- 80+: Raised in last 3 months, large round
- 60-79: Raised in last 6 months
- 40-59: Raised in last 12 months
- <40: No recent funding

Search queries:
- `serp-api.sh news "<company> funding" --num 5`
- `serp-api.sh search "<company> series raises investment crunchbase"`

### 3. Leadership Changes (20% weight)
- 80+: New relevant exec in last 90 days (buying window)
- 60-79: New exec in last 6 months
- 40-59: Reorg or board changes
- <40: Stable leadership

Search queries:
- `serp-api.sh news "<company> appoints new CTO VP" --num 5`
- `serp-api.sh search "<company> leadership changes executive hire"`

### 4. Tech Stack Changes (15% weight)
- 80+: Active migration or evaluation underway
- 60-79: Signals of tech stack review
- 40-59: General modernization indicators
- <40: No change signals

Search queries:
- `serp-api.sh search "<company> migrating evaluating platform" --time m`
- `github-api.sh languages <org>` for tech stack shifts

### 5. Competitor Dissatisfaction (10% weight)
- 80+: Active vendor evaluation or public dissatisfaction
- 60-79: Some negative sentiment about current tool
- 40-59: Neutral or mixed signals
- <40: No dissatisfaction detected

Search queries:
- `serp-api.sh search "<company> <competitor> problems switching alternative"`

## Recency Multiplier

| Signal Age | Multiplier |
|-----------|------------|
| Last 30 days | 1.0x |
| 31-90 days | 0.8x |
| 91-180 days | 0.6x |
| 181-365 days | 0.4x |
| Over 1 year | 0.2x |

## Priority Score

```
Priority = (ICP * 0.4) + (Intent * 0.6)
```

**ICP Gating:** If ICP Score < 50, Priority is capped at NURTURE regardless of Intent.

| Priority Score | Level | Action | Timeline |
|---------------|-------|--------|----------|
| 80-100 | HOT | Personalized outreach referencing top signal | Today |
| 60-79 | WARM | Active campaign sequence | This week |
| 40-59 | NURTURE | Monitor, check back in 30 days | This month |
| 0-39 | COLD | Park, re-check in 90 days | Next quarter |
