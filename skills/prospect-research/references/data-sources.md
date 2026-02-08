# Data Sources Reference

Complete API documentation and rate limits for prospect research.

## Hunter.io API

### Authentication

All requests require API key as query parameter:
```
?api_key=YOUR_API_KEY
```

### Endpoints

#### Email Finder
Find email address for a person at a company.

```
GET https://api.hunter.io/v2/email-finder
```

Parameters:
- `domain` (required): Company domain (e.g., "acme.com")
- `first_name` (required): Person's first name
- `last_name` (required): Person's last name
- `api_key` (required): Your API key

Response:
```json
{
  "data": {
    "first_name": "John",
    "last_name": "Smith",
    "email": "john.smith@acme.com",
    "score": 95,
    "domain": "acme.com",
    "position": "VP Engineering",
    "twitter": "@johnsmith",
    "linkedin_url": "linkedin.com/in/johnsmith",
    "phone_number": "+1-555-123-4567",
    "company": "Acme Corp"
  }
}
```

#### Domain Search
Find all email addresses associated with a domain.

```
GET https://api.hunter.io/v2/domain-search
```

Parameters:
- `domain` (required): Company domain
- `limit` (optional): Max results (default 10, max 100)
- `offset` (optional): Pagination offset
- `type` (optional): "personal" or "generic"
- `seniority` (optional): "junior", "senior", "executive"
- `department` (optional): "executive", "it", "finance", "management", "sales", "legal", "support", "hr", "marketing", "communication"

Response:
```json
{
  "data": {
    "domain": "acme.com",
    "disposable": false,
    "webmail": false,
    "pattern": "{first}.{last}",
    "organization": "Acme Corp",
    "emails": [
      {
        "value": "john.smith@acme.com",
        "type": "personal",
        "confidence": 95,
        "first_name": "John",
        "last_name": "Smith",
        "position": "VP Engineering",
        "seniority": "executive",
        "department": "it"
      }
    ]
  }
}
```

#### Email Verifier
Verify if an email address is deliverable.

```
GET https://api.hunter.io/v2/email-verifier
```

Parameters:
- `email` (required): Email to verify

Response:
```json
{
  "data": {
    "email": "john@acme.com",
    "result": "deliverable",
    "score": 95,
    "regexp": true,
    "gibberish": false,
    "disposable": false,
    "webmail": false,
    "mx_records": true,
    "smtp_server": true,
    "smtp_check": true,
    "accept_all": false,
    "block": false
  }
}
```

### Rate Limits

| Plan | Requests/Month | Requests/Second |
|------|----------------|-----------------|
| Free | 25 | 1 |
| Starter | 500 | 10 |
| Growth | 5,000 | 20 |
| Business | 30,000 | 30 |

Best practices:
- Cache results to avoid duplicate requests
- Batch requests when possible
- Use exponential backoff on rate limit errors

---

## Google Maps/Places API

### Authentication

Pass API key as query parameter:
```
?key=YOUR_API_KEY
```

### Endpoints

#### Find Place
Search for a place by name.

```
GET https://maps.googleapis.com/maps/api/place/findplacefromtext/json
```

Parameters:
- `input` (required): Search query
- `inputtype` (required): "textquery" or "phonenumber"
- `fields` (required): Comma-separated fields to return
- `locationbias` (optional): Prefer results near location

Fields available:
- Basic: `formatted_address`, `geometry`, `icon`, `name`, `opening_hours`, `photos`, `place_id`, `types`
- Contact: `formatted_phone_number`, `international_phone_number`, `opening_hours`, `website`
- Atmosphere: `price_level`, `rating`, `reviews`, `user_ratings_total`

Response:
```json
{
  "candidates": [
    {
      "formatted_address": "123 Main St, San Francisco, CA 94102",
      "name": "Acme Corp",
      "place_id": "ChIJ...",
      "formatted_phone_number": "(555) 123-4567",
      "website": "https://acme.com"
    }
  ],
  "status": "OK"
}
```

#### Place Details
Get detailed information about a place.

