# Data Sources Reference

Comprehensive reference for all 8 API data sources used in the sales-recon pipeline. Each section covers authentication, endpoints, example requests/responses, rate limits, and best practices.

---

## 1. Hunter.io

Email discovery, domain search, and email verification.

### Authentication
- **Method**: API key as query parameter (`api_key=<key>`)
- **Key location**: `HUNTER_API_KEY` env var or `hunter_api_key` in `~/.claude/sales-recon.local.md`
- **Base URL**: `https://api.hunter.io/v2`

### Endpoints

#### Email Finder
Find the most likely email address for a person at a company.

```bash
hunter-api.sh find-email --domain stripe.com --first Patrick --last Collison
```

**API call**: `GET /email-finder?domain=stripe.com&first_name=Patrick&last_name=Collison&api_key=<key>`

**Response**:
```json
{
  "data": {
    "first_name": "Patrick",
    "last_name": "Collison",
    "email": "patrick@stripe.com",
    "score": 91,
    "domain": "stripe.com",
    "position": "CEO",
    "company": "Stripe",
    "sources": [
      {
        "domain": "techcrunch.com",
        "uri": "https://techcrunch.com/...",
        "extracted_on": "2024-01-15"
      }
    ]
  },
  "meta": {
    "params": {
      "first_name": "Patrick",
      "last_name": "Collison",
      "domain": "stripe.com"
    }
  }
}
```

#### Domain Search
List all email addresses found for a domain.

```bash
hunter-api.sh domain-search stripe.com --limit 5 --seniority executive
```

**API call**: `GET /domain-search?domain=stripe.com&limit=5&seniority=executive&api_key=<key>`

**Parameters**:
- `--limit N` — Max results (default: 10)
- `--seniority X` — Filter: `junior`, `senior`, `executive`
- `--department X` — Filter: `executive`, `it`, `finance`, `management`, `sales`, `legal`, `support`, `hr`, `marketing`, `communication`, `education`, `design`, `health`, `operations`

**Response**:
```json
{
  "data": {
    "domain": "stripe.com",
    "disposable": false,
    "webmail": false,
    "accept_all": false,
    "pattern": "{first}",
    "organization": "Stripe",
    "emails": [
      {
        "value": "patrick@stripe.com",
        "type": "personal",
        "confidence": 91,
        "first_name": "Patrick",
        "last_name": "Collison",
        "position": "CEO",
        "seniority": "senior",
        "department": "executive"
      }
    ]
  },
  "meta": {
    "results": 1,
    "limit": 5,
    "offset": 0
  }
}
```

#### Email Verifier
Verify deliverability of an email address.

```bash
hunter-api.sh verify patrick@stripe.com
```

**API call**: `GET /email-verifier?email=patrick@stripe.com&api_key=<key>`

**Response**:
```json
{
  "data": {
    "email": "patrick@stripe.com",
    "result": "deliverable",
    "score": 95,
    "status": "valid",
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

#### Account Info
Check remaining quota and plan details.

```bash
hunter-api.sh account-info
```

**API call**: `GET /account?api_key=<key>`

### Rate Limits

| Tier | Searches/mo | Verifications/mo | Requests/sec |
|------|-------------|------------------|--------------|
| Free | 25 | 50 | 10 |
| Starter | 500 | 1,000 | 15 |
| Growth | 5,000 | 10,000 | 20 |

### Best Practices
- Use `domain-search` first to discover the email pattern (e.g., `{first}@company.com`)
- Once you know the pattern, you can guess emails without using API calls
- Only verify emails that are critical for outreach (scores 50-80)
- Emails with score >80 are safe to use directly
- Cache all results — emails rarely change

---

## 2. Apollo.io

Company firmographics, contact data, org charts, and people search.

### Authentication
- **Method**: API key in JSON request body (`"api_key": "<key>"`)
- **Key location**: `APOLLO_API_KEY` env var or `apollo_api_key` in `~/.claude/sales-recon.local.md`
- **Base URL**: `https://api.apollo.io/v1`

### Endpoints

#### Company Enrich
Get company firmographics by domain.

```bash
apollo-api.sh company-enrich --domain stripe.com
```

