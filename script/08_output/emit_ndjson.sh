### --- output structure prep -------------------------------
emit_ndjson() {
	local source="$1"
	local value="$2"
	local status_code="$3"
	local in_scope="$4"
	local technologies="${5:-[]}"
	jq -nc \
		--arg target "$TARGET" \
		--arg source "$source" \
		--arg value "$value" \
		--argjson status_code "$status_code" \
		--argjson in_scope "$in_scope" \
		--argjson technologies "$technologies" \
		'{target: $target, source: $source, value: $value, status_code: $status_code, in_scope: $in_scope, technologies: $technologies}'
}
