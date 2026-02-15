---
name: Residential Intelligence
description: This skill should be used when the user asks to "find homeowner leads", "pull building permits", "look up property", "find permit data", "search permits", "property lookup", "homeowner contacts", or needs guidance on residential lead generation from building permits and property data.
version: 3.0.0
---

# Residential Lead Intelligence Methodology

Framework for finding homeowner leads through building permits and enriching with property/owner data. Uses free city open data portals (Socrata) and RentCast for property enrichment.

## Data Sources

1. **Socrata Open Data** (FREE) — Building permits from 6 city portals. Script: `socrata-permits-api.sh`
2. **RentCast** (free tier) — Property details, owner names, tax assessments, sale history. Script: `rentcast-api.sh`

## Pipeline

### 1. Pull Permits
- `socrata-permits-api.sh search <city> --type <project> --days <N> --limit <N>`
- Filter by: city, project type (roofing, hvac, plumbing, etc.), date range, minimum value
- Returns: addresses, work descriptions, permit values, dates

### 2. Enrich Property
For each permit address:
- `rentcast-api.sh property "<address>"` → owner name, property type, beds/baths, sqft, year built
- `rentcast-api.sh value "<address>"` → estimated value, price range
- `rentcast-api.sh sale-history "<address>"` → last sale date/price

### 3. Score
- **Property value tier**: Higher value = higher revenue potential
- **Permit recency**: Recent permits = active project = immediate need
- **Project value**: Higher permit value = bigger project
- **Owner-occupied vs investor**: Owner-occupied = decision maker on site

### 4. Output
Ranked homeowner lead list with owner contact info, property details, permit info, and opportunity score.

## Supported Cities

See `references/permit-cities.md` for full endpoint details and field mappings.

- Austin, TX
- San Antonio, TX
- New York City, NY
- Boston, MA
- Detroit, MI
- Washington, DC

## Project Types

Common permit categories to search:
roofing, hvac, plumbing, electrical, remodel, addition, foundation, siding, windows, solar, pool, fence, deck, garage, demolition, commercial, new construction, renovation
