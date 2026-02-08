---
name: craft-outreach
description: Generate personalized outreach messages based on research context
argument-hint: "Name" [channel]
allowed-tools: Read, Write, Grep, Glob, Bash, WebSearch, WebFetch
---

Generate personalized outreach for: $ARGUMENTS

## Outreach Generation Process

### Step 1: Gather Context

Check conversation history for existing research on this person/company:
- Recent `/research-contact` profile (contact info, work history, DM score)
- Recent `/research-company` profile (company data, buying signals)
- Recent `/check-signals` results (intent indicators)
- Recent `/check-competitors` results (displacement opportunities)
- ICP score (from `.prospector/icp.json`)

If no prior research exists:
- Run a quick research pass (abbreviated `/research-contact`)
- Gather enough for personalization (current role, recent activity, company news)

### Step 2: Determine Best Channel

Evaluate channel fit based on available data:

**Email** (preferred when):
- High-confidence email available (>80%)
- Professional/executive target (VP+)
- Complex value proposition requiring detail

**LinkedIn** (preferred when):
- Active LinkedIn presence detected
- Mutual connections available
- InMail more likely to reach than email

**Twitter/X** (preferred when):
- Active Twitter presence (>500 followers)
- They engage with industry content
- Casual, thought-leadership approach fits

Output recommended channel with reasoning.

### Step 3: Select Personalization Hooks

From gathered context, identify the strongest hooks:

**Signal-led hooks** (strongest — reference a trigger event):
- Recent funding: "Congrats on the Series B..."
- New role: "Welcome to [Company] — the first 90 days..."
- Product launch: "Saw the announcement about..."
- Hiring surge: "Looks like the team is growing fast..."

**Problem-led hooks** (strong — reference a known pain point):
- Industry challenge: "Most [titles] in [industry] face..."
- Competitor issue: "Teams migrating from [competitor] often find..."
- Scale challenge: "As you grow past [size], [problem] becomes..."

**Connection-led hooks** (moderate — reference shared context):
- Mutual connection: "Saw you're connected to [name]..."
- Conference: "Caught your talk at [event]..."
- Content: "Your post about [topic] resonated..."
- Alma mater: "Fellow [school] grad here..."

**Activity-led hooks** (moderate — reference recent public activity):
- Recent post: "Your take on [topic] was interesting..."
- Published article: "Read your piece in [publication]..."
- Open source: "Noticed your contributions to [project]..."

Rank hooks by strength and relevance.

### Step 4: Generate 3 Message Variants

Create three distinct outreach messages using different hooks:

**Variant 1: Signal-Led**
```
Subject: [Reference to trigger event]

Hi [First Name],

[1-2 sentences referencing the specific signal/event]

[1-2 sentences connecting the signal to your value proposition]

[Soft CTA — question or offer, not a meeting request]

[Signature]
```

**Variant 2: Problem-Led**
```
Subject: [Reference to common challenge]

Hi [First Name],

[1-2 sentences describing a challenge relevant to their role/industry]

[1-2 sentences about how you've helped similar companies]

[Soft CTA — offer insight or resource]

[Signature]
```

**Variant 3: Connection-Led**
```
Subject: [Personal connection reference]

Hi [First Name],

[1-2 sentences about the shared context/connection]

[1 sentence pivoting to value]

[Soft CTA — casual and conversational]

[Signature]
```

### Step 5: Suggest Follow-Up Sequence

Based on the recommended channel:

**Email Sequence:**
- **Day 0**: Initial outreach (Variant 1 or strongest hook)
- **Day 3**: Follow-up with new angle (Variant 2)
- **Day 7**: Final touch — share a relevant resource or insight
- **Day 14**: Break-up email (last attempt, gives permission to stop)

**LinkedIn Sequence:**
- **Day 0**: Connection request with personalized note
- **Day 2**: Thank for connecting + brief value message
- **Day 5**: Share relevant content with comment
- **Day 10**: Direct message with CTA

### Step 6: Generate Report

```markdown
# Outreach Plan: [Full Name] at [Company]

## Contact Summary
- **Name**: [Full Name]
- **Title**: [Title] at [Company]
- **DM Score**: [X]/10
- **ICP Score**: [X]/100 ([Match Level])
- **Intent Score**: [X]/100 ([Level])

## Recommended Channel: [Email/LinkedIn/Twitter]
**Reasoning**: [Why this channel is best for this person]

## Personalization Hooks (Ranked)
1. **[Hook type]**: [Specific hook] (Strength: [Strong/Moderate])
2. **[Hook type]**: [Specific hook] (Strength: [Strong/Moderate])
3. **[Hook type]**: [Specific hook] (Strength: [Strong/Moderate])

## Message Variants

### Variant 1: Signal-Led
**Subject**: [Subject line]
> [Full message body]

### Variant 2: Problem-Led
**Subject**: [Subject line]
> [Full message body]

### Variant 3: Connection-Led
**Subject**: [Subject line]
> [Full message body]

## Follow-Up Sequence
| Day | Action | Message |
|-----|--------|---------|
| 0 | [Channel]: Initial outreach | Use Variant 1 |
| 3 | [Channel]: Follow-up | Use Variant 2 |
| 7 | [Channel]: Value add | Share [resource/insight] |
| 14 | [Channel]: Break-up | Permission-based close |

## Notes
- [Any caveats about data freshness]
- [Suggested timing: best day/time to send]
- [Do not mention: topics to avoid]
```