**API call**: `POST /organizations/enrich` with `{"api_key": "<key>", "domain": "stripe.com"}`

**Response**:
```json
{
  "organization": {
    "id": "5e66b6XXXXXXXXXX",
    "name": "Stripe",
    "website_url": "https://stripe.com",
    "domain": "stripe.com",
    "estimated_num_employees": 8000,
    "industry": "Internet Software & Services",
    "keywords": ["payments", "fintech", "api", "infrastructure"],
    "founded_year": 2010,
    "linkedin_url": "https://linkedin.com/company/stripe",
    "phone": "+1-888-926-2289",
    "annual_revenue": 14000000000,
    "total_funding": 8700000000,
    "latest_funding_stage": "Series I",
    "latest_funding_round_date": "2023-03-15",
    "technologies": ["python", "ruby", "react", "aws", "kubernetes"],
    "city": "San Francisco",
    "state": "California",
    "country": "United States",
    "logo_url": "https://..."
  }
}
```

#### People Search
Search for people by keywords, organization, or title.

```bash
apollo-api.sh people-search --org "Stripe" --title "CTO" --limit 5
```

**API call**: `POST /mixed_people/search` with body:
```json
{
  "api_key": "<key>",
  "q_organization_name": "Stripe",
  "person_titles": ["CTO"],
  "per_page": 5
}
```

**Response**:
```json
{
  "people": [
    {
      "id": "abc123",
      "first_name": "David",
      "last_name": "Singleton",
      "name": "David Singleton",
      "title": "CTO",
      "email": "david@stripe.com",
      "email_status": "verified",
      "phone_numbers": [
        {"raw_number": "+1-555-123-4567", "type": "mobile"}
      ],
      "organization": {
        "name": "Stripe",
        "domain": "stripe.com"
      },
      "seniority": "c_suite",
      "departments": ["engineering"],
      "linkedin_url": "https://linkedin.com/in/davidsingleton"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 5,
    "total_entries": 3
  }
}
```

#### People Enrich (Match)
Enrich a person's profile by email address.

```bash
apollo-api.sh people-enrich --email patrick@stripe.com
```

**API call**: `POST /people/match` with `{"api_key": "<key>", "email": "patrick@stripe.com"}`

**Response**:
```json
{
  "person": {
    "id": "xyz789",
    "first_name": "Patrick",
    "last_name": "Collison",
    "title": "CEO & Co-founder",
    "email": "patrick@stripe.com",
    "organization": {
      "name": "Stripe",
      "domain": "stripe.com",
      "estimated_num_employees": 8000
    },
    "phone_numbers": [],
    "linkedin_url": "https://linkedin.com/in/patrickcollison",
    "city": "San Francisco",
    "state": "California",
    "employment_history": [
      {
        "organization_name": "Stripe",
        "title": "CEO & Co-founder",
        "start_date": "2010-01-01",
        "current": true
      }
    ]
  }
}
```

#### Org Chart
Get leadership and decision makers for a company.

```bash
apollo-api.sh org-chart --domain stripe.com --limit 10
```

**API call**: `POST /mixed_people/search` with body:
```json
{
  "api_key": "<key>",
  "q_organization_domains": "stripe.com",
  "person_seniorities": ["owner", "founder", "c_suite", "partner", "vp", "head", "director"],
  "per_page": 10
}
```

Returns the same `people` array structure as people-search, filtered to senior roles.

### Rate Limits

| Resource | Limit | Notes |
|----------|-------|-------|
| Credits/month | 900 (free) | 1 credit per person or company enrichment |
| API calls/min | 100 | Across all endpoints |
| Org chart | 1 credit per person returned | Use `--limit` to control cost |

### Best Practices
- `company-enrich` is the best first call — costs 1 credit, returns 30+ fields
- Use `org-chart` to get multiple contacts in one call (1 credit per person)
- Avoid `people-search` with broad queries — it burns credits fast
- `people-enrich` by email is the most reliable person lookup
- Cache company data for at least 30 days — firmographics rarely change

---

## 3. SerpAPI

Google search, news search, jobs search, and LinkedIn profile/company lookups.

