# Supported Cities & Socrata Endpoints

## Austin, TX
- **Portal**: data.austintexas.gov
- **Dataset**: 3syk-w9eu
- **Key fields**: `issued_date`, `work_description`, `original_address1`, `original_city`, `original_zip`, `status_current`, `permit_type_desc`
- **Endpoint**: `https://data.austintexas.gov/resource/3syk-w9eu.json`

## San Antonio, TX
- **Portal**: data.sanantonio.gov
- **Dataset**: nkgd-7gx7
- **Key fields**: `issued_date`, `project_description`, `address`, `zip_code`, `permit_type`
- **Endpoint**: `https://data.sanantonio.gov/resource/nkgd-7gx7.json`

## New York City, NY
- **Portal**: data.cityofnewyork.us
- **Dataset**: ipu4-2vj7
- **Key fields**: `issuance_date`, `job_description`, `house__`, `street_name`, `borough`, `zip_code`, `job_type`
- **Endpoint**: `https://data.cityofnewyork.us/resource/ipu4-2vj7.json`

## Boston, MA
- **Portal**: data.boston.gov
- **Dataset**: hfgw-p5wb
- **Key fields**: `issued_date`, `description`, `address`, `zip`, `permit_type`, `estimated_cost`
- **Endpoint**: `https://data.boston.gov/resource/hfgw-p5wb.json`

## Detroit, MI
- **Portal**: data.detroitmi.gov
- **Dataset**: but4-ky7y
- **Key fields**: `permit_issued`, `bld_type_use`, `site_address`, `parcel_no`, `permit_description`
- **Endpoint**: `https://data.detroitmi.gov/resource/but4-ky7y.json`

## Washington, DC
- **Portal**: opendata.dc.gov
- **Dataset**: awqx-zupu
- **Key fields**: `issue_date`, `full_address`, `description_of_work`, `permit_type_name`, `fees_paid`
- **Endpoint**: `https://opendata.dc.gov/resource/awqx-zupu.json`

## Field Mapping Notes

Field names vary by city. The `socrata-permits-api.sh` script handles normalization. When a command returns raw data, Claude should map fields to the standard schema:
- **address**: varies (`original_address1`, `address`, `site_address`, `full_address`)
- **date**: varies (`issued_date`, `issuance_date`, `permit_issued`, `issue_date`)
- **description**: varies (`work_description`, `project_description`, `job_description`, `description_of_work`)
- **value/cost**: varies (`estimated_cost`, `fees_paid`, `original_value`)
