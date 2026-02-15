---
name: check-signals
description: Detect buying intent signals for a company — hiring, funding, leadership, tech changes, competitor dissatisfaction
argument-hint: "Company Name" [your-product-category]
allowed-tools: Read, Bash, WebSearch, WebFetch
---

Detect buying intent signals for: $ARGUMENTS

Use the Lead Intelligence skill and signal-weights.md reference for methodology.

## Process

### Step 1: Parse Input

Extract from "$ARGUMENTS":
- **Company name**: The target company (required)
- **Product category** (optional): Your product type for relevance filtering (e.g., "CRM", "cloud infrastructure", "marketing automation")

### Step 2: Detect Signals Across 5 Categories

Run signal detection searches using the scripts. Evaluate each signal 0-100.

#### Signal 1: Hiring Signals (30% weight)

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh jobs "<company>"
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh search "<company> hiring <product-category-related roles>" --time m
```

Look for:
- Job postings suggesting need for your product category
- Roles indicating team build-out your product serves
- Technical requirements mentioning technologies you integrate with
- Headcount growth in relevant departments

Score:
- 80+: Multiple relevant roles posted recently
- 60-79: Some relevant hiring activity
- 40-59: General hiring, not specifically relevant
- <40: No relevant hiring signals

#### Signal 2: Funding Signals (25% weight)

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh news "<company> funding" --num 5
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh search "<company> series raises investment crunchbase"
```

Look for:
- Recent funding rounds (last 6 months = strongest signal)
- Size of round (larger = bigger budget)
- Stated use of funds (mentions your category?)
- Investor quality (tier-1 VCs suggest growth trajectory)

Score:
- 80+: Raised in last 3 months, large round
- 60-79: Raised in last 6 months
- 40-59: Raised in last 12 months
- <40: No recent funding

#### Signal 3: Leadership Changes (20% weight)

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh news "<company> appoints new CTO VP" --num 5
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh search "<company> leadership changes executive hire"
```

Look for:
- New C-level or VP in relevant department (first 90 days = buying window)
- Departures suggesting strategic shifts
- Board additions signaling new direction
- Reorgs creating new decision-makers

Score:
- 80+: New relevant exec in last 90 days
- 60-79: New exec in last 6 months
- 40-59: Reorg or board changes
- <40: Stable leadership

#### Signal 4: Tech Stack Changes (15% weight)

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh search "<company> migrating evaluating platform" --time m
bash ${CLAUDE_PLUGIN_ROOT}/scripts/github-api.sh languages <org>
```

Look for:
- Mentions of migrating or replacing existing tools
- Blog posts about evaluating new solutions
- Job postings requiring new/different tech
- Conference talks about tech transitions

Score:
- 80+: Active migration or evaluation underway
- 60-79: Signals of tech stack review
- 40-59: General modernization indicators
- <40: No change signals

#### Signal 5: Competitor Dissatisfaction (10% weight)

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh search "<company> <competitor> problems switching alternative"
```

Look for:
- Negative reviews of their current vendor
- Public complaints or switching discussions
- RFP signals or vendor evaluation mentions
- Support escalation patterns

Score:
- 80+: Active vendor evaluation or public dissatisfaction
- 60-79: Some negative sentiment about current tool
- 40-59: Neutral or mixed signals
- <40: No dissatisfaction detected

### Step 3: Apply Recency Multiplier

Weight signals by freshness per signal-weights.md:

| Signal Age | Multiplier |
|-----------|------------|
| Last 30 days | 1.0x |
| 31-90 days | 0.8x |
| 91-180 days | 0.6x |
| 181-365 days | 0.4x |
| Over 1 year | 0.2x |

### Step 4: Calculate Intent Score

```
Intent Score = (
  hiring_score      * 0.30 +
  funding_score     * 0.25 +
  leadership_score  * 0.20 +
  tech_change_score * 0.15 +
  dissatisfaction   * 0.10
) * recency_multiplier
```

Classify:
- 80+: HOT
- 60-79: WARM
- 40-59: NURTURE
- <40: NOT READY

### Step 5: Output Report

```markdown
# Buying Intent Report: [Company Name]

**Product Category**: [category or "General"] | **Date**: [YYYY-MM-DD]

## Intent Score: [X]/100 — [HOT/WARM/NURTURE/NOT READY]

### Signal Breakdown

| Signal | Score | Weight | Weighted | Key Finding |
|--------|-------|--------|----------|-------------|
| Hiring | [X] | 30% | [X] | [summary] |
| Funding | [X] | 25% | [X] | [summary] |
| Leadership | [X] | 20% | [X] | [summary] |
| Tech Changes | [X] | 15% | [X] | [summary] |
| Competitor Issues | [X] | 10% | [X] | [summary] |

### Detected Signals (Chronological)

1. **[Date]** [Signal type]: [Description] (Source: [URL])
2. **[Date]** [Signal type]: [Description] (Source: [URL])
3. **[Date]** [Signal type]: [Description] (Source: [URL])

### Recommended Action

- **HOT (80+)**: Immediate outreach. Reference [strongest signal] in opening.
- **WARM (60-79)**: Add to active campaign. Monitor for additional signals.
- **NURTURE (40-59)**: Add to nurture sequence. Check back in 30 days.
- **NOT READY (<40)**: Low priority. Set reminder for 90-day re-check.

### Signal Freshness

- Most recent signal: [date]
- Average signal age: [X] days
- Recency multiplier applied: [X]x

## Data Sources

- SerpAPI searches: [N] queries
- News articles reviewed: [N]
- Job postings found: [N]
- GitHub repos checked: [N]
- Review sites checked: [N]

---

**Next steps**: `/deep-research "[Company]"` | `/craft-outreach "[Contact]"` | `/find-contacts "[Company]"`
```
