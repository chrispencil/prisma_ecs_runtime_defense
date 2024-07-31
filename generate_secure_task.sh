#!/bin/bash

# Define the API endpoints
AUTH_API_ENDPOINT=${AUTH_API_ENDPOINT}
TASK_GENERATION_API_ENDPOINT=${TASK_GENERATION_API_ENDPOINT}

# Define the headers for the requests
HEADERS=(-H "Content-Type: application/json")
AUTH_HEADER=(-H "Authorization: Bearer ${BEARER_TOKEN}")
TASK_GENERATION_HEADERS=(${HEADERS[@]} ${AUTH_HEADER[@]} -H 'Accept: */*' -H 'Content-Type: application/json')

# Function to send a POST request and return the response
send_request() {
  local url=$1
  shift
  local response=$(curl -s -X POST "$url" "${HEADERS[@]}" -d @request_body.json)
  echo "$response"
}

# Function to write the task definition to a file
write_task_definition() {
  local response=$1
  echo "$response" | /usr/bin/jq > protectedtask.json
}

# Obtain the bearer token
echo "Obtaining Bearer Token..."
BEARER_TOKEN=$(curl -s -X POST "$AUTH_API_ENDPOINT" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"${TL_USER}\",\"password\":\"${TL_PASS}\"}" | jq -r '.token')

echo "Bearer Token: $BEARER_TOKEN"

# Prepare the request body for generating the Fargate task
cat <<EOF > request_body.json
{
  "consoleaddr": "${TL_CONSOLE}",
  "defenderType": "appEmbedded",
}
EOF

# Generate the Fargate task definition
echo "Generating Fargate Task..."
TASK_DEFINITION_JSON=$(curl -X 'POST' -H "Authorization: Bearer $BEARER_TOKEN" -H 'Accept: */*' -H 'Content-Type: application/json' --data-binary "@original_task_definition.json" "$TASK_GENERATION_API_ENDPOINT?consoleaddr=${TL_CONSOLE}&defenderType=appEmbedded" | /usr/bin/jq)

# Write the task definition to a file
write_task_definition "$TASK_DEFINITION_JSON"

echo "Generated protectedtask.json"
