#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#
#
#

### --- colours ---------------------------------------------
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[-]${NC} $*"; }

### --- configuration ---------------------------------------
TARGET="$1"
BASE_DIR="recon/$TARGET"
INPUT_FILE="$BASE_DIR/http/200.txt"
RAW_OUTPUT="$BASE_DIR/javascript/${TARGET}_raw.txt"
FILTERED_OUTPUT="$BASE_DIR/javascript/${TARGET}_filtered.txt"
mkdir -p "$BASE_DIR/javascript"

### --- prep -----------------------------------------------
if [ ! -f "$INPUT_FILE" ]; then
	error "Input file not found: $INPUT_FILE"
	exit 1
fi

if [ ! -d "$BASE_DIR" ]; then
  error "Base directory for target not found: $BASE_DIR"
  exit 1
fi

### -- step 1: gather javascript files ---------------------
urls=( $(grep -iEv 'jquery|bootstrap|\.min\.js' "$INPUT_FILE") )
total_urls=${#urls[@]}
log "Found $total_urls URLs to scan."

for url in "${urls[@]}"; do
	log "Scanning $url"
	before_count=$( [ -f "$RAW_OUTPUT" ] && grep -E '^https?://[^ ]+\.js($|\?)' "$RAW_OUTPUT" | wc -l || echo 0 )

	gau "$url" --verbose \
  	#| grep -E '^https?://[^ ]+\.js($|\?)' 
  	#| grep -ivE 'jquery|bootstrap|\.min\.js|\.json|\.jsp|\.js\.' 
  	 tee -a "$RAW_OUTPUT" >/dev/null

	after_count=$( [ -f "$RAW_OUTPUT" ] && grep -E '^https?://[^ ]+\.js($|\?)' "$RAW_OUTPUT" | wc -l || echo 0 )
	found=$((after_count - before_count))
	
	#if ((found > 0)); then
	#	log " -> Found $found javascript files in this URL"
	#else
	#	log " -> No javascript files found"
	#fi
done

sort -u "$RAW_OUTPUT" -o "$RAW_OUTPUT"
log "Deduplicated JS files saved to $RAW_OUTPUT"


