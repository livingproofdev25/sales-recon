#!/usr/bin/env python3
"""
Format prospect data into various report formats.
Usage: python format-report.py <input.json> <output-format> [output-file]

Formats: markdown, json, csv, html
"""

import json
import sys
import csv
from datetime import datetime
from io import StringIO


def format_person_markdown(person: dict) -> str:
    """Format a person record as markdown."""
    md = f"# Contact Profile: {person.get('name', 'Unknown')}\n\n"

    # Contact Information
    md += "## Contact Information\n"
    md += f"- **Email**: {person.get('email', 'Not found')}"
    if person.get('email_confidence'):
        md += f" ({person['email_confidence']}% confidence)"
    md += "\n"
    md += f"- **Phone**: {person.get('phone', 'Not found')}\n"
    md += f"- **LinkedIn**: {person.get('linkedin_url', 'Not found')}\n"
    md += f"- **Twitter**: {person.get('twitter', 'Not found')}\n\n"

    # Professional Profile
    md += "## Professional Profile\n"
    md += f"- **Current Role**: {person.get('current_title', 'Unknown')} at {person.get('current_company', 'Unknown')}\n"
    md += f"- **Location**: {person.get('location', 'Unknown')}\n\n"

    # Work History
    if person.get('work_history'):
        md += "## Work History\n"
        for i, job in enumerate(person['work_history'], 1):
            md += f"{i}. {job.get('title', 'Unknown')} at {job.get('company', 'Unknown')}"
            if job.get('start') and job.get('end'):
                md += f" ({job['start']} - {job['end']})"
            md += "\n"
        md += "\n"

    # Decision Maker Score
    if person.get('decision_maker_score'):
        md += f"## Decision-Maker Score: {person['decision_maker_score']}/10\n\n"

    # Data Sources
    if person.get('data_sources'):
        md += "## Data Sources\n"
        for source in person['data_sources']:
            md += f"- {source}\n"
        md += "\n"

    md += f"*Last updated: {person.get('last_updated', datetime.now().isoformat()[:10])}*\n"

    return md


def format_company_markdown(company: dict) -> str:
    """Format a company record as markdown."""
    md = f"# Company Profile: {company.get('name', 'Unknown')}\n\n"

    # Overview
    md += "## Overview\n"
    md += f"- **Industry**: {company.get('industry', 'Unknown')}\n"
    md += f"- **Founded**: {company.get('founded', 'Unknown')}\n"
    md += f"- **Employees**: {company.get('employee_count', 'Unknown')}\n"
    md += f"- **Revenue**: {company.get('revenue_estimate', 'Unknown')}\n"
    md += f"- **Website**: {company.get('website', 'Unknown')}\n\n"

    # Headquarters
    if company.get('headquarters'):
        hq = company['headquarters']
        md += "## Headquarters\n"
        md += f"- **Address**: {hq.get('address', 'Unknown')}\n"
        md += f"- **Phone**: {hq.get('phone', 'Unknown')}\n\n"

    # Leadership
    if company.get('leadership'):
        md += "## Leadership Team\n\n"
        md += "| Name | Title | Email | DM Score |\n"
        md += "|------|-------|-------|----------|\n"
        for leader in company['leadership']:
            md += f"| {leader.get('name', '')} | {leader.get('title', '')} | {leader.get('email', '')} | {leader.get('dm_score', '')} |\n"
        md += "\n"

    # Decision Makers
    if company.get('decision_makers'):
        md += "## Decision Makers\n"
        for i, dm in enumerate(company['decision_makers'], 1):
            md += f"{i}. **{dm.get('name', 'Unknown')}** - {dm.get('title', 'Unknown')}"
            if dm.get('role'):
                md += f" ({dm['role']})"
            md += "\n"
        md += "\n"

    # Recent News
    if company.get('recent_news'):
        md += "## Recent News\n"
        for news in company['recent_news']:
            md += f"- [{news.get('date', '')}] {news.get('headline', '')}"
            if news.get('source'):
                md += f" ({news['source']})"
            md += "\n"
        md += "\n"

    md += f"*Last updated: {company.get('last_updated', datetime.now().isoformat()[:10])}*\n"

    return md


def format_to_csv(data: dict) -> str:
    """Convert prospect data to CSV format."""
    output = StringIO()

    # Flatten persons
    if data.get('persons'):
        writer = csv.writer(output)
        headers = ['type', 'name', 'email', 'email_confidence', 'phone', 'linkedin_url',
                   'twitter', 'title', 'company', 'location', 'dm_score', 'last_updated']
        writer.writerow(headers)

        for person in data['persons']:
            writer.writerow([
                'person',
                person.get('name', ''),
                person.get('email', ''),
                person.get('email_confidence', ''),
                person.get('phone', ''),
                person.get('linkedin_url', ''),
                person.get('twitter', ''),
                person.get('current_title', ''),
                person.get('current_company', ''),
                person.get('location', ''),
                person.get('decision_maker_score', ''),
                person.get('last_updated', '')
            ])

    # Flatten companies
    if data.get('companies'):
        for company in data['companies']:
            # Company row
            ceo = next((l for l in company.get('leadership', []) if 'CEO' in l.get('title', '')), {})
            output.write(f"company,{company.get('name', '')},{ceo.get('email', '')},,")
            output.write(f"{company.get('headquarters', {}).get('phone', '')},,,")
            output.write(f",{company.get('name', '')},{company.get('headquarters', {}).get('address', '')},")
            output.write(f",{company.get('last_updated', '')}\n")

    return output.getvalue()