### Authentication
- **Method**: API key as query parameter (`api_key=<key>`)
- **Key location**: `SERPAPI_KEY` env var or `serp_api_key` in `~/.claude/sales-recon.local.md`
- **Base URL**: `https://serpapi.com/search`

### Endpoints

#### Google Web Search
General web search with time filtering.

```bash
serp-api.sh search "Stripe funding 2024" --num 5 --time m
```

**API call**: `GET /search?engine=google&q=Stripe+funding+2024&num=5&tbs=qdr:m&api_key=<key>`

**Parameters**:
- `--num N` — Number of results (default: 10)
- `--time X` — Time filter: `d` (day), `w` (week), `m` (month), `y` (year)

**Response** (truncated):
```json
{
  "search_metadata": {
    "id": "search_abc123",
    "status": "Success",
    "total_time_taken": 1.23
  },
  "organic_results": [
    {
      "position": 1,
      "title": "Stripe raises $6.5B at $50B valuation",
      "link": "https://techcrunch.com/...",
      "snippet": "Stripe has raised a $6.5 billion round...",
      "date": "2024-02-15"
    }
  ],
  "search_information": {
    "total_results": 1250000
  }
}
```

#### Google News Search
Search recent news articles.

```bash
serp-api.sh news "Stripe partnership" --num 5
```

**API call**: `GET /search?engine=google_news&q=Stripe+partnership&num=5&api_key=<key>`

**Response**:
```json
{
  "news_results": [
    {
      "position": 1,
      "title": "Stripe Partners with Major Bank",
      "link": "https://...",
      "source": {
        "name": "Bloomberg"
      },
      "date": "2 days ago",
      "snippet": "Stripe announced a new partnership..."
    }
  ]
}
```

#### Google Jobs Search
Search job postings (hiring signals).

```bash
serp-api.sh jobs "Stripe" --location "San Francisco"
```

**API call**: `GET /search?engine=google_jobs&q=Stripe&location=San+Francisco&api_key=<key>`

**Response**:
```json
{
  "jobs_results": [
    {
      "title": "Senior Backend Engineer",
      "company_name": "Stripe",
      "location": "San Francisco, CA",
      "via": "via LinkedIn",
      "description": "We're looking for...",
      "detected_extensions": {
        "posted_at": "3 days ago",
        "salary": "$180K-$250K"
      },
      "job_highlights": [
        {
          "title": "Qualifications",
          "items": ["5+ years experience", "Python or Go"]
        }
      ]
    }
  ]
}
```

#### LinkedIn Profile Search
Find a person's LinkedIn profile via Google.

```bash
serp-api.sh linkedin-profile "Patrick Collison" "Stripe"
```

**API call**: `GET /search?engine=google&q=site:linkedin.com/in/+Patrick+Collison+Stripe&num=5&api_key=<key>`

#### LinkedIn Company Search
Find a company's LinkedIn page via Google.

```bash
serp-api.sh linkedin-company "Stripe"
```

**API call**: `GET /search?engine=google&q=site:linkedin.com/company/+Stripe&num=5&api_key=<key>`

### Rate Limits

| Tier | Searches/mo | Cost/search |
|------|-------------|------------|
| Free | 100 | Free |
| Developer | 5,000 | $0.01 |
| Business | 15,000 | $0.0075 |

### Best Practices
- Combine intent signal searches: run news, jobs, and web search in sequence per company
- Use `--time m` for recent signals (last month) to reduce noise
- LinkedIn searches cost 1 SerpAPI credit each — use sparingly
- Cache results for at least 7 days
- Prefer specific queries: `"Stripe hiring CTO"` over `"Stripe jobs"`

---

## 4. Google Places

Business verification, address/phone confirmation, ratings, and reviews.

### Authentication
- **Method**: API key as query parameter (`key=<key>`)
- **Key location**: `GOOGLE_PLACES_API_KEY` env var or `google_places_api_key` in `~/.claude/sales-recon.local.md`
- **Base URL**: `https://maps.googleapis.com/maps/api/place`

### Endpoints

#### Find Place
Find a business by text query. Returns the single best match.

```bash
google-places-api.sh find "Stripe San Francisco"
```

