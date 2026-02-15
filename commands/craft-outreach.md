---
name: craft-outreach
description: Generate personalized outreach messages based on gathered intelligence
argument-hint: "Name" [--style warm|cold|doorknock|linkedin|email]
allowed-tools: Read, Write, Bash, WebSearch, WebFetch
---

Generate personalized outreach for: $ARGUMENTS

Use the Lead Intelligence skill for B2B methodology and the Residential Intelligence skill for residential outreach.

## Process

### Step 1: Parse Input

Extract from "$ARGUMENTS":
- **Name**: Person or company name (required)
- **--style**: Outreach style (optional, default: `warm`)
  - `warm` — Warm email outreach referencing known signals/connections
  - `cold` — Cold email or direct mail with no prior relationship
  - `doorknock` — In-person/door knock script for residential leads
  - `linkedin` — LinkedIn connection request + follow-up sequence
  - `email` — Formal email with detailed value proposition

### Step 2: Gather Context

Check conversation history for existing research on this person/company:
- Recent `/prospect` results (company + contact data)
- Recent `/deep-research` profile (full company intelligence)
- Recent `/find-contacts` results (contact details, DM score)
- Recent `/check-signals` results (buying intent indicators)
- Recent `/homeowner-leads` results (property data, permit info)
- Recent `/property-lookup` results (owner details, property value)
- Recent `/score-icp` results (ICP fit)
- ICP config from `~/.claude/sales-recon.local.md`

If no prior research exists, run a quick research pass:

**For B2B targets**:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/apollo-api.sh company-enrich --domain <best-guess-domain>
bash ${CLAUDE_PLUGIN_ROOT}/scripts/serp-api.sh news "<company>" --num 3
```

**For residential targets** (if permit/property data is in context):
- Use existing property and permit data from the session

Gather enough context for personalization: current role/situation, recent activity, relevant signals.

### Step 3: Select Personalization Hooks

From gathered context, identify the strongest hooks ranked by type:

**Signal-led hooks** (strongest — reference a trigger event):
- Recent funding: "Congrats on the Series B..."
- New role: "Welcome to [Company] — the first 90 days..."
- Product launch: "Saw the announcement about..."
- Hiring surge: "Looks like the team is growing fast..."
- Permit filed: "Noticed you recently pulled a permit for..."
- Property improvement: "Your home on [Street] is in a great area for..."

**Problem-led hooks** (strong — reference a known pain point):
- Industry challenge: "Most [titles] in [industry] face..."
- Competitor issue: "Teams migrating from [competitor] often find..."
- Scale challenge: "As you grow past [size], [problem] becomes..."
- Home maintenance: "After a [project type], most homeowners also need..."
- Property value: "Protecting your investment in [area] means..."

**Connection-led hooks** (moderate — reference shared context):
- Mutual connection: "Saw you're connected to [name]..."
- Conference: "Caught your talk at [event]..."
- Content: "Your post about [topic] resonated..."
- Neighborhood: "We've done work for several of your neighbors on..."

**Activity-led hooks** (moderate — reference recent public activity):
- Recent post: "Your take on [topic] was interesting..."
- Published article: "Read your piece in [publication]..."
- Open source: "Noticed your contributions to [project]..."

Rank hooks by strength and relevance. Select top 3 for message variants.

### Step 4: Generate 3 Message Variants

Adapt variants to the selected `--style`:

#### Style: warm / email

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

#### Style: cold

**Variant 1: Direct Value**
```
Subject: [Specific benefit for their role]

Hi [First Name],

[1 sentence about their company/situation showing you did homework]

[2-3 sentences about a specific result you deliver for similar companies]

[Direct CTA — specific ask with low friction]

[Signature]
```

**Variant 2: Case Study**
```
Subject: How [Similar Company] achieved [result]

Hi [First Name],

[1 sentence connecting to their industry]

[2-3 sentences summarizing a relevant case study or result]

[CTA — offer to share the full case study]

[Signature]
```

**Variant 3: Question-Led**
```
Subject: Quick question about [their challenge area]

Hi [First Name],

[1 question about a challenge common in their industry]

