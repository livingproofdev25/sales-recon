---
name: property-lookup
description: Full property intelligence — owner name, value, tax assessment, sale history, property details
argument-hint: "Full Address, City, State ZIP"
allowed-tools: Read, Bash
---

Pull full property intelligence for: $ARGUMENTS

Use the Residential Intelligence skill and property-enrichment.md reference for methodology.

## Process

### Step 1: Parse and Normalize Address

Extract from "$ARGUMENTS":
- **Full address**: Street address, city, state, and ZIP code (required)

Normalize the address:
- Ensure format: "[Street], [City], [State] [ZIP]"
- Standardize abbreviations: St -> Street, Ave -> Avenue, Dr -> Drive, etc.
- Ensure state is 2-letter abbreviation

If the address is incomplete (missing city, state, or ZIP), ask the user for the full address.

### Step 2: Property Details

Get property information from RentCast:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/rentcast-api.sh property "<full address>"
```

Extract: owner name, owner type (Individual/Corporate), property type, bedrooms, bathrooms, square footage, lot size, year built, tax assessed value, mailing address, last sale date, last sale price.

### Step 3: Property Value Estimate

Get automated valuation:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/rentcast-api.sh value "<full address>"
```

Extract: estimated value, value range (low/high), price per square foot, confidence level, comparable properties.

### Step 4: Sale History

Pull transaction history:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/rentcast-api.sh sale-history "<full address>"
```

Extract: list of sale transactions with dates, prices, buyer/seller names, transaction types.

### Step 5: Market Context (Optional)

If the ZIP code is available, pull market stats for context:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/rentcast-api.sh market "<zip code>"
```

Extract: median home value, median rent, days on market, price trends.

### Step 6: Output Report

```markdown
# Property Intelligence: [Address]

**Date**: [YYYY-MM-DD]

---

## Owner Information

| Field | Value |
|-------|-------|
| Owner Name | [name] |
| Owner Type | [Individual/Corporate/Trust] |
| Mailing Address | [address — same or different from property] |
| Owner-Occupied | [Yes/No/Unknown] |

## Property Details

| Field | Value |
|-------|-------|
| Property Type | [Single Family/Condo/Townhouse/Multi-Family] |
| Bedrooms | [N] |
| Bathrooms | [N] |
| Square Footage | [N] sqft |
| Lot Size | [N] sqft |
| Year Built | [year] |
| County | [county] |

## Valuation

| Metric | Value |
|--------|-------|
| Estimated Value | $[amount] |
| Value Range | $[low] — $[high] |
| Price/SqFt | $[amount] |
| Tax Assessed Value | $[amount] |
| Assessment vs. Market | [X]% [above/below] market |
| Confidence | [High/Medium/Low] |

### Comparable Properties

| Address | Price | SqFt | Beds | Baths | Distance | Correlation |
|---------|-------|------|------|-------|----------|-------------|
| [address] | $[price] | [sqft] | [beds] | [baths] | [miles] | [X]% |
| [address] | $[price] | [sqft] | [beds] | [baths] | [miles] | [X]% |

## Sale History

| Date | Price | Buyer | Seller | Type |
|------|-------|-------|--------|------|
| [date] | $[price] | [name] | [name] | [Standard/Foreclosure/etc.] |
| [date] | $[price] | [name] | [name] | [type] |

**Total appreciation since last sale**: [X]% ($[amount])
**Average annual appreciation**: [X]%

## Market Context ([ZIP Code])

| Metric | Value |
|--------|-------|
| Median Home Value | $[amount] |
| Median Rent | $[amount]/mo |
| Avg Days on Market | [N] |
| YoY Price Change | [X]% |
| Active Listings | [N] |
| Price-to-Rent Ratio | [X] |

## Lead Assessment

| Factor | Value | Score |
|--------|-------|-------|
| Property Value | $[amount] | [X]/100 |
| Owner-Occupied | [Yes/No] | [X]/100 |
| Equity Position | [High/Medium/Low] | [narrative] |
| Market Strength | [Strong/Moderate/Weak] | [narrative] |

---

**Next steps**:
- `/craft-outreach "[Owner Name]" --style doorknock` — Generate outreach for this homeowner
- `/homeowner-leads "[City]" --type [relevant type]` — Find similar leads in the area
- `/find-permits "[City]"` — Check for related permits in the area
```