**API call**: `GET /findplacefromtext/json?input=Stripe+San+Francisco&inputtype=textquery&fields=name,formatted_address,formatted_phone_number,website,place_id,rating,user_ratings_total,business_status,types&key=<key>`

**Response**:
```json
{
  "candidates": [
    {
      "name": "Stripe",
      "formatted_address": "510 Townsend St, San Francisco, CA 94103",
      "formatted_phone_number": "(888) 926-2289",
      "website": "https://stripe.com",
      "place_id": "ChIJ_____XXXXXX",
      "rating": 4.2,
      "user_ratings_total": 156,
      "business_status": "OPERATIONAL",
      "types": ["point_of_interest", "establishment"]
    }
  ],
  "status": "OK"
}
```

#### Place Details
Get detailed information for a specific place by place_id.

```bash
google-places-api.sh details "ChIJ_____XXXXXX"
```

**API call**: `GET /details/json?place_id=ChIJ_____XXXXXX&fields=name,formatted_address,...&key=<key>`

**Default fields**: `name`, `formatted_address`, `formatted_phone_number`, `international_phone_number`, `website`, `url`, `rating`, `reviews`, `user_ratings_total`, `types`, `opening_hours`, `business_status`

**Response**:
```json
{
  "result": {
    "name": "Stripe",
    "formatted_address": "510 Townsend St, San Francisco, CA 94103",
    "formatted_phone_number": "(888) 926-2289",
    "international_phone_number": "+1 888-926-2289",
    "website": "https://stripe.com",
    "url": "https://maps.google.com/?cid=...",
    "rating": 4.2,
    "reviews": [
      {
        "author_name": "John Smith",
        "rating": 5,
        "text": "Great company to work with...",
        "time": 1700000000
      }
    ],
    "user_ratings_total": 156,
    "opening_hours": {
      "open_now": true,
      "weekday_text": ["Monday: 9:00 AM - 6:00 PM", "..."]
    },
    "business_status": "OPERATIONAL"
  },
  "status": "OK"
}
```

#### Text Search
Search for multiple places matching a text query.

```bash
google-places-api.sh text-search "roofing companies Austin TX" --location "30.2672,-97.7431" --radius 50000
```

**API call**: `GET /textsearch/json?query=roofing+companies+Austin+TX&location=30.2672,-97.7431&radius=50000&key=<key>`

**Parameters**:
- `--location lat,lng` — Center point for search
- `--radius meters` — Search radius (max 50,000)

**Response**:
```json
{
  "results": [
    {
      "name": "Austin Roofing Co",
      "formatted_address": "123 Main St, Austin, TX 78701",
      "rating": 4.8,
      "user_ratings_total": 312,
      "place_id": "ChIJ_____YYYYYY",
      "business_status": "OPERATIONAL",
      "types": ["roofing_contractor", "general_contractor"]
    }
  ],
  "status": "OK"
}
```

### Rate Limits

| Request Type | Cost | Free Tier ($200/mo credit) |
|-------------|------|---------------------------|
| Find Place | $0.017 | ~11,700 requests |
| Place Details (basic) | $0.017 | ~11,700 requests |
| Place Details (contact) | $0.003 | ~66,600 requests |
| Text Search | $0.032 | ~6,250 requests |

### Best Practices
- Use `find` for single business verification (cheapest call)
- Only call `details` when you need reviews or opening hours
- Use `text-search` for competitive landscape analysis
- The `place_id` is stable — cache and reuse for future detail lookups
- Combine with Apollo data: Google Places confirms address/phone, Apollo adds contacts

---

## 5. GitHub

Organization data, repositories, tech stack detection, and contributor analysis.

### Authentication
- **Method**: Bearer token in Authorization header (optional)
- **Key location**: `GITHUB_TOKEN` env var or `github_token` in `~/.claude/sales-recon.local.md`
- **Base URL**: `https://api.github.com`
- **Note**: Works without auth at 60 req/hr; with token: 5,000 req/hr

### Endpoints

#### Organization Info
Get organization profile data.

```bash
github-api.sh org stripe
```

**API call**: `GET /orgs/stripe`

