#!/bin/bash

# === module: 07_tech_detech.sh ===
# Description:
# Use tools such as wafw00f, httpx, and whatweb
# =================================

# === step 0: input arguments and validation
TARGET="$1"
INPUT_FILE="/home/kali/bugBounty/bugBounty_v2/recon/$TARGET/http/200.txt"
OUTPUT_DIR="/home/kali/bugBounty/bugBounty_v2/recon/$TARGET/tech-detect"
HTTPX_OUT="$OUTPUT_DIR/${TARGET}_httpx.txt"
WHATWEB_OUT="$OUTPUT_DIR/${TARGET}_whatweb.txt"
WAFWOOF_OUT="$OUTPUT_DIR/${TARGET}_wafw00f.txt"

if [ -z "$TARGET" ]; then 
	echo "Usage: $0 <target-name>"
	exit 1
fi

mkdir -p "$OUTPUT_DIR"

# step 1: tech-detect scanning

# use httpx
echo "Scanning $INPUT_FILE"
httpx -l "$INPUT_FILE" -tech-detect -silent -nc -o "$HTTPX_OUT"

# use whatweb
echo "Scanning $INPUT_FILE"
whatweb -i "$INPUT_FILE" --color=never >> "$WHATWEB_OUT"

# use wafw00f
echo ""
wafw00f --no-colors -i "$INPUT_FILE" -o "$WAFWOOF_OUT"
