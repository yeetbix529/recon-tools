#!/bin/bash

# === module: config.sh ===
# Description:
# centralised variable management
#

# - - - - [ General Settings ] - - - - 
TARGET_NAME="Epic Games"

# - - - - [ Directory Structure ] - - - -
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RECON_DIR="$BASE_DIR/recon"
SCRIPTS_DIR="$BASE_DIR/scripts"
TARGET_DIR="$RECON_DIR/$TARGET_NAME"

# - - - - [ Phase Output Dirs ] - - - -
NDJSON_DIR="$TARGET_DIR/ndjson"
DNS_DIR="$TARGET_DIR/dns"
HTTP_DIR="$TARGET_DIR/http"
JS_DIR="$TARGET_DIR/javascript"
SUBS_DIR="$TARGET_DIR/subdomains"
TECH_DIR="$TARGET_DIR/tech-detect"

# - - - - [ Input Files ] - - - -
SCOPE_FILE="$TARGET_DIR/${TARGET_NAME}_scope.txt"
OOS_FILE="$TARGET_DIR/${TARGET_NAME}_out_of_scope.txt"

# - - - - [ NDJSON Phase Output ] - - - -
NDJSON_SCOPE="$NDJSON_DIR/01_scope.ndjson"
NDJSON_SUBS="$NDJSON_DIR/02_subs.ndjson"
NDJSON_DNS="$NDJSON_DIR/03_dns.ndjson"
NDJSON_HTTP="$NDJSON_DIR/04_http.ndjson"
NDJSON_JS="$NDJSON_DIR/05_js.ndjson"
NDJSON_SECRETS="$NDJSON_DIR/06_secrets.ndjson"
NDJSON_TECH="$NDJSON_DIR/07_tech.ndjson"
NDJSON_FINAL="$NDJSON_DIR/final.ndjson"

# - - - - [ Tool Configuration Defaults (optional) ] - - - -
SECRETFINDER_DIR="$BASE_DIR/secretfinder"