**Response**:
```json
{
  "login": "stripe",
  "name": "Stripe",
  "description": "Financial infrastructure for the internet.",
  "blog": "https://stripe.com",
  "location": "San Francisco, CA",
  "email": "info@stripe.com",
  "public_repos": 182,
  "public_members": 45,
  "followers": 2800,
  "created_at": "2011-06-30T17:35:11Z",
  "type": "Organization"
}
```

#### Repositories
List organization repositories with sorting.

```bash
github-api.sh repos stripe --limit 5 --sort stars
```

**API call**: `GET /orgs/stripe/repos?per_page=5&sort=created&direction=desc` (post-processed for stars sort)

**Parameters**:
- `--limit N` — Max results (default: 30)
- `--sort X` — Sort by: `stars`, `updated`, `pushed`

**Response**:
```json
[
  {
    "name": "stripe-node",
    "full_name": "stripe/stripe-node",
    "description": "Node.js library for the Stripe API.",
    "stargazers_count": 3400,
    "forks_count": 450,
    "language": "TypeScript",
    "updated_at": "2024-02-10T15:30:00Z",
    "topics": ["stripe", "payments", "nodejs"]
  }
]
```

#### Languages (Tech Stack)
Aggregate programming languages across an org's top 10 repos.

```bash
github-api.sh languages stripe
```

**Response**:
```json
{
  "organization": "stripe",
  "repos_analyzed": 10,
  "languages": {
    "Ruby": 15234567,
    "TypeScript": 12345678,
    "Python": 8901234,
    "Go": 5678901,
    "Java": 3456789,
    "JavaScript": 2345678,
    "Shell": 123456
  },
  "primary_language": "Ruby"
}
```

#### Contributors
List contributors for a specific repository.

```bash
github-api.sh contributors stripe/stripe-node --limit 10
```

**API call**: `GET /repos/stripe/stripe-node/contributors?per_page=10`

#### Search Organization
Find a GitHub org by company name.

```bash
github-api.sh search-org "Stripe"
```

**API call**: `GET /search/users?q=Stripe+type:org`

### Rate Limits

| Auth Level | Requests/hour | Cost |
|-----------|---------------|------|
| Unauthenticated | 60 | Free |
| Authenticated (token) | 5,000 | Free |

### Best Practices
- Always use a token for 83x higher rate limit
- `languages` aggregates across top 10 repos — gives a reliable tech stack picture
- Use `search-org` first if you don't know the GitHub org name
- Star count and contributor count indicate team size and community
- Check `updated_at` on repos to see if the company is actively developing

---

## 6. SEC EDGAR

Public company financial filings, revenue data, and earnings. Free, no API key needed.

### Authentication
- **Method**: User-Agent header (required, but no key needed)
- **User-Agent**: `SalesRecon/3.0 (dev@xai3x.com)`
- **Base URLs**:
  - Full-text search: `https://efts.sec.gov/LATEST/search-index`
  - Submissions: `https://data.sec.gov/submissions/`
  - XBRL facts: `https://data.sec.gov/api/xbrl/`

### Endpoints

#### Company Search
Search for a company by name to find its CIK number.

```bash
sec-edgar-api.sh search "Stripe"
```

**API call**: `GET https://efts.sec.gov/LATEST/search-index?q=Stripe&forms=10-K`

**Response**:
```json
{
  "hits": {
    "hits": [
      {
        "_source": {
          "entity_name": "Stripe Inc",
          "entity_id": "0001234567",
          "file_date": "2024-03-15",
          "form_type": "10-K"
        }
      }
    ],
    "total": {"value": 5}
  }
}
```

#### Company Filings
Get filings by CIK number with optional type and limit filters.

```bash
sec-edgar-api.sh filings 320193 --type 10-K --limit 5
```

**API call**: `GET https://data.sec.gov/submissions/CIK0000320193.json`

**Parameters**:
- `--type X` — Filing type: `10-K` (annual), `10-Q` (quarterly), `8-K` (events), `DEF 14A` (proxy)
- `--limit N` — Max results

