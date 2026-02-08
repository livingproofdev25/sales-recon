# Web Research Patterns for Sales Prospecting

Techniques for finding prospect data from web sources when APIs are unavailable.

## Important Disclaimer

Web research should be conducted responsibly:
- Respect robots.txt directives
- Don't overload servers with requests
- Check terms of service before accessing data
- Prefer official APIs when available
- Use only publicly available information

## LinkedIn Research Patterns

LinkedIn heavily restricts automated access. Use these approaches instead:

### Alternative: SerpAPI LinkedIn Search
```python
# Use SerpAPI's Google search with site:linkedin.com
search_query = f"{name} {company} site:linkedin.com"
# Returns public profile snippets from Google's index
```

### Alternative: Hunter.io LinkedIn Lookup
Hunter.io can return LinkedIn URLs when finding emails:
```python
# Email finder often includes linkedin_url in response
{
  "linkedin_url": "linkedin.com/in/username"
}
```

### Public Profile Data (No Login)
LinkedIn public profiles show limited info:
- Name and headline
- Current company
- Location (city level)
- Profile photo

---

## Company Website Patterns

### Team Page Discovery

Common team page URL patterns:
```
/about
/about-us
/team
/our-team
/leadership
/about/team
/company/team
/people
```

Typical HTML structures:
```html
<!-- Card-based layout -->
<div class="team-member">
  <img src="photo.jpg" />
  <h3 class="name">John Smith</h3>
  <p class="title">VP Engineering</p>
  <a href="mailto:john@company.com">Email</a>
  <a href="linkedin.com/in/jsmith">LinkedIn</a>
</div>

<!-- List layout -->
<ul class="leadership">
  <li>
    <span class="executive-name">Jane Doe</span>
    <span class="executive-title">CEO</span>
  </li>
</ul>
```

### Contact Page Patterns

Look for:
```
/contact
/contact-us
/get-in-touch
```

Extract:
- General email (often info@, hello@, contact@)
- Phone numbers
- Physical address
- Support email

### Footer Information

Company footers often contain:
- Address
- Phone number
- Social media links
- Copyright year (indicates active business)

---

## News and Press Release Research

### Press Release Sources

Common locations:
```
/press
/news
/newsroom
/press-releases
/media
/blog (filter for announcements)
```

PR aggregator sites:
- PRNewswire
- BusinessWire
- GlobeNewswire
- PR.com

### Extracting Structured Data

Press releases often follow patterns:
```html
<article class="press-release">
  <time datetime="2024-01-15">January 15, 2024</time>
  <h1>Company Announces New Product</h1>
  <p class="summary">Brief description...</p>
</article>
```

Key data to extract:
- Date (for recency)
- Headline
- Key names mentioned
- Funding amounts (for funding news)
- Product names

---

## Job Posting Analysis

### Job Board Sources

Major sources:
- Company careers page (/careers, /jobs)
- LinkedIn Jobs
- Indeed
- Glassdoor
- Greenhouse
- Lever

### Insights from Job Postings

**Organizational clues:**
- Department names and structure
- Reporting relationships ("reports to VP of...")
- Team sizes ("join our 15-person team")
- Tech stack requirements
- Location expansion (new office locations)

**Growth indicators:**
- Number of open positions
- Seniority of roles (many senior roles = scaling)
- New departments forming
- Executive searches

### Example Job Listing Structure
```html
<div class="job-posting">
  <h2 class="job-title">Senior Software Engineer</h2>
  <span class="department">Engineering</span>
  <span class="location">San Francisco, CA</span>
  <div class="description">
    <!-- Often mentions team lead name, tech stack -->
  </div>
</div>
```

---

## Social Media Patterns

### Twitter/X
Public profiles show:
- Bio (often includes title, company)
- Follower count (influence metric)
- Recent tweets (thought leadership)
- Lists they're on

Search patterns:
```
"VP Engineering" site:twitter.com
"@companyhandle" site:twitter.com
```

### GitHub (Technical Roles)
For technical prospects:
- Public repositories
- Contribution activity
- Organization memberships
- Bio and contact info

Search:
```
"@company.com" site:github.com
"Company Name" site:github.com
```

---

## Rate Limiting Best Practices

### Request Throttling
```python
import time
import random

def respectful_request(url):
    # Random delay between 1-3 seconds
    time.sleep(1 + random.random() * 2)
    # Make request
    return fetch(url)
```

### Caching Results
```python
# Cache research data to avoid repeat requests
cache = {}

def get_with_cache(url, ttl_hours=24):
    if url in cache and not expired(cache[url], ttl_hours):
        return cache[url]['data']
    data = fetch(url)
    cache[url] = {'data': data, 'timestamp': now()}
    return data
```

### Retry Strategy
```python
def fetch_with_retry(url, max_retries=3):
    for attempt in range(max_retries):
        try:
            response = fetch(url)
            if response.status == 200:
                return response
            if response.status == 429:  # Rate limited
                wait_time = 2 ** attempt * 10  # Exponential backoff
                time.sleep(wait_time)
        except Exception as e:
            if attempt == max_retries - 1:
                raise
    return None
```

---

## Data Extraction Utilities

### Email Pattern Recognition
```python
import re

EMAIL_PATTERN = r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'

def extract_emails(text):
    return re.findall(EMAIL_PATTERN, text)
```

### Phone Number Extraction
```python
PHONE_PATTERNS = [
    r'\+?1?[-.\s]?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}',  # US format
    r'\+\d{1,3}[-.\s]?\d{2,4}[-.\s]?\d{2,4}[-.\s]?\d{2,4}',  # International
]

def extract_phones(text):
    phones = []
    for pattern in PHONE_PATTERNS:
        phones.extend(re.findall(pattern, text))
    return list(set(phones))
```

### Name Extraction (Basic)
```python
# For structured HTML with clear name elements
def extract_names_from_team_page(html):
    names = []
    # Look for common patterns
    for selector in ['.name', '.team-member-name', 'h3.person']:
        elements = html.select(selector)
        names.extend([e.text.strip() for e in elements])
    return names
```

---

## Ethical Considerations

### Do:
- Use public information only
- Respect rate limits and robots.txt
- Cache aggressively to reduce requests
- Identify yourself with a proper User-Agent
- Delete data when requested (GDPR compliance)

### Don't:
- Bypass authentication or paywalls
- Access private or logged-in-only content
- Overwhelm servers with rapid requests
- Store sensitive personal data unnecessarily
- Violate terms of service
- Use data for spam or harassment

### GDPR/Privacy Compliance
- Only collect business-related data
- Provide opt-out mechanism
- Don't collect personal addresses or personal phone numbers
- Document data sources for audit trail
- Implement data retention policies
