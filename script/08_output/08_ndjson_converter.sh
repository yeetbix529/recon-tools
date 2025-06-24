#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# === module 08_ndjson_converter.sh ===
# Description: converts .txt file output to .ndjson
# format ideal for elastic stack integration.

### --- configuration ----------------------------------------
TARGET="NBA Public Bug Bounty"
BASE_DIR="recon/$TARGET"
OUTFILE="$BASE_DIR/output.ndjson"
> "$OUTFILE"
TECH_FILE="recon/$TARGET/tech-detect/${TARGET}_httpx.txt"

### --- output structure prep -------------------------------
emit_ndjson() {
	local source="$1"
	local value="$2"
	local status_code="$3"
	local in_scope="$4"
	local technologies="${5:-[]}"
	jq -nc \
		--arg target "$TARGET" \
		--arg source "$source" \
		--arg value "$value" \
		--argjson status_code "$status_code" \
		--argjson in_scope "$in_scope" \
		--argjson technologies "$technologies" \
		'{target: $target, source: $source, value: $value, status_code: $status_code, in_scope: $in_scope, technologies: $technologies}'
}

### --- output line prep -------------------------------------
# --- Scope
while read -r line; do
	[[ -z "$line" ]] && continue
	emit_ndjson "scope.txt" "$line" null true >> "$OUTFILE"
done < "recon/$TARGET/${TARGET}_scope.txt"

# --- Out of Scope
while read -r line; do
	[[ -z "$line" ]] && continue
	emit_ndjson "out_of_scope.txt" "$line" null false >> "$OUTFILE"
done < "recon/$TARGET/${TARGET}_out_of_scope.txt"

# --- Filtered subdomains
while read -r line; do
	[[ -z "$line" ]] && continue
	emit_ndjson "filtered.txt" "$line" null null >> "$OUTFILE"
done < recon/$TARGET/subdomains/filtered.txt

# --- 200.txt (Live URLs)
while read -r url; do
	[[ -z "$url" ]] && continue
	emit_ndjson "200.txt" "$url" 200 null >> "$OUTFILE"
done < recon/$TARGET/http/200.txt

# --- non_200.txt (Non-200s with status)
regex='^(https?://[^ ]+) \[([0-9]{3})\]$'

while read -r line; do
	[[ -z "$line" ]] && continue
	if [[ "$line" =~ $regex ]]; then
		url="${BASH_REMATCH[1]}"
		status="${BASH_REMATCH[2]}"
		emit_ndjson "non_200.txt" "$url" "$status" null >> "$OUTFILE"
	fi
done < recon/$TARGET/http/non_200.txt

# --- tech_detect.txt (Tech stack detection)
while read -r line; do
	[[ -z "$line" ]] && continue

	if [[ "$line" =~ ^(https?://[^ ]+)\ \[(.*)\]$ ]]; then
		url="${BASH_REMATCH[1]}"
		techs_raw="${BASH_REMATCH[2]}"
		# Convert techs to JSON array
		techs_json=$(printf '%s\n' "$techs_raw" | tr ',' '\n' | jq -R . | jq -s .)
		emit_ndjson "tech_detect.txt" "$url" null null "$techs_json" >> "$OUTFILE"
	else
		# Fallback: just a URL without stack info
		emit_ndjson "tech_detect.txt" "$line" null null '[]' >> "$OUTFILE"
	fi
done < "$TECH_FILE"

### --- Complete status -----------------------------------------

echo "[✓] NDJSON output written to $OUTFILE"
