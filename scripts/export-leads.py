#!/usr/bin/env python3
"""
Export leads to various CRM-compatible formats.
Usage: python export-leads.py <input.json> <format> [output-file]

Formats: salesforce, hubspot, pipedrive, generic-csv
"""

import json
import sys
import csv
from datetime import datetime
from io import StringIO


def export_salesforce(data: dict) -> str:
    """Export to Salesforce Lead import format."""
    output = StringIO()
    writer = csv.writer(output)

    # Salesforce Lead headers
    headers = [
        'First Name', 'Last Name', 'Email', 'Phone', 'Company',
        'Title', 'Industry', 'Website', 'LinkedIn__c', 'Twitter__c',
        'Lead Source', 'Description', 'Rating'
    ]
    writer.writerow(headers)

    for person in data.get('persons', []):
        name_parts = person.get('name', '').split(' ', 1)
        first_name = name_parts[0] if name_parts else ''
        last_name = name_parts[1] if len(name_parts) > 1 else ''

        # Convert DM score to Salesforce rating
        dm_score = person.get('decision_maker_score', 0)
        rating = 'Hot' if dm_score >= 8 else ('Warm' if dm_score >= 5 else 'Cold')

        writer.writerow([
            first_name,
            last_name,
            person.get('email', ''),
            person.get('phone', ''),
            person.get('current_company', ''),
            person.get('current_title', ''),
            '',  # Industry (from company data if available)
            '',  # Website (from company data if available)
            person.get('linkedin_url', ''),
            person.get('twitter', ''),
            'Prospector',
            f"DM Score: {dm_score}/10. {', '.join(person.get('data_sources', []))}",
            rating
        ])

    return output.getvalue()


def export_hubspot(data: dict) -> str:
    """Export to HubSpot Contact import format."""
    output = StringIO()
    writer = csv.writer(output)

    # HubSpot Contact headers
    headers = [
        'First Name', 'Last Name', 'Email', 'Phone Number',
        'Company Name', 'Job Title', 'LinkedIn Bio',
        'Twitter Username', 'City', 'State/Region',
        'Lead Status', 'Lifecycle Stage', 'Lead Source'
    ]
    writer.writerow(headers)

    for person in data.get('persons', []):
        name_parts = person.get('name', '').split(' ', 1)
        first_name = name_parts[0] if name_parts else ''
        last_name = name_parts[1] if len(name_parts) > 1 else ''

        location_parts = person.get('location', '').split(', ')
        city = location_parts[0] if location_parts else ''
        state = location_parts[1] if len(location_parts) > 1 else ''

        dm_score = person.get('decision_maker_score', 0)
        lead_status = 'Qualified' if dm_score >= 7 else ('Open' if dm_score >= 4 else 'New')

        writer.writerow([
            first_name,
            last_name,
            person.get('email', ''),
            person.get('phone', ''),
            person.get('current_company', ''),
            person.get('current_title', ''),
            person.get('linkedin_url', ''),
            person.get('twitter', '').replace('@', ''),
            city,
            state,
            lead_status,
            'lead',
            'Prospector'
        ])

    return output.getvalue()


def export_pipedrive(data: dict) -> str:
    """Export to Pipedrive Person import format."""
    output = StringIO()
    writer = csv.writer(output)

    # Pipedrive Person headers
    headers = [
        'Name', 'Email', 'Phone', 'Organization',
        'Label', 'Owner', 'Visible to', 'Note'
    ]
    writer.writerow(headers)

    for person in data.get('persons', []):
        dm_score = person.get('decision_maker_score', 0)
        label = 'Hot lead' if dm_score >= 8 else ('Warm lead' if dm_score >= 5 else 'Cold lead')

        note = f"Title: {person.get('current_title', 'N/A')}\n"
        note += f"LinkedIn: {person.get('linkedin_url', 'N/A')}\n"
        note += f"DM Score: {dm_score}/10\n"
        note += f"Sources: {', '.join(person.get('data_sources', []))}"

        writer.writerow([
            person.get('name', ''),
            person.get('email', ''),
            person.get('phone', ''),
            person.get('current_company', ''),
            label,
            '',  # Owner - leave blank for auto-assignment
            'Everyone',
            note
        ])

    return output.getvalue()


def export_generic(data: dict) -> str:
    """Export to generic CSV format with all fields."""
    output = StringIO()
    writer = csv.writer(output)

    # Comprehensive headers
    headers = [
        'record_type', 'name', 'email', 'email_confidence', 'phone',
        'linkedin_url', 'twitter', 'title', 'company', 'location',
        'industry', 'employee_count', 'website', 'decision_maker_score',
        'work_history', 'data_sources', 'last_updated'
    ]
    writer.writerow(headers)

    for person in data.get('persons', []):
        work_history = '; '.join([
            f"{job.get('title', '')} at {job.get('company', '')} ({job.get('start', '')}-{job.get('end', '')})"
            for job in person.get('work_history', [])
        ])

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
            '',  # industry
            '',  # employee_count
            '',  # website
            person.get('decision_maker_score', ''),
            work_history,
            ', '.join(person.get('data_sources', [])),
            person.get('last_updated', '')
        ])

    for company in data.get('companies', []):
        writer.writerow([
            'company',
            company.get('name', ''),
            '',  # email
            '',  # email_confidence
            company.get('headquarters', {}).get('phone', ''),
            '',  # linkedin_url
            '',  # twitter
            '',  # title
            company.get('name', ''),
            company.get('headquarters', {}).get('address', ''),
            company.get('industry', ''),
            company.get('employee_count', ''),
            company.get('website', ''),
            '',  # decision_maker_score
            '',  # work_history
            ', '.join(company.get('data_sources', [])),
            company.get('last_updated', '')
        ])

    return output.getvalue()


def main():
    if len(sys.argv) < 3:
        print("Usage: export-leads.py <input.json> <format> [output-file]")
        print("Formats: salesforce, hubspot, pipedrive, generic-csv")
        sys.exit(1)

    input_file = sys.argv[1]
    export_format = sys.argv[2].lower()
    output_file = sys.argv[3] if len(sys.argv) > 3 else None

    # Read input
    with open(input_file, 'r') as f:
        data = json.load(f)

    # Export based on format
    if export_format == 'salesforce':
        output = export_salesforce(data)
    elif export_format == 'hubspot':
        output = export_hubspot(data)
    elif export_format == 'pipedrive':
        output = export_pipedrive(data)
    elif export_format == 'generic-csv' or export_format == 'generic':
        output = export_generic(data)
    else:
        print(f"Unknown format: {export_format}")
        print("Available formats: salesforce, hubspot, pipedrive, generic-csv")
        sys.exit(1)

    # Output
    if output_file:
        with open(output_file, 'w') as f:
            f.write(output)
        print(f"Exported to {output_file}")
    else:
        print(output)


if __name__ == '__main__':
    main()
