# Buying Intent Signal Detection Methodology

How Prospector detects, scores, and prioritizes buying intent signals for target companies.

## Overview

Buying intent signals are observable events that indicate a company may be ready to purchase a product or service. Prospector monitors 5 signal categories, each with specific search queries, scoring rubrics, and freshness weights.

## Signal Categories

### 1. Hiring Signals (30% weight)

**Why it matters:** Companies hire for roles they need to fill. If they're hiring roles your product serves or replaces, they have budget and urgency.

**Search queries:**
```
"[Company]" hiring [role keywords]
"[Company]" careers site:linkedin.com/jobs
"[Company]" open positions site:greenhouse.io OR site:lever.co
"[Company]" "we're hiring" [department]
```

**Scoring rubric:**
| Criteria | Score |
|----------|-------|
| 3+ relevant roles posted in last 30 days | 90-100 |
| 1-2 relevant roles in last 30 days | 70-89 |
| Relevant roles posted 1-3 months ago | 50-69 |
| General hiring, not specifically relevant | 30-49 |
| No relevant hiring activity | 0-29 |

**What makes a role "relevant":**
- Matches your product category (e.g., DevOps tools → DevOps Engineer)
- Mentions your competitors or your tech category
- Describes building a function your product automates
- Reports to a decision-maker title

### 2. Funding Signals (25% weight)

**Why it matters:** Companies that just raised capital have budget to spend. The first 6 months post-funding are the prime buying window.

**Search queries:**
```
"[Company]" funding round 2025 OR 2026
"[Company]" raises million
"[Company]" series site:crunchbase.com OR site:techcrunch.com
"[Company]" investment announcement
```

**Scoring rubric:**
| Criteria | Score |
|----------|-------|
| Raised in last 90 days, $10M+ | 90-100 |
| Raised in last 90 days, <$10M | 75-89 |
| Raised in last 6 months | 60-74 |
| Raised in last 12 months | 40-59 |
| No recent funding | 0-39 |

**Bonus modifiers:**
- Stated use of funds mentions your category: +15
- Tier-1 VC investors: +10
- Growth stage (Series B+): +5

### 3. Leadership Changes (20% weight)

**Why it matters:** New executives change priorities. The first 90 days of a new leader is the prime buying window — they want quick wins and will evaluate new vendors.

**Search queries:**
```
"[Company]" appoints OR hires [CTO/VP/Director/Head]
"[Company]" new [executive title]
"[Company]" "joins as" OR "named as"
"[Company]" leadership site:linkedin.com
```

**Scoring rubric:**
| Criteria | Score |
|----------|-------|
| New relevant exec in last 90 days | 90-100 |
| New relevant exec in last 6 months | 65-89 |
| Relevant reorg or restructuring | 50-64 |
| Board-level changes | 35-49 |
| No leadership changes | 0-34 |

**Relevance criteria:**
- New CTO/VP Engineering (for tech products)
- New VP Sales/Marketing (for sales/marketing tools)
- New CFO (for financial tools)
- New CISO (for security products)

### 4. Tech Stack Changes (15% weight)

**Why it matters:** Companies actively changing their tech stack are evaluating alternatives. If you see migration signals, they're open to new vendors.

**Search queries:**
```
"[Company]" migrating from [competitor]
"[Company]" evaluating [your category]
"[Company]" site:stackshare.io
"[Company]" engineering blog migration OR modernization
"[Company]" "moving to" OR "switching to" [technology]
```

**Scoring rubric:**
| Criteria | Score |
|----------|-------|
| Active migration from competitor | 90-100 |
| Public evaluation of alternatives | 70-89 |
| Engineering blog about modernization | 50-69 |
| Job posts requiring new tech | 35-49 |
| No change signals | 0-34 |

### 5. Competitor Dissatisfaction (10% weight)

**Why it matters:** If a company is unhappy with their current vendor (your competitor), they're primed for displacement.

**Search queries:**
```
"[Company]" "[competitor]" problems OR issues
"[Company]" review site:g2.com OR site:capterra.com
"[Company]" switching from [competitor]
"[Company]" "[competitor] alternative"
"[Company]" RFP [your category]
```

**Scoring rubric:**
| Criteria | Score |
|----------|-------|
| Active vendor evaluation / RFP | 90-100 |
| Public complaints about current vendor | 70-89 |
| Low review scores for current tool | 50-69 |
| Neutral signals, no strong sentiment | 25-49 |
| No dissatisfaction detected | 0-24 |

## Recency Multiplier

All signal scores are adjusted by freshness:

```
Signal age → Multiplier
0-30 days     → 1.0x
31-90 days    → 0.8x
91-180 days   → 0.6x
181-365 days  → 0.4x
365+ days     → 0.2x
```

Apply to individual signal scores before computing the weighted composite.

## Composite Intent Score

```
Intent Score = sum of (signal_score * signal_weight * recency_multiplier)
```

### Classification

| Score | Level | Meaning | Recommended Action |
|-------|-------|---------|-------------------|
| 80-100 | HOT | Multiple strong, recent signals | Immediate personalized outreach |
| 60-79 | WARM | Some positive signals detected | Active campaign, monitor closely |
| 40-59 | NURTURE | Weak or aging signals | Nurture sequence, re-check in 30 days |
| 0-39 | NOT READY | No meaningful signals | Low priority, re-check in 90 days |

## Integration with ICP

When both ICP and Intent scores are available:
```
Timing Score = (ICP * 0.4) + (Intent * 0.6)
```

**ICP Gate:** If ICP Score < 50, Timing is capped at NURTURE regardless of Intent. This prevents chasing high-intent but poor-fit prospects.

## Signal Sources Quality

| Source | Reliability | Freshness |
|--------|------------|-----------|
| Company careers page | High | Real-time |
| LinkedIn job posts | High | Real-time |
| Crunchbase funding | High | 1-2 week lag |
| News articles | Medium | 1-7 day lag |
| G2/Capterra reviews | Medium | Variable |
| Blog posts | Medium | Variable |
| Social media mentions | Low | Real-time but noisy |
