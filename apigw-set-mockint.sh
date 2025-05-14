#!/bin/bash

# Set your API ID here
API_ID="<API Gateway ID>"

# Loop over each resource
echo "$resources" | jq -c '.items[] | select(.resourceMethods != null)' | while read -r resource; do
    resource_id=$(echo "$resource" | jq -r '.id')
    path=$(echo "$resource" | jq -r '.path')
    
    methods=$(echo "$resource" | jq -r '.resourceMethods | keys[]')

    for method in $methods; do
        aws apigateway put-integration \
            --rest-api-id "$API_ID" \
            --resource-id "$resource_id" \
            --http-method "$method" \
            --type MOCK


        # Get integration info for each method
        integration=$(aws apigateway get-integration --rest-api-id "$API_ID" --resource-id "$resource_id" --http-method "$method" 2>/dev/null)
        uri=$(echo "$integration" | jq -r '.uri // "No integration URI"')
        echo "$method $path -> $uri"
    done
done