**Response** (post-filtered):
```json
{
  "cik": "320193",
  "entityName": "Apple Inc",
  "filings": [
    {
      "form": "10-K",
      "filingDate": "2024-11-01",
      "accessionNumber": "0000320193-24-000123",
      "primaryDocument": "aapl-20240928.htm",
      "description": "Annual Report"
    }
  ],
  "total_filtered": 5
}
```

#### Company Facts
Get all XBRL financial facts for a company.

```bash
sec-edgar-api.sh company-facts 320193
```

**API call**: `GET https://data.sec.gov/api/xbrl/companyfacts/CIK0000320193.json`

**Response** (truncated):
```json
{
  "cik": 320193,
  "entityName": "Apple Inc",
  "facts": {
    "us-gaap": {
      "Revenues": {
        "label": "Revenues",
        "units": {
          "USD": [
            {
              "val": 394328000000,
              "end": "2022-09-24",
              "form": "10-K",
              "filed": "2022-10-28"
            }
          ]
        }
      },
      "NetIncomeLoss": {
        "label": "Net Income (Loss)",
        "units": {
          "USD": [
            {
              "val": 99803000000,
              "end": "2022-09-24",
              "form": "10-K"
            }
          ]
        }
      }
    }
  }
}
```

#### Company Concept
Get a specific financial metric over time.

```bash
sec-edgar-api.sh company-concept 320193 Revenues
```

**API call**: `GET https://data.sec.gov/api/xbrl/companyconcept/CIK0000320193/us-gaap/Revenues.json`

**Common tags**: `Revenues`, `NetIncomeLoss`, `Assets`, `StockholdersEquity`, `EarningsPerShareBasic`, `OperatingIncomeLoss`, `CostOfGoodsAndServicesSold`, `ResearchAndDevelopmentExpense`

**Response**:
```json
{
  "cik": 320193,
  "taxonomy": "us-gaap",
  "tag": "Revenues",
  "label": "Revenues",
  "entityName": "Apple Inc",
  "units": {
    "USD": [
      {"val": 394328000000, "end": "2022-09-24", "form": "10-K", "fy": 2022},
      {"val": 383285000000, "end": "2023-09-30", "form": "10-K", "fy": 2023},
      {"val": 391035000000, "end": "2024-09-28", "form": "10-K", "fy": 2024}
    ]
  }
}
```

### Rate Limits

| Limit | Value |
|-------|-------|
| Requests/sec | 10 per IP |
| Monthly | Unlimited |
| Cost | Free |

### Best Practices
- Use `search` to find CIK, then `company-concept` for specific metrics
- `company-facts` returns everything but is a large response — use `company-concept` when you know the tag
- Only works for public companies — skip for private companies
- CIK numbers are auto-padded to 10 digits by the script
- Revenue trends over 3-5 years reveal growth trajectory
- Compare `Revenues` and `NetIncomeLoss` for profitability analysis

---

## 7. Socrata Open Data (Building Permits)

Free city open data portals for building permit records. No API key required.

### Authentication
- **Method**: None (public data)
- **Query language**: SoQL (Socrata Query Language) via URL parameters
- **Endpoints**: See `skills/residential-intelligence/references/permit-cities.md`

### Endpoints

#### Permit Search
Search building permits for a supported city.

```bash
socrata-permits-api.sh search austin --type roofing --days 30 --limit 20 --min-value 5000
```

**API call**: `GET https://data.austintexas.gov/resource/3syk-w9eu.json?$limit=20&$order=issue_date%20DESC&$where=issue_date > '2024-01-15T00:00:00' AND upper(permit_type_definition) LIKE '%ROOFING%' AND original_value > 5000`

**Parameters**:
- `<city>` — Required: `austin`, `san-antonio`, `nyc`, `boston`, `detroit`, `dc`
- `--type X` — Project type filter (case-insensitive text match)
- `--days N` — Lookback period in days (default: 90)
- `--limit N` — Max results (default: 50)
- `--min-value N` — Minimum permit value in dollars

**Response** (Austin example):
```json
[
  {
    "permit_num": "2024-012345",
    "permit_type_desc": "Residential - Roofing",
    "work_description": "Reroof entire residence, tear off existing shingles",
    "original_address1": "1234 Oak Hill Dr",
    "original_city": "Austin",
    "original_zip": "78749",
    "issued_date": "2024-02-01T00:00:00.000",
    "status_current": "Issued",
    "original_value": "18500"
  }
]
```

