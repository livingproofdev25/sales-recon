---
name: lead-settings
description: Configure API keys, default ICP, and output preferences for sales-recon
argument-hint: [show|set <key> <value>|reset]
allowed-tools: Read, Write, Bash
---

Manage sales-recon plugin configuration: $ARGUMENTS

## Process

### Step 1: Parse Arguments

Extract from "$ARGUMENTS":
- **Action**: One of:
  - `show` (default if no arguments) — Display current configuration
  - `set <key> <value>` — Update a specific setting
  - `reset` — Reset configuration to empty template

Valid keys for `set`:
- `hunter_api_key` — Hunter.io API key
- `apollo_api_key` — Apollo.io API key
- `serp_api_key` — SerpAPI key
- `google_places_api_key` — Google Places API key
- `rentcast_api_key` — RentCast API key
- `output_format` — Default output format (`markdown` or `json`)
- Any `default_icp.*` field (e.g., `default_icp.industries`, `default_icp.min_employees`)

### Step 2: Settings File Location

The settings file is: `~/.claude/sales-recon.local.md`

This file uses YAML frontmatter for structured configuration.

### Step 3: Action — Show

Read `~/.claude/sales-recon.local.md`. If the file does not exist, show the empty state.

Check each API key: test if the environment variable is set OR if the key exists in the settings file.

For each configured API key, mask all but the last 4 characters (e.g., `****7f3a`).

Output:

```markdown
# Sales-Recon Settings

## API Keys

| API | Status | Source | Monthly Limit |
|-----|--------|--------|---------------|
| Hunter.io | [Configured/Missing] | [env/file] | 25 searches, 50 verifications (free) |
| Apollo.io | [Configured/Missing] | [env/file] | 900 credits (free) |
| SerpAPI | [Configured/Missing] | [env/file] | 100 searches (free) |
| Google Places | [Configured/Missing] | [env/file] | ~11,700 requests ($200 credit) |
| RentCast | [Configured/Missing] | [env/file] | 50 requests (free) |
| GitHub | [Configured/Optional] | [env/file] | 5,000 req/hr (free with token) |

**APIs configured**: [N] of 5 required | [N] of 1 optional

## ICP Configuration

[If configured, show summary:]
- **Industries**: [list]
- **Company Size**: [min]-[max] employees
- **Revenue**: [min]-[max]
- **Geography**: [list]
- **Target Titles**: [list]
- **Target Departments**: [list]
- **Tech Stack**: [list or "Not set"]

[If not configured:]
- **Status**: Not configured. Run `/set-icp` to define your Ideal Customer Profile.

## Output Preferences

- **Default format**: [markdown/json]

## Setup Guide

To get started, you need API keys for at least the core services:

### Required APIs

1. **Hunter.io** (email discovery)
   - Sign up: https://hunter.io/users/sign_up
   - Free tier: 25 searches/mo, 50 verifications/mo
   - Set: `/lead-settings set hunter_api_key YOUR_KEY`

2. **Apollo.io** (company & contact data)
   - Sign up: https://www.apollo.io/sign-up
   - Free tier: 900 credits/mo
   - Set: `/lead-settings set apollo_api_key YOUR_KEY`

3. **SerpAPI** (web search, news, jobs)
   - Sign up: https://serpapi.com/users/sign_up
   - Free tier: 100 searches/mo
   - Set: `/lead-settings set serp_api_key YOUR_KEY`

4. **Google Places** (business verification)
   - Console: https://console.cloud.google.com/apis/library/places-backend.googleapis.com
   - Free tier: $200/mo credit
   - Set: `/lead-settings set google_places_api_key YOUR_KEY`

5. **RentCast** (property data — residential only)
   - Sign up: https://app.rentcast.io/app/api
   - Free tier: 50 requests/mo
   - Set: `/lead-settings set rentcast_api_key YOUR_KEY`

### Optional APIs

6. **GitHub** (tech stack detection — no key needed, but token increases rate limit)
   - Token: https://github.com/settings/tokens
   - Set env var: `export GITHUB_TOKEN=your_token`

### Environment Variables

You can also set keys as environment variables instead of in the settings file:
```bash
export HUNTER_API_KEY=your_key
export APOLLO_API_KEY=your_key
export SERPAPI_KEY=your_key
export GOOGLE_PLACES_API_KEY=your_key
export RENTCAST_API_KEY=your_key
export GITHUB_TOKEN=your_token
```
```

### Step 4: Action — Set

Read the existing settings file. If it does not exist, create it from the template first.

Update the specified key in the YAML frontmatter:

```bash
# Read current file
cat ~/.claude/sales-recon.local.md
```

Parse the YAML frontmatter, update the specified key with the new value, and write the file back.

For API keys, validate the format looks reasonable (non-empty string, no spaces).

Confirm the update:

```markdown
## Setting Updated

- **Key**: [key name]
- **Value**: [masked value — ****last4]
- **File**: ~/.claude/sales-recon.local.md

Run `/lead-settings show` to see all current settings.
```

### Step 5: Action — Reset

Ask the user to confirm: "This will reset all settings to defaults (including removing API keys from the file). Environment variables will not be affected. Continue? (yes/no)"

If confirmed, write the empty template to `~/.claude/sales-recon.local.md`:

```yaml
---
hunter_api_key: ""
apollo_api_key: ""
serp_api_key: ""
google_places_api_key: ""
rentcast_api_key: ""
default_icp:
  industries: []
  min_employees: 0
  max_employees: 0
  min_revenue: ""
  max_revenue: ""
  geo: []
  target_titles: []
  target_departments: []
  tech_stack: []
  pain_points: []
output_format: "markdown"
---
# Sales-Recon Settings
This file stores your sales-recon plugin configuration.
API keys are stored locally and never committed to git.
```

Confirm:

```markdown
## Settings Reset

All settings have been reset to defaults.
- API keys cleared from file (environment variables unaffected)
- ICP cleared (run `/set-icp` to reconfigure)
- Output format reset to markdown

Run `/lead-settings show` to verify.
```
