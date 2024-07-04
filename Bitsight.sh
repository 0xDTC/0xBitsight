#!/bin/bash

# Source the secrets file to load the variables
source secrets.txt

# Construct the API URL with the company ID
API_URL="https://api.bitsighttech.com/ratings/v1/companies/$COMPANY_GUID/findings?limit=100000"

# Make API request using curl and filter for bad grade using jq
curl -s "$API_URL" -u "$API_TOKEN" | jq . > bitsight.json

# Filter the data based on the conditions and save it in a new file called filtered.json

jq --arg today "$(date +%Y-%m-%d)" --arg yesterday "$(date -d '1 day ago' +%Y-%m-%d)" --arg day_before_yesterday "$(date -d '2 days ago' +%Y-%m-%d)" '.results[] | select((.details.grade == "BAD" or .details.grade == "WARN" or .details.grade == "FAIR") and (.first_seen | contains($today, $yesterday, $day_before_yesterday)) and .affects_rating == true and (.last_seen | contains($today, $yesterday, $day_before_yesterday)) and (.comments == null))' bitsight.json > filtered.json 

# Now check if the filtered.json file contain any of these "risk_vector_label" which matches the name of template files then use the template in that file to fetch data and add it in the file called jira-bitsight-"lablename"-$date.json
# "risk_vector_label": "Desktop Software",
# "risk_vector_label": "DKIM",
# "risk_vector_label": "DMARC",
# "risk_vector_label": "DNSSEC",
# "risk_vector_label": "Mobile Application Security",
# "risk_vector_label": "Mobile Software",
# "risk_vector_label": "Open Ports",
# "risk_vector_label": "Server Software",
# "risk_vector_label": "SPF",
# "risk_vector_label": "SSL Certificates",
# "risk_vector_label": "SSL Configurations",
# "risk_vector_label": "Web Application Headers",
# "risk_vector_label": "Web Application Security",