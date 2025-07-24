#!/bin/bash

# === helper.sh ===
# Common utility functions for recon and analysis scripts

# === deduplication_results
# Filters lines matching secret-related keywords and deduplicates them.
deduplicate_results() {
	local input_file="$1"
	local output_file="$2"
	shift 2
	local keywords=("$@")

	if [[ ! -f "$input_file" ]]; then
		echo "[!] File not found: $input_file"
		return 1
	fi

	grep -Ei "$(IFS='|'; echo "${keywords[*]}")" "$input_file" \
		| sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
		| sed 's/[[:space:]]\+/ /g' \
		| awk '!seen[tolower($0)]++' \
		> "$output_file"

	echo "[+] Deduplicated output written to: $output_file"
}

# === secret_keywords
# If not defined elsewhere, define your default keyword list here


# === print_line_count
print_line_count() {
	local file="$1"
	if [[ -f "$file" ]]; then
		local count
		count=$(wc -l < "$file")
		echo "[+] $count lines in $file"
	else
		echo "[!] File not found: $file"
	fi
}

# === debug_log
log_info() {
	echo -e "[*] $*"
}

log_success() {
	echo -e "[+] $*"
}

log_error() {
	echo -e "[!] $*" >&2
}
