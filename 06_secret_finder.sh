#!/bin/bash

# === module: 06_secret_finder.sh ===
# Description: Scan remote JS files for secrets using SecretFinder

# === Step 0: Argument and input validation
TARGET="$1"
INPUT_FILE="/home/kali/bugBounty/bugBounty_v2/recon/$TARGET/javascript/js_urls.txt"
OUTPUT_DIR="/home/kali/bugBounty/bugBounty_v2/recon/$TARGET/javascript"
SECRETFINDER_DIR="/home/kali/bugBounty/bugBounty_v2/secretfinder"

if [ ! -f "$INPUT_FILE" ]; then
    echo "[!] File $INPUT_FILE does not exist. Exiting..."
    exit 1
fi

# === Step 1: Activate Python virtual environment
source $SECRETFINDER_DIR/venv/bin/activate

# === Step 2: Run SecretFinder on all filtered URLs
echo "[*] Starting SecretFinder on remote JS URLs..."
> "$OUTPUT_DIR/${TARGET}_raw.txt"

cat "$INPUT_FILE" | grep -i -v 'jquery\|bootstrap\|.min.js' | while read -r url; do
    echo "[*] Scanning $url" | tee -a "$OUTPUT_DIR/${TARGET}_raw.txt"
    python3 "$SECRETFINDER_DIR/SecretFinder.py" -i "$url" -o cli | tee -a "$OUTPUT_DIR/${TARGET}_raw.txt"
    echo "" >> "$OUTPUT_DIR/${TARGET}_raw.txt"
done

# === Step 3: Filter output for valid results
echo "[*] Filtering potential secrets from output..."

SECRET_KEYWORDS=('heroku' 'apikey' 'api[\s_-]?key' 'token' 'bearer' 'secret' 'authorization' 'access[_-]?key' 'jwt' 'refresh_token' 'supabase.auth.*' 'client_secret' 'session_token')

FILTERED_FILE="$OUTPUT_DIR/${TARGET}_filtered.txt"
> "$FILTERED_FILE"

grep -Ei "$(IFS='|'; echo "${SECRET_KEYWORDS[*]}")" "$OUTPUT_DIR/${TARGET}_raw.txt" | sort -u > "$FILTERED_FILE"

echo "[+] All done."
echo "[+] Raw output: $OUTPUT_DIR/${TARGET}_raw.txt"
echo "[+] Filtered secrets: $OUTPUT_DIR/${TARGET}_filtered.txt"
