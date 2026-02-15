# Property Enrichment via RentCast

## API Endpoints

### Property Details
```
rentcast-api.sh property "<full address>"
```
Returns: owner names, property type, bedrooms, bathrooms, sqft, lot size, year built, tax assessed value, mailing address.

### Property Value Estimate
```
rentcast-api.sh value "<full address>"
```
Returns: estimated value, value range (low/high), price per sqft, comparable properties.

### Sale History
```
rentcast-api.sh sale-history "<full address>"
```
Returns: list of sale transactions with dates, prices, and buyer/seller info.

### Market Stats
```
rentcast-api.sh market "<zip code>"
```
Returns: median home value, median rent, price trends, inventory levels.

## Enrichment Strategy

1. **Always start with property lookup** — confirms address validity and gets owner name
2. **Add value estimate** — determines revenue potential tier
3. **Sale history only for high-value leads** — conserves API calls
4. **Cache results** — property data doesn't change often, reuse within 30 days

## Scoring Residential Leads

| Factor | Weight | Scoring |
|--------|--------|---------|
| Property value | 30% | >$500K = 100, $300-500K = 75, $150-300K = 50, <$150K = 25 |
| Permit recency | 25% | <30 days = 100, 30-60 = 80, 60-90 = 60, >90 = 40 |
| Project value | 25% | >$20K = 100, $10-20K = 75, $5-10K = 50, <$5K = 25 |
| Owner-occupied | 20% | Owner-occupied = 100, Investor/rental = 50, Unknown = 60 |

**Lead Quality:**
- 80+: Priority lead — immediate outreach
- 60-79: Good lead — include in campaign
- 40-59: Fair lead — follow up if capacity allows
- <40: Low priority — skip unless batch is thin