```
GET https://maps.googleapis.com/maps/api/place/details/json
```

Parameters:
- `place_id` (required): From findplace or textsearch
- `fields` (required): Comma-separated fields

Response includes all requested fields plus reviews:
```json
{
  "result": {
    "name": "Acme Corp",
    "formatted_address": "123 Main St, San Francisco, CA 94102",
    "formatted_phone_number": "(555) 123-4567",
    "website": "https://acme.com",
    "reviews": [
      {
        "rating": 5,
        "text": "Great company to work with!",
        "time": 1704067200
      }
    ]
  }
}
```

### Rate Limits & Pricing

| Request Type | Price per 1,000 |
|--------------|-----------------|
| Find Place | $17.00 |
| Place Details (Basic) | $17.00 |
| Place Details (Contact) | $3.00 |
| Place Details (Atmosphere) | $5.00 |

Monthly free tier: $200 credit (~11,700 basic requests)

Best practices:
- Request only needed fields (reduces cost)
- Cache place_id for future lookups
- Use session tokens for autocomplete workflows

---

## SerpAPI

### Authentication

Pass API key as query parameter:
```
?api_key=YOUR_API_KEY
```

### Endpoints

#### Google Search
General web search with structured results.

```
GET https://serpapi.com/search
```

Parameters:
- `engine` (required): "google"
- `q` (required): Search query
- `location` (optional): Location for localized results
- `num` (optional): Results per page (max 100)
- `start` (optional): Pagination offset
- `tbs` (optional): Time filter ("qdr:d" day, "qdr:w" week, "qdr:m" month)

LinkedIn Profile Search:
```
q=John+Smith+VP+Engineering+site:linkedin.com
```

Company News Search:
```
q="Acme+Corp"+news
tbs=qdr:m
```

Response:
```json
{
  "organic_results": [
    {
      "position": 1,
      "title": "John Smith - VP Engineering - Acme Corp | LinkedIn",
      "link": "https://linkedin.com/in/johnsmith",
      "snippet": "VP of Engineering at Acme Corp. San Francisco Bay Area.",
      "displayed_link": "linkedin.com > johnsmith"
    }
  ],
  "search_metadata": {
    "total_results": 1520000
  }
}
```

#### Google Maps Search
Search Google Maps for businesses.

```
GET https://serpapi.com/search
?engine=google_maps
&q=Acme+Corp+San+Francisco
```

Response:
```json
{
  "local_results": [
    {
      "title": "Acme Corp",
      "place_id": "ChIJ...",
      "address": "123 Main St, San Francisco, CA",
      "phone": "(555) 123-4567",
      "website": "https://acme.com",
      "rating": 4.5,
      "reviews": 127,
      "type": "Software company"
    }
  ]
}
```

### Rate Limits

| Plan | Searches/Month | Price/Search |
|------|----------------|--------------|
| Free | 100 | - |
| Developer | 5,000 | $0.01 |
| Production | 15,000 | $0.008 |
| Business | 100,000+ | $0.004 |

Best practices:
- Use specific queries (site:linkedin.com) for targeted results
- Limit to needed result count
- Cache results for repeat queries

---

## Combining Sources

### Optimal Query Order

1. **Hunter.io first** - Highest confidence for email data
2. **Google Maps second** - Verify business existence and location
3. **SerpAPI third** - Fill in social profiles and news

### Cross-Validation Pattern

```python
# Example: Verify a person's employment

# 1. Hunter.io says John is VP at Acme
hunter_result = hunter_email_finder("acme.com", "John", "Smith")

# 2. SerpAPI LinkedIn search confirms
serp_result = serpapi_search("John Smith VP Engineering site:linkedin.com")

# 3. Cross-check titles match
if "VP" in hunter_result.position and "VP" in serp_result.title:
    confidence = "high"
else:
    confidence = "verify_manually"
```

### Rate Limit Coordination

When processing batches:
1. Implement per-API rate limiters
2. Parallelize across different APIs (Hunter + SerpAPI simultaneously)
3. Add exponential backoff for any 429 errors
4. Log API usage for cost tracking
