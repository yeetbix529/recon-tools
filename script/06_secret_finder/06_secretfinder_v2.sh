#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# === module 06_secretfinder_v2.sh ===
# Description: scan remote JS files for secrets using SecretFinder
# Improved logging, per-URL counts, and final summary

### --- colours ---------------------------------------------------
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[-]${NC} $*" >&2; }

### --- configuration ---------------------------------------------
TARGET="$1"
BASE_DIR="recon/$TARGET/javascript"
INPUT_FILE="$BASE_DIR/${TARGET}_raw.txt"
RAW_OUTPUT="$BASE_DIR/${TARGET}_secrets.txt"
FILTERED_OUTPUT="$BASE_DIR/${TARGET}_filtered.txt"
SECRETFINDER_DIR="/home/kali/bugBounty/bugBounty_v2/secretfinder"

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
)

### --- prep --------------------------------------------------------
if [ ! -f "$INPUT_FILE" ]; then
	error "Input file not found: $INPUT_FILE"
	exit 1
fi

log "Activating SecretFinder venv..."
if ! source "$SECRETFINDER_DIR/venv/bin/activate"; then
	error "Failed to activate virtualenv at $SECRETFINDER_DIR/venv"
	exit 1
fi

# clean up old outputs
> "$RAW_OUTPUT"
> "$FILTERED_OUTPUT"

### --- step 1: scan each url ----------------------------------------
urls=( $(grep -iEv 'jquery|bootstrap|\.min\.js' "$INPUT_FILE") )
total_urls=${#urls[@]}
log "Found $total_urls URLs to scan."

for url in "${urls[@]}"; do
	log "Scanning $url"
	before_count=$(wc -l < "$RAW_OUTPUT" || echo 0)
	python3 "$SECRETFINDER_DIR/SecretFinder.py" \
	 -i "$url" -o cli | tee -a "$RAW_OUTPUT" >/dev/null
	 echo >> "$RAW_OUTPUT"
	 after_count=$(wc -l < "$RAW_OUTPUT")
	 found=$(( after_count - before_count ))
	 if ((found > 0)); then
	 	log " -> Found $found potential secrets in this URL"
	 else
	 	log " -> No secrets found in this URL"
	 fi
done

### --- step 2: filter & deduplicate ----------------------------------
log "Filtering and deduplicating results..."
grep -Ei "$(IFS='|'; echo "${SECRET_KEYWORDS[*]}")" \
	"$RAW_OUTPUT" \
	| sort -u \
	> "$FILTERED_OUTPUT"
total_secrets=$(wc -l < "$FILTERED_OUTPUT")
log "Total unique potential secrets: $total_secrets"

### --- step 3: breakdown by keyword
if (( total_secrets > 0 )); then
	echo
	log "Breakdown by pattern:"
	for kw in "${SECRET_KEYWORDS[@]}"; do
		count=$(grep -Eic "$kw" "$FILTERED_OUTPUT" 2>/dev/null || true)
		if (( count > 0 )); then
			printf " • %s: %d\n" "$kw" "$count"
		fi
	done
fi

log "All done."
log "  • Raw output:      $RAW_OUTPUT"
log "  • Filtered output: $FILTERED_OUTPUT"
