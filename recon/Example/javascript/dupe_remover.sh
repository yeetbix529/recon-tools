#!/bin/bash
source "/home/kali/bugBounty/script/lib/config.sh"
source "/home/kali/bugBounty/script/lib/helpers.sh"

SECRET_KEYWORDS=(
'amazon_aws_access_key_id'
)

print_line_count "js_filtered.txt"

RAW_OUTPUT="js_filtered.txt"
FILTERED_OUTPUT="format.txt"

deduplicate_results "$RAW_OUTPUT" "$FILTERED_OUTPUT" "${SECRET_KEYWORDS[@]}"

print_line_count "format.txt"
