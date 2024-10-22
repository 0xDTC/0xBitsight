#!/bin/bash

# Source the secrets file to load the variables
source secrets.txt

# Set the current date
current_date=$(date +%Y%m%d)

# Construct the API URL with the company ID
API_URL="https://api.bitsighttech.com/ratings/v1/companies/$COMPANY_GUID/findings?limit=100000"

# Make API request using curl and save the results to bitsight.json
curl -s "$API_URL" -u "$API_TOKEN" | jq . > bitsight.json

# Filter the data based on the conditions and save it in a new file called filtered.json
jq --arg today "$(date +%Y-%m-%d)" \
   --arg yesterday "$(date -d '1 day ago' +%Y-%m-%d)" \
   --arg day_before_yesterday "$(date -d '2 days ago' +%Y-%m-%d)" \
   '.results[] | select((.details.grade == "BAD" or .details.grade == "WARN" or .details.grade == "FAIR") and (.first_seen | contains($today, $yesterday, $day_before_yesterday)) and .affects_rating == true and (.last_seen | contains($today, $yesterday, $day_before_yesterday)) and (.comments == null))' \
   bitsight.json > filtered.json

# Define the list of risk vector labels and corresponding templates
declare -A risk_vector_templates
risk_vector_templates=(
  ["Desktop Software"]="desktop_software_template.json"
  ["DKIM"]="dkim_template.json"
  ["DMARC"]="dmarc_template.json"
  ["DNSSEC"]="dnssec_template.json"
  ["Mobile Application Security"]="mobile_application_security_template.json"
  ["Mobile Software"]="mobile_software_template.json"
  ["Open Ports"]="open_ports_template.json"
  ["Server Software"]="server_software_template.json"
  ["SPF"]="spf_template.json"
  ["SSL Certificates"]="ssl_certificates_template.json"
  ["SSL Configurations"]="ssl_configurations_template.json"
  ["Web Application Headers"]="web_application_headers_template.json"
  ["Web Application Security"]="web_application_security_template.json"
)

# Loop through each risk vector label and generate corresponding JSON files
for risk_vector_label in "${!risk_vector_templates[@]}"; do
  # Check if the risk_vector_label exists in the filtered.json file
  if jq -e --arg label "$risk_vector_label" '. | select(.risk_vector_label == $label)' filtered.json > /dev/null; then
    # Use the corresponding template
    template_file="${risk_vector_templates[$risk_vector_label]}"
    
    # Generate the output file name
    output_file="jira-bitsight-${risk_vector_label// /_}-$current_date.json"
    
    # Generate the JSON file using the template
    jq --argfile template "$template_file" \
       --argfile filtered filtered.json \
       '. * $template' > "$output_file"
    
    echo "Generated $output_file for risk vector label: $risk_vector_label"
  else
    echo "No findings for risk vector label: $risk_vector_label"
  fi
done