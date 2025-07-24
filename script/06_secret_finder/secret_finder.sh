#!/bin/bash
source "$(dirname "$0")/../lib/config.sh"
source "$(dirname "$1")/../lib/helper.sh"

# === module: 06_secret_finder.sh ===
# Description:
# uses secretfinder to analyse javascript files
#

# === config
IFS=$'\n\t'
INPUT_FILE="$JS_DIR/js_endpoints.txt"
RAW_OUTPUT="$JS_DIR/js_raw.txt"
FILTERED_OUTPUT="$JS_DIR/js_filtered.txt"

# === step 0: system checks
if [ ! -f "$INPUT_FILE" ]; then
	echo "Input file not found: $INPUT_FILE"
	exit 1
fi

echo "Activate SecretFinder venv..."

if ! source "$SECRETFINDER_DIR/venv/bin/activate"; then
	echo "Failed to activate virtualenv at $SECRETFINDER_DIR/venv"
	exit 1
fi

> "$RAW_OUTPUT"
> "$FILTERED_OUTPUT"

# === step 1: scanning
urls=( $(grep -iEv 'jquery|bootstrap|\.min\.js' "$INPUT_FILE") )
total_urls=${#urls[@]}

echo "Found $total_urls URLs to scan."

for url in "${urls[@]}"; do
	echo "Scanning $url"
	before_count=$(wc -l < "$RAW_OUTPUT" || echo 0)
	
	python3 "$SECRETFINDER_DIR/SecretFinder.py" -i "$url" -o cli | tee -a "$RAW_OUTPUT" >/dev/null
	
	echo >> "$RAW_OUTPUT"
	after_count=$(wc -l < "$RAW_OUTPUT")
	
	found=$(( after_count - before_count ))
	if (( found > 0 )); then
		echo " -> Found $found potential secrets in this URL"
	else
		echo "-> No secrets found in this URL"
	fi
done

# === step 2: filter & deduplicate
SECRET_KEYWORDS=(
'heroku'
'apikey'
'api[\s_-]?key'
'token'
'bearer'
'secret'
'authorization'
'access[_-]?key'
'jwt'
'refresh_token'
'supabase\.auth.*'
'client_secret'
'session_token'
'signature'
'private_key'
'aws_access_key'
'aws_secret_key'
'gcp_key'
'firebase'
'admin_token'
)

echo "Filtering and deduplicating results..."

deduplicate_and_filter "$RAW_OUTPUT" "$FILTERED_OUTPUT" "${SECRET_KEYWORDS[@]}"
total_secrets=$(wc -l < "$FILTERED_OUTPUT")
echo "Total unique potential secrets: $total_secrets"

# === step 3: breakdown by keyword
if (( total_secrets > 0 )); then
	echo
	echo "Breakdown by pattern:"
	for kw in "${SECRET_KEYWORDS[@]}"; do
		count=$(grep -Eic "$kw" "$FILTERED_OUTPUT" 2>/dev/null || true)
		if (( count > 0 )); then
			printf " • %s: %d\n" "$kw" "$count"
		fi
	done
fi

# === step 4: result summary
echo "All done."
echo "  • Raw output:      $RAW_OUTPUT"
echo "  • Filtered output: $FILTERED_OUTPUT"











	
