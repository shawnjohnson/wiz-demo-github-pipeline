#!/bin/bash

# This script parses a Wiz vulnerability scan JSON report
# and generates a Markdown summary table of vulnerability counts.

# Accept the scan report path as the first argument.
# If no argument is provided, default to "wiz-vuln-scan.json".
SCAN_REPORT_PATH="${1:-wiz-vuln-scan.json}"

# Check if the provided (or default) file exists
if [ ! -f "$SCAN_REPORT_PATH" ]; then
    echo "Error: Scan report file not found at '$SCAN_REPORT_PATH'."
    exit 1
fi

# --- Function to get vulnerability counts using jq ---
get_vulnerability_count() {
    # $1: The path to the JSON file
    # $2: The specific vulnerability count key (e.g., "criticalCount", "highCount")
    jq -r ".result.analytics.vulnerabilities.${2}" "$1"
}

# --- Extract counts from the JSON report ---
CRITICAL_COUNT=$(get_vulnerability_count "${SCAN_REPORT_PATH}" "criticalCount")
HIGH_COUNT=$(get_vulnerability_count "${SCAN_REPORT_PATH}" "highCount")
MEDIUM_COUNT=$(get_vulnerability_count "${SCAN_REPORT_PATH}" "mediumCount")
LOW_COUNT=$(get_vulnerability_count "${SCAN_REPORT_PATH}" "lowCount")

# --- Generate the Markdown Executive Summary table ---
echo "### 🚨 Executive Summary"
echo ""
echo "This report summarizes the findings from the latest vulnerability scan of your repository."
echo "A total of $((CRITICAL_COUNT + HIGH_COUNT + MEDIUM_COUNT + LOW_COUNT)) vulnerabilities were identified across all severity levels."
echo ""
echo "| Severity | Count |"
echo "| :------- | :----: |"
echo "| ⚫ **Critical** | ${CRITICAL_COUNT} |"
echo "| 🔴 **High** | ${HIGH_COUNT} |"
echo "| 🟠 **Medium** | ${MEDIUM_COUNT} |"
echo "| 🟢 **Low** | ${LOW_COUNT} |"

# You can save this output to a file, e.g., 'vulnerability_summary.md'
# by redirecting the script's output: ./script_name.sh > vulnerability_summary.md
