#!/bin/bash

# === module: 03_dns_resolution.sh ===
# Description:
#  resolves the domain name system using dnsx
#  and saves results per target.
#

# === step 0: input arguments and validation
TARGET="$1"
INPUT_FILE="recon/$TARGET/subdomains/filtered.txt"
OUTPUT_DIR="recon/$TARGET/dns"
mkdir -p "recon/$TARGET/dns"

if [ -z "$TARGET" ]; then
	echo "Usage: $0 <target-name>"
	echo "Example: 03_dns_resolution.sh NBA Public Bug Bounty"
	exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
	echo "[!] input file not found: $INPUT_FILE"
	exit 1
fi

# === step 1: resolve dns using dnsx
echo "[*] Resolving domains..."

dnsx -silent -a -resp -json -retry 2 -rl 300 -l "$INPUT_FILE" > dnsx_output.js
mv "dnsx_output.js" "$OUTPUT_DIR/dnsx_output.js"
 
# === step 2: parse successful resolutions
jq -r '.host' "$OUTPUT_DIR/dnsx_output.js" | sort -u > "$OUTPUT_DIR/resolved.txt"
jq -r '"\(.host) -> \((.a // []) | join(",")) | \((.cname // []) | join(","))"'  "$OUTPUT_DIR/dnsx_output.js" > "$OUTPUT_DIR/resolved_with_ips.txt"

# === step 2: find unresolved subdomains
comm -23 <(sort "$INPUT_FILE") <(sort "$OUTPUT_DIR/resolved.txt") > "$OUTPUT_DIR/unresolved.txt"

echo "[+] Resolved: $(wc -l < "$OUTPUT_DIR/resolved.txt")"
echo "[+] Unresolved: $(wc -l < "$OUTPUT_DIR/unresolved.txt")"
