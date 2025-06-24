# === module 08_ndjson_converter.sh ===
# Description: converts .txt file output to .ndjson
# format ideal for elastic stack integration.

# --- Setup ---------------
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# --- configuration -------
TARGET="$1"
BASE_DIR="recon/$TARGET/"
OUTPUT_FILE="$BASE_DIR"
TECH_FILE="$BASE_DIR/tech-detect/${TARGET}_httpx.txt"
SUB_FILE="$BASE_DIR/subdomains/${TARGET}_"
HTTP_FILE="$BASE_DIR/http/${TARGET}_"
DNS_FILE="$BASE_DIR/dns/${TARGET}_"