#### List Supported Cities

```bash
socrata-permits-api.sh cities
```

#### List Project Types

```bash
socrata-permits-api.sh project-types
```

### SoQL Query Syntax

The script builds SoQL queries internally. For reference, key SoQL operators:

| Operator | Example | Description |
|----------|---------|-------------|
| `>`, `<`, `=` | `issue_date > '2024-01-01'` | Comparison |
| `LIKE` | `upper(type) LIKE '%ROOFING%'` | Pattern match |
| `AND`, `OR` | Combine conditions | Logical operators |
| `$limit` | `$limit=50` | Max rows |
| `$order` | `$order=issue_date DESC` | Sort order |
| `$where` | `$where=<conditions>` | Filter clause |

### Rate Limits

| Limit | Value |
|-------|-------|
| Unauthenticated | 1,000 req/hour |
| With app token | 10,000 req/hour |
| Cost | Free |

### Best Practices
- Start with a small `--days` window (30) and expand if needed
- Use `--min-value` to filter out trivial permits (e.g., <$1,000)
- Field names differ between cities — the script normalizes query parameters
- Raw response field names are city-specific (see permit-cities.md for mappings)
- Large `--limit` values (>1000) can be slow — paginate for bulk pulls
- Data freshness varies: Austin is near-real-time, others may lag 1-4 weeks

---

## 8. RentCast

Property details, automated valuations, sale history, and market statistics.

### Authentication
- **Method**: `X-Api-Key` header
- **Key location**: `RENTCAST_API_KEY` env var or `rentcast_api_key` in `~/.claude/sales-recon.local.md`
- **Base URL**: `https://api.rentcast.io/v1`

### Endpoints

#### Property Details
Get property information by address.

```bash
rentcast-api.sh property "1234 Oak Hill Dr, Austin, TX 78749"
```

**API call**: `GET /properties?address=1234+Oak+Hill+Dr%2C+Austin%2C+TX+78749` with `X-Api-Key` header

**Response**:
```json
[
  {
    "id": "prop_abc123",
    "formattedAddress": "1234 Oak Hill Dr, Austin, TX 78749",
    "addressLine1": "1234 Oak Hill Dr",
    "city": "Austin",
    "state": "TX",
    "zipCode": "78749",
    "county": "Travis",
    "propertyType": "Single Family",
    "bedrooms": 4,
    "bathrooms": 3,
    "squareFootage": 2450,
    "lotSize": 8500,
    "yearBuilt": 2005,
    "ownerName": "John Smith",
    "ownerType": "Individual",
    "mailingAddress": "1234 Oak Hill Dr, Austin, TX 78749",
    "taxAssessedValue": 485000,
    "lastSaleDate": "2019-06-15",
    "lastSalePrice": 375000
  }
]
```

#### Property Value (AVM)
Get automated valuation model estimate.

```bash
rentcast-api.sh value "1234 Oak Hill Dr, Austin, TX 78749"
```

**API call**: `GET /avm/value?address=1234+Oak+Hill+Dr%2C+Austin%2C+TX+78749` with `X-Api-Key` header

**Response**:
```json
{
  "price": 525000,
  "priceRangeLow": 490000,
  "priceRangeHigh": 560000,
  "pricePerSquareFoot": 214.28,
  "confidence": "high",
  "comparables": [
    {
      "formattedAddress": "1240 Oak Hill Dr, Austin, TX 78749",
      "price": 510000,
      "squareFootage": 2380,
      "bedrooms": 4,
      "bathrooms": 2.5,
      "distance": 0.1,
      "correlation": 0.95
    }
  ]
}
```

#### Sale History
Get historical sale transactions for a property.

```bash
rentcast-api.sh sale-history "1234 Oak Hill Dr, Austin, TX 78749"
```

**API call**: `GET /sales/history?address=1234+Oak+Hill+Dr%2C+Austin%2C+TX+78749` with `X-Api-Key` header

