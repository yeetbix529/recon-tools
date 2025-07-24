#!/bin/bash
source "$(dirname "$0")/../lib/config.sh"

# === module: 05_endpoint_analysis.sh ===
# Description:
# uses Get All Urls (gau) for endpoint retrieval
#

# == step 0: system check ===
mkdir -p "$TARGET_DIR"

if [ -z "$TARGET_NAME" ]; then
	echo "[!] Target not found"
	exit 1
fi

if [ ! -f "$HTTP_DIR/200.txt" ]; then
	echo "[!] Scope file not found: $HTTP_DIR/200.txt"
	exit 1
fi

echo "[*] Starting JavaScript file analysis..."

# === step 1: file cleanup ===
cat "$HTTP_DIR/200.txt" | 
sed -E 's|https?://||; s|/.*||' | 
sort -u > "$JS_DIR/domains.txt"

# === step 2: run gau ===
cat "$JS_DIR/domains.txt" | 
gau --threads 10 --subs --blacklist png,jpg,gif,svg --o "$JS_DIR/gau_output.txt"

# == step 3: filters ===
echo "[*] Filtering interesting endpoints..."

RAW_OUTPUT="$JS_DIR/gau_output.txt"
FILTERED_OUTPUT="$JS_DIR/gau_filtered.txt"

ENDPOINT_KEYWORDS=(
    '(/|=)(token|auth|key|password|secret|jwt|bearer)[/=]?'
    'login'
    'register'
    'signup'
    'reset'
    'forgot'
    'activate'
    'callback'
    'redirect'
    'debug'
    'admin'
    'panel'
    'config'
    '\.env'
    'sitemap\.xml'
    '\.php'
    '\.json'
    '\.xml'
    '\.jsp'
    '\.aspx?'
    'signature='
    'license'
)

echo "Filtering and deduplicating results..."
grep -Ei "$(IFS='|'; echo "${ENDPOINT_KEYWORDS[*]}")" "$RAW_OUTPUT" | sort -u > "$FILTERED_OUTPUT"
total_secrets=$(wc -l < "$FILTERED_OUTPUT")

grep -Ei '\.js(\?|$)' "$JS_DIR/gau_output.txt" > "$JS_DIR/js_endpoints.txt"
echo "Total unique potential endpoints: $total_secrets"

# notes
# - should be possible to use kibana filters for intersting endpoints.
# - prepare a javascript list for secretfinder.
#