[1-2 sentences about why you're asking — your expertise in this area]

[CTA — ask if it's worth a 10-minute conversation]

[Signature]
```

#### Style: doorknock (residential)

**Variant 1: Permit-Based**
```
Hi, I'm [Your Name] with [Company].

I noticed you recently [got a permit for / had work done on] [project type] at your home here on [Street].

[1 sentence connecting to your service — complementary or follow-up work]

We've helped [N] homeowners in [neighborhood/area] with [your service], and I wanted to see if you had any questions or needed help with [related need].

[Leave door hanger/card if not home]
```

**Variant 2: Neighborhood-Based**
```
Hi, I'm [Your Name] with [Company].

We're currently working with a few homeowners on [Street/in neighborhood] on [your service type], and I wanted to introduce myself in case you've been thinking about [related need].

[1-2 sentences about what makes you different — warranty, local, licensed, etc.]

Would it be helpful if I left you a quick estimate?
```

**Variant 3: Value-Based**
```
Hi, I'm [Your Name] with [Company].

Your home is beautiful — [specific compliment about the property]. I specialize in [your service] and noticed [observation relevant to your service].

[1 sentence about a specific benefit or concern relevant to them]

I'd be happy to do a free [inspection/assessment/estimate] if you're interested — no pressure at all.
```

#### Style: linkedin

**Connection Request** (300 char limit):
```
Hi [First Name] — [1 sentence personal hook: shared connection, signal, or relevant observation]. Would love to connect and share thoughts on [topic].
```

**Follow-Up Message** (after connected):
```
Thanks for connecting, [First Name]!

[1-2 sentences referencing their work/company/recent activity]

[1 sentence about your relevant expertise]

[Soft CTA — offer a resource or ask a question]
```

### Step 5: Suggest Follow-Up Sequence

**Email/Warm Sequence**:
| Day | Action | Content |
|-----|--------|---------|
| 0 | Initial email | Use strongest variant |
| 3 | Follow-up | New angle (second variant) |
| 7 | Value add | Share relevant resource or insight |
| 14 | Break-up | Final attempt, permission-based close |

**Cold Sequence**:
| Day | Action | Content |
|-----|--------|---------|
| 0 | Cold email | Direct value variant |
| 4 | Follow-up | Case study or social proof |
| 9 | Last touch | Question-led, invite response |

**LinkedIn Sequence**:
| Day | Action | Content |
|-----|--------|---------|
| 0 | Connection request | Personalized note |
| 2 | Thank + intro | Brief value message |
| 5 | Content share | Relevant content with comment |
| 10 | Direct message | Specific CTA |

**Door Knock Follow-Up**:
| Day | Action | Content |
|-----|--------|---------|
| 0 | Door knock | In-person script + leave card |
| 3 | Mail/postcard | Follow-up with offer |
| 7 | Second visit | Different time of day |
| 14 | Final mail | Last touch with seasonal urgency |

### Step 6: Output Report

```markdown
# Outreach Plan: [Name] at [Company/Address]

## Context Summary
- **Name**: [Full Name]
- **Title/Role**: [Title at Company] or [Homeowner at Address]
- **DM Score**: [X]/10 (B2B) or Lead Score: [X]/100 (Residential)
- **ICP Score**: [X]/100 ([Match Level]) (B2B only)
- **Intent Score**: [X]/100 ([Level]) (B2B only)
- **Style**: [warm/cold/doorknock/linkedin/email]

## Recommended Channel: [Email/LinkedIn/Door Knock/Direct Mail]
**Reasoning**: [Why this channel is best for this person/situation]

## Personalization Hooks (Ranked)
1. **[Hook type]**: [Specific hook] (Strength: [Strong/Moderate])
2. **[Hook type]**: [Specific hook] (Strength: [Strong/Moderate])
3. **[Hook type]**: [Specific hook] (Strength: [Strong/Moderate])

## Message Variants

### Variant 1: [Hook Type]
**Subject**: [Subject line] (email) / **Opening**: [First line] (doorknock/linkedin)
> [Full message body]

### Variant 2: [Hook Type]
**Subject**: [Subject line] / **Opening**: [First line]
> [Full message body]

### Variant 3: [Hook Type]
**Subject**: [Subject line] / **Opening**: [First line]
> [Full message body]

## Follow-Up Sequence

| Day | Action | Message |
|-----|--------|---------|
| 0 | [Channel]: Initial outreach | Use Variant 1 |
| [N] | [Channel]: Follow-up | Use Variant 2 |
| [N] | [Channel]: Value add | Share [resource/insight] |
| [N] | [Channel]: Final touch | Permission-based close |

## Notes
- **Best timing**: [Suggested day/time to send or visit]
- **Tone**: [Professional/Casual/Neighborly]
- **Avoid mentioning**: [Topics to avoid — e.g., competitor name, sensitive info]
- **Data freshness**: [When the underlying research was gathered]
```
