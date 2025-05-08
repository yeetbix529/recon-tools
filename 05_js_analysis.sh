#!/bin/bash

# === module: 06_js_analysis.sh ===
# Desciption: 
# use gau, and waybackurls to retrieve 
# javascript files for analysis
# 

# === step 0: input arguments and validation
TARGET="$1"
INPUT_FILE="/home/kali/bugBounty/bugBounty_v2/recon/$TARGET/http/200.txt"
OUTDIR="recon/$TARGET/javascript"
mkdir -p "$OUTDIR"

if [ -z "$TARGET" ]; then
	echo "Usage: $0 <target-name>"
	exit 1
fi

echo "[*] Starting JavaScript file analysis..."

# === step 1: gather javascript files using gau ===
echo "[*] Collecting JS file URLs with gau..."
  while read -r LINE; do
 	DOMAIN=$(echo "$LINE" | awk '{print $1}')
 	echo "$DOMAIN"
 	gau "$DOMAIN" | grep "\.js$" >> "$OUTDIR/js_urls.txt" 
  done < "$INPUT_FILE"

# waybackurls (optional)
# currently not implemented

# remove duplicate javascript urls
cat "$OUTDIR/${TARGET}_js_urls.txt" | sort -u > "$OUTDIR/${TARGET}_js_url1.txt"

total=$(wc -l < "$OUTDIR/${TARGET}_js_urls.txt")
sort -u "$OUTDIR/${TARGET}_js_urls.txt" > "$OUTDIR/${TARGET}_js_url1.txt"
unique=$(wc -l < "$OUTDIR/${TARGET}_js_url1.txt")
duplicates=$((total - unique))

echo "[✓] Total JS URLs found      : $total"
echo "[✓] Unique JS URLs           : $unique"
echo "[✓] Duplicate JS URLs removed: $duplicates"
