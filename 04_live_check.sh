#!/bin/bash

# === module: 04_live_check.sh
# Description:
# 
#
# === step 0: input arguments and validation
TARGET="$1"
INPUT_FILE="recon/$TARGET/dns/resolved.txt"
OUTPUT_DIR="recon/$TARGET/http"

if [ -z "$TARGET" ]; then
	echo "Usage: $0 <target-name>"
	exit 1
fi

mkdir -p "$OUTPUT_DIR"

# === step 1: check for live hosts using httpx
echo "[*] Probing live hosts for $TARGET..."
httpx -l "$INPUT_FILE" -status-code -silent -nc -o "${OUTPUT_DIR}/all_results.txt"

# === step 2: status-code filter
grep -v "\[200\]" "${OUTPUT_DIR}/all_results.txt" > "${OUTPUT_DIR}/non_200.txt"
grep "\[200\]" "${OUTPUT_DIR}/all_results.txt" | sed 's/ \[200\]//' > "${OUTPUT_DIR}/200.txt"

rm "${OUTPUT_DIR}/all_results.txt"

echo "[✓] Active live hosts saved to ${OUTPUT_DIR}/200.txt"
echo "[✓] Hosts not active saved to ${OUTPUT_DIR}/non_200.txt"
