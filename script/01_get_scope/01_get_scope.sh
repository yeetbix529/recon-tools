#!/bin/bash

# === module: 01_get_scope.sh ===
# Description:
# 
#

# === step 0: variable intialisation ===

PLATFORM="$1"
TARGET="$2"
BASE_DIR="/home/kali/bugBounty/bugBounty_v2/"

if [ -z "$TARGET" ] || [ -z "$PLATFORM" ]; then
	echo "Usage: $0 <platform-name> <target-name>"
	echo "Supported Platforms: hackerone, yeswehack, intigriti"
	echo "Example: 01_get_scope.sh hackerone NBA Public Bug Bounty"
	exit 1
fi

mkdir -p "../../recon/$TARGET"

# === step 1: fetch latest scope data ===

if [ ! -d "bounty-targets-data" ]; then
	git clone https://github.com/arkadiyt/bounty-targets-data.git
fi

cd bounty-targets-data || exit 1
git pull > /dev/null

# === step 2: choose json file for data ===

case "$PLATFORM" in
	hackerone|bugcrowd|yeswehack|intigriti|federacy)
	  json_file="data/${PLATFORM}_data.json"
	  ;;
	*)
	  echo "[!] Unsupported platform: $PLATFORM"
	  exit 1
	  ;;
esac

if [ ! -f "$json_file" ]; then
  echo "[!] Data file not found: $json_file"
  exit 1
fi

# === step 3: extract in-scope targets based on platform ===

case "$PLATFORM" in
  hackerone)
    jq --arg TARGET "$TARGET" '
      .[]
      | select((.name | ascii_downcase) == ($TARGET | ascii_downcase))
      | .targets.in_scope[]?
      | select(.asset_type == "WILDCARD" or .asset_type == "URL")
      | .asset_identifier' "$json_file" \
      | tr -d '"' \
      | sort -u > "../${TARGET}_scope.txt"
      
      mv "../${TARGET}_scope.txt" "$BASE_DIR/recon/$TARGET/${TARGET}_scope.txt"
      echo "In-scope targets saved to ../../${TARGET}_scope.txt"
      
    jq --arg TARGET "$TARGET" '
      .[]
      | select((.name | ascii_downcase) == ($TARGET | ascii_downcase))
      | .targets.out_of_scope[]?
      | select(.asset_type == "WILDCARD" or .asset_type == "URL")
      | .asset_identifier' "$json_file" \
      | tr -d '"' \
      | sort -u > "../${TARGET}_out_of_scope.txt"
      
      mv "../${TARGET}_out_of_scope.txt" "$BASE_DIR/recon/$TARGET/${TARGET}_out_of_scope.txt"
      echo "Out of Scope targets saved to ../${TARGET}/${TARGET}_out_of_scope.txt"
    ;;
  intigriti)
    jq --arg TARGET "$TARGET" '
      .[]
      | select((.name | ascii_downcase) == ($TARGET | ascii_downcase))
      | .targets.in_scope[]?
      | select(.type == "wildcard" or .type == "url")
      | .endpoint' "$json_file" \
      | tr -d '"' \
      | sort -u > "../${TARGET}_scope.txt"
      
      mv "../${TARGET}_scope.txt" "../recon/$TARGET/${TARGET}_scope.txt"
      echo "In-scope targets saved to ../${TARGET}_scope.txt"
      
    jq --arg TARGET "$TARGET" '
      .[]
      | select((.name | ascii_downcase) == ($TARGET | ascii_downcase))
      | .targets.out_of_scope[]?
      | select(.type == "wildcard" or .type == "url")
      | .endpoint' "$json_file" \
      | tr -d '"' \
      | sort -u > "../${TARGET}_out_of_scope.txt"
      
      mv "../${TARGET}_out_of_scope.txt" "../recon/$TARGET/${TARGET}_out_of_scope.txt"
      echo "In-scope targets saved to ../${TARGET}_out_of_scope.txt"
    ;;
  yeswehack)
    jq --arg TARGET "$TARGET" '
      .[]
      | select((.name | ascii_downcase) == ($TARGET | ascii_downcase))
      | .targets.in_scope[]?
      | select(.type == "web-application")
      | .target' "$json_file" \
      | tr -d '"' \
      | sort -u > "../${TARGET}_scope.txt"
      
      mv "../${TARGET}_scope.txt" "../recon/$TARGET/${TARGET}_scope.txt"  
      echo "In-scope targets saved to ../${TARGET}_scope.txt"
      
    jq --arg TARGET "$TARGET" '
      .[]
      | select((.name | ascii_downcase) == ($TARGET | ascii_downcase))
      | .targets.out_of_scope[]?
      | select(.type == "web-application" or .type == "other")
      | .target' "$json_file" \
      | tr -d '"' \
      | sort -u > "../${TARGET}_out_of_scope.txt"
      
      mv "../${TARGET}_out_of_scope.txt" "../recon/$TARGET/${TARGET}_out_of_scope.txt"
      echo "out-of-scope targets saved to ../${TARGET}_out_of_scope.txt"
    ;;
  *)
    echo "[!] Unsupported platform"
    exit 1
    ;;
esac