**Response**:
```json
[
  {
    "transactionDate": "2019-06-15",
    "price": 375000,
    "buyer": "John Smith",
    "seller": "Jane Doe",
    "transactionType": "Standard Sale",
    "documentType": "Warranty Deed"
  },
  {
    "transactionDate": "2010-03-22",
    "price": 265000,
    "buyer": "Jane Doe",
    "seller": "Builder LLC",
    "transactionType": "Standard Sale",
    "documentType": "Warranty Deed"
  }
]
```

#### Market Statistics
Get market stats for a zip code.

```bash
rentcast-api.sh market 78749
```

**API call**: `GET /markets?zipCode=78749` with `X-Api-Key` header

**Response**:
```json
{
  "zipCode": "78749",
  "city": "Austin",
  "state": "TX",
  "medianHomeValue": 515000,
  "medianRent": 2200,
  "averageDaysOnMarket": 35,
  "activeListings": 142,
  "priceToRentRatio": 19.5,
  "yearOverYearChange": 0.032,
  "medianPricePerSquareFoot": 225
}
```

### Rate Limits

| Tier | Requests/mo | Cost |
|------|-------------|------|
| Free | 50 | Free |
| Basic | 1,000 | $39/mo |
| Professional | 10,000 | $149/mo |

### Best Practices
- Free tier is very limited (50/mo) — use only for high-priority leads
- Always call `property` first — it confirms the address and returns owner name
- Call `value` second to determine revenue potential tier
- Only use `sale-history` for leads scoring 70+ — it costs an API call
- `market` data applies to all properties in a zip — call once per zip code and reuse
- Cache all results for at least 30 days — property data changes slowly
- Address formatting matters — use full address with city, state, zip

---

## Combining Sources

### Optimal Query Order for B2B Leads

Execute in this order to minimize paid API calls:

1. **GitHub** (free) + **SEC EDGAR** (free) — tech stack and financials if public
2. **Google Places** (cheap) — verify business exists, get address/phone
3. **Apollo** (1 credit) — `company-enrich` for firmographics
4. **SerpAPI** (1 search) — news + signals check
5. **Hunter** (1 request) — only for email discovery when Apollo lacks email
6. **Apollo org-chart** (N credits) — only when you need the full decision-maker roster

### Optimal Query Order for Residential Leads

1. **Socrata** (free) — pull permits matching criteria
2. **RentCast property** (1 call) — confirm address, get owner name
3. **RentCast value** (1 call) — determine property value tier
4. **RentCast sale-history** (1 call) — only for high-value leads (score 70+)
5. **RentCast market** (1 call) — once per zip code, reuse across leads

### Cross-Validation Patterns

Use these patterns to verify data accuracy across sources:

| Data Point | Primary Source | Cross-Reference With |
|-----------|---------------|---------------------|
| Company exists | Google Places | Apollo company-enrich |
| Company phone | Google Places | Apollo company-enrich |
| Company address | Google Places | Apollo company-enrich, SEC EDGAR |
| Contact email | Apollo | Hunter email-finder + verify |
| Contact title | Apollo | SerpAPI linkedin-profile |
| Revenue | SEC EDGAR (10-K) | Apollo (estimated_revenue) |
| Tech stack | GitHub languages | Apollo (technologies), SerpAPI job postings |
| Employee count | Apollo | GitHub (public_members), LinkedIn |
| Funding | Apollo (latest_funding) | SerpAPI news search |
| Property owner | RentCast property | RentCast sale-history (last buyer) |
| Property value | RentCast AVM | RentCast property (tax assessed value) |
| Permit address | Socrata | RentCast property (address normalization) |

### Conflict Resolution

When sources disagree:

1. **SEC EDGAR > Apollo > SerpAPI** for financial data (SEC is the legal filing)
2. **Hunter > Apollo** for email confidence (Hunter provides explicit scores)
3. **Google Places > Apollo** for phone/address (Google has real-time verification)
4. **Apollo > GitHub** for employee count (Apollo tracks total, GitHub only shows public)
5. **RentCast > Socrata** for property details (RentCast normalizes and enriches)
6. **Most recent timestamp wins** when data types are equal across sources
