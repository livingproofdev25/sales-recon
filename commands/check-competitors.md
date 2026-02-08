---
name: check-competitors
description: Competitive displacement analysis for a target company
argument-hint: "Company Name" [your-product-category]
allowed-tools: Read, Write, Grep, Glob, Bash, WebSearch, WebFetch, Task
---

Analyze competitive displacement opportunities at: $ARGUMENTS

Use the Prospect Research skill for methodology guidance.

## Competitive Analysis Process

### Step 1: Parse Input

Extract from "$ARGUMENTS":
- **Company name**: The target company
- **Product category** (optional): Your product type to focus the analysis

### Step 2: Detect Current Tech Stack

Search for what tools/vendors the company currently uses:

**Job posting analysis:**
- Search "[Company] careers" and "[Company] site:linkedin.com/jobs"
- Extract technology requirements from job descriptions
- Map to vendor/product categories

**BuiltWith / tech detection:**
- Search "[Company] site:builtwith.com" or "[Company] tech stack"
- Search "[Company] site:stackshare.io"
- Look for technology mentions on their engineering blog

**Integration clues:**
- Search "[Company] integrates with" or "[Company] uses [category]"
- Check case studies: "[Company] case study [vendor]"
- Look for partner/integration pages on company website

Output a vendor map:
```
Category → Current Vendor → Confidence
CRM → Salesforce → High (job posts mention it)
CI/CD → Jenkins → Medium (blog post from 6 months ago)
Analytics → Unknown → Low
```

### Step 3: Find Dissatisfaction Signals

Search for pain points with current vendors:

**Review sites:**
- Search "site:g2.com [Company]" for their reviews of tools
- Search "site:capterra.com [Company]"
- Search "site:trustradius.com [Company]"

**Public complaints:**
- Search "[Company] [current vendor] problems"
- Search "[Company] [current vendor] alternative"
- Search "[Company] [current vendor] switching"

**Community signals:**
- Search "site:reddit.com [Company] [current vendor]"
- Search "site:news.ycombinator.com [Company] [current vendor]"

Score dissatisfaction 0-100:
- 80+: Active vendor evaluation or public complaints
- 60-79: Some negative sentiment detected
- 40-59: Mixed or neutral reviews
- <40: Satisfied or no data

### Step 4: Identify Switching Triggers

Determine what would cause them to switch:

**Pricing triggers:**
- Are they on an expensive legacy contract?
- Did current vendor recently raise prices?
- Are they scaling beyond current plan limits?

**Feature triggers:**
- Do job posts mention capabilities their current tool lacks?
- Are they building workarounds or custom solutions?
- Do they mention "wish list" features publicly?

**Support triggers:**
- Any public support escalations?
- Mentions of poor vendor responsiveness?
- Community posts asking for help with current tool?

**Scale triggers:**
- Growing rapidly (hiring signals)?
- Current tool may not scale to their needs?
- Moving to enterprise tier from SMB tools?

### Step 5: Generate Displacement Talking Points

Based on findings, create personalized talking points:

For each identified competitor/vendor:
- What pain points suggest switching opportunity?
- What specific advantages does your product offer?
- What migration path would be easiest?
- What ROI argument would resonate?

### Step 6: Generate Report

```markdown
# Competitive Displacement Analysis: [Company Name]

## Current Vendor Map

| Category | Current Vendor | Confidence | Source |
|----------|---------------|------------|--------|
| [Category] | [Vendor] | [High/Med/Low] | [Where detected] |
| [Category] | [Vendor] | [High/Med/Low] | [Where detected] |
| [Category] | [Vendor] | [High/Med/Low] | [Where detected] |

## Dissatisfaction Score: [X]/100

### Detected Pain Points
1. **[Vendor]**: [Specific complaint or issue] (Source: [where found])
2. **[Vendor]**: [Specific complaint or issue] (Source: [where found])

### Sentiment Analysis
- Positive mentions: [N]
- Neutral mentions: [N]
- Negative mentions: [N]

## Switching Triggers

| Trigger Type | Signal | Strength |
|-------------|--------|----------|
| Pricing | [Finding] | [High/Med/Low] |
| Features | [Finding] | [High/Med/Low] |
| Support | [Finding] | [High/Med/Low] |
| Scale | [Finding] | [High/Med/Low] |

## Displacement Opportunity: [High/Medium/Low]

### Talking Points

**For displacing [Vendor A]:**
1. [Pain point] → [Your advantage]
2. [Pain point] → [Your advantage]
3. Migration path: [Suggested approach]

**For displacing [Vendor B]:**
1. [Pain point] → [Your advantage]
2. [Pain point] → [Your advantage]

### Recommended Approach
- **Lead with**: [Strongest pain point or trigger]
- **Avoid**: [Topics that favor incumbent]
- **Proof points needed**: [Case studies, benchmarks, etc.]

## Data Sources
- Job postings analyzed: [N]
- Review sites checked: [List]
- News/blog articles: [N]
- Community threads: [N]
```