def format_to_html(data: dict) -> str:
    """Convert prospect data to HTML report."""
    html = """<!DOCTYPE html>
<html>
<head>
    <title>Prospect Research Report</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 1200px; margin: 0 auto; padding: 20px; }
        h1 { color: #1a1a2e; border-bottom: 2px solid #4a4e69; padding-bottom: 10px; }
        h2 { color: #4a4e69; margin-top: 30px; }
        .card { background: #f8f9fa; border-radius: 8px; padding: 20px; margin: 20px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .dm-score { display: inline-block; background: #4a4e69; color: white; padding: 5px 15px; border-radius: 20px; font-weight: bold; }
        .dm-high { background: #2ecc71; }
        .dm-medium { background: #f39c12; }
        .dm-low { background: #e74c3c; }
        table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #4a4e69; color: white; }
        tr:hover { background: #f5f5f5; }
        .meta { color: #666; font-size: 0.9em; margin-top: 20px; }
    </style>
</head>
<body>
    <h1>Prospect Research Report</h1>
"""

    # Export metadata
    if data.get('export_metadata'):
        meta = data['export_metadata']
        html += f"<p class='meta'>Generated: {meta.get('timestamp', '')} | Source: {meta.get('source', 'prospector')}</p>\n"

    # Persons
    if data.get('persons'):
        html += "<h2>Contact Profiles</h2>\n"
        for person in data['persons']:
            dm_class = 'dm-high' if person.get('decision_maker_score', 0) >= 7 else ('dm-medium' if person.get('decision_maker_score', 0) >= 4 else 'dm-low')
            html += f"""<div class="card">
    <h3>{person.get('name', 'Unknown')}
        <span class="dm-score {dm_class}">DM Score: {person.get('decision_maker_score', 'N/A')}/10</span>
    </h3>
    <p><strong>{person.get('current_title', 'Unknown')}</strong> at {person.get('current_company', 'Unknown')}</p>
    <p>Email: {person.get('email', 'N/A')} | Phone: {person.get('phone', 'N/A')} | <a href="{person.get('linkedin_url', '#')}">LinkedIn</a></p>
    <p>Location: {person.get('location', 'Unknown')}</p>
</div>\n"""

    # Companies
    if data.get('companies'):
        html += "<h2>Company Profiles</h2>\n"
        for company in data['companies']:
            html += f"""<div class="card">
    <h3>{company.get('name', 'Unknown')}</h3>
    <p><strong>Industry:</strong> {company.get('industry', 'Unknown')} | <strong>Size:</strong> {company.get('employee_count', 'Unknown')} | <strong>Revenue:</strong> {company.get('revenue_estimate', 'Unknown')}</p>
    <p><a href="{company.get('website', '#')}">{company.get('website', 'N/A')}</a> | Phone: {company.get('headquarters', {}).get('phone', 'N/A')}</p>
"""
            if company.get('leadership'):
                html += "<h4>Leadership</h4>\n<table><tr><th>Name</th><th>Title</th><th>Email</th><th>DM Score</th></tr>\n"
                for leader in company['leadership']:
                    html += f"<tr><td>{leader.get('name', '')}</td><td>{leader.get('title', '')}</td><td>{leader.get('email', '')}</td><td>{leader.get('dm_score', '')}</td></tr>\n"
                html += "</table>\n"
            html += "</div>\n"

    html += """
    <p class="meta">Generated by Prospector Plugin</p>
</body>
</html>"""

    return html


def main():
    if len(sys.argv) < 3:
        print("Usage: format-report.py <input.json> <format> [output-file]")
        print("Formats: markdown, json, csv, html")
        sys.exit(1)

    input_file = sys.argv[1]
    output_format = sys.argv[2].lower()
    output_file = sys.argv[3] if len(sys.argv) > 3 else None

    # Read input
    with open(input_file, 'r') as f:
        data = json.load(f)

    # Format output
    if output_format == 'markdown' or output_format == 'md':
        output = ""
        for person in data.get('persons', []):
            output += format_person_markdown(person) + "\n---\n\n"
        for company in data.get('companies', []):
            output += format_company_markdown(company) + "\n---\n\n"
    elif output_format == 'json':
        output = json.dumps(data, indent=2)
    elif output_format == 'csv':
        output = format_to_csv(data)
    elif output_format == 'html':
        output = format_to_html(data)
    else:
        print(f"Unknown format: {output_format}")
        sys.exit(1)

    # Output
    if output_file:
        with open(output_file, 'w') as f:
            f.write(output)
        print(f"Written to {output_file}")
    else:
        print(output)


if __name__ == '__main__':
    main()
