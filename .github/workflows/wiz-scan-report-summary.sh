#!/bin/bash

# This script parses a Wiz vulnerability scan JSON report
# and generates a complete Markdown summary report.

# Accept the scan report path as the first argument.
# If no argument is provided, default to "wiz-vuln-scan.json".
SCAN_REPORT_PATH="${1:-wiz-vuln-scan.json}"

# Check if the provided (or default) file exists
if [ ! -f "$SCAN_REPORT_PATH" ]; then
    echo "Error: Scan report file not found at '$SCAN_REPORT_PATH'."
    exit 1
fi

# --- Function to get a specific value using jq ---
get_json_value() {
    # $1: The path to the JSON file
    # $2: The jq filter for the desired value
    jq -r "${2}" "$1"
}

# --- Extract image name ---
IMAGE_NAME=$(get_json_value "${SCAN_REPORT_PATH}" ".scanOriginResource.name // \"N/A\"")

# --- Extract vulnerability counts ---
VULN_CRITICAL_COUNT=$(get_json_value "${SCAN_REPORT_PATH}" ".result.analytics.vulnerabilities.criticalCount")
VULN_HIGH_COUNT=$(get_json_value "${SCAN_REPORT_PATH}" ".result.analytics.vulnerabilities.highCount")
VULN_MEDIUM_COUNT=$(get_json_value "${SCAN_REPORT_PATH}" ".result.analytics.vulnerabilities.mediumCount")
VULN_LOW_COUNT=$(get_json_value "${SCAN_REPORT_PATH}" ".result.analytics.vulnerabilities.lowCount")
TOTAL_VULN_COUNT=$(get_json_value "${SCAN_REPORT_PATH}" ".result.analytics.vulnerabilities.totalCount")


# --- Extract other finding counts ---
EOL_COUNT=$(get_json_value "${SCAN_REPORT_PATH}" ".result.endOfLifeTechnologies | length")
SECRETS_COUNT=$(get_json_value "${SCAN_REPORT_PATH}" ".result.analytics.secrets.totalCount")
DATA_FINDINGS_COUNT=$(get_json_value "${SCAN_REPORT_PATH}" ".result.dataFindings | length")
MALWARE_COUNT=$(get_json_value "${SCAN_REPORT_PATH}" ".result.analytics.malware.totalCount")


# --- Generate the Markdown Report ---

# Header Section
echo "# :shield: Wiz CLI Container Image Scan Report :crystal_ball:"
echo ""
echo "**Scanned Image:** ${IMAGE_NAME}"
echo ""
echo "---"
echo ""

# Summary Section
echo "## 🚨 Summary"
echo ""
echo "| Finding Type | Count |"
echo "| :---------------------- | :----: |"
echo "| **Total Vulnerabilities** | ${TOTAL_VULN_COUNT} |"
echo "| 🟢 Low Vulnerabilities | ${VULN_LOW_COUNT} |"
echo "| 🟠 Medium Vulnerabilities | ${VULN_MEDIUM_COUNT} |"
echo "| 🔴 High Vulnerabilities | ${VULN_HIGH_COUNT} |"
echo "| ⚫ Critical Vulnerabilities | ${VULN_CRITICAL_COUNT} |"
echo "| --- | --- |"
echo "| ☠️ **End of Life (EOL) Technologies** | ${EOL_COUNT} |"
echo "| 🔑 **Secrets** | ${SECRETS_COUNT} |"
echo "| 🔍 **Data Findings** | ${DATA_FINDINGS_COUNT} |"
echo "| 🦠 **Malware** | ${MALWARE_COUNT} |"
echo ""
echo "---"
echo ""

# Critical & High Severity Issues Section
echo "### ❗ **Critical & High Severity Findings**"
echo ""
echo "The following vulnerabilities are considered **critical or high severity** and require immediate attention."
echo ""
echo "| Vulnerability ID / Name | Affected Package / Component | Version | Severity | Remediation Strategy |"
echo "| :---------------------- | :--------------------------- | :------: | :--------: | :------------------- |"

# Extract and format Critical and High vulnerabilities from osPackages
jq -r '.result.osPackages[] | .name as $pkg_name | .version as $pkg_version | .vulnerabilities[] | select(.severity == "CRITICAL" or .severity == "HIGH") | "\(.name) | \($pkg_name) | \($pkg_version) | **\(.severity)** | \(if .fixedVersion then "Upgrade to version \(.fixedVersion) or later" else "Consult package documentation" end)"' "$SCAN_REPORT_PATH" | while IFS= read -r line; do
    echo "| ${line} |"
done

# Extract and format Critical and High vulnerabilities from endOfLifeTechnologies
jq -r '.result.endOfLifeTechnologies[] | .name as $eol_name | .version as $eol_version | .vulnerabilities[] | select(.severity == "CRITICAL" or .severity == "HIGH") | "\(.name) | EOL: \($eol_name) | \($eol_version) | **\(.severity)** | \(if .fixedVersion then "Upgrade to version \(.fixedVersion) or later" else "Upgrade EOL technology to a supported version" end)"' "$SCAN_REPORT_PATH" | while IFS= read -r line; do
    echo "| ${line} |"
done

# If no critical/high vulnerabilities were found, add a placeholder row
if ! jq -e '.result.osPackages[].vulnerabilities[] | select(.severity == "CRITICAL" or .severity == "HIGH")' "$SCAN_REPORT_PATH" > /dev/null && \
   ! jq -e '.result.endOfLifeTechnologies[].vulnerabilities[] | select(.severity == "CRITICAL" or .severity == "HIGH")' "$SCAN_REPORT_PATH" > /dev/null; then
    echo "| No Critical or High severity issues found. | | | |"
fi

echo ""
echo "---"
echo ""

# Detailed Findings & Next Steps Section
echo "### 🔍 **Detailed Findings & Next Steps**"
echo ""
echo "For a comprehensive breakdown of all identified findings, including medium and low severity issues, detailed descriptions, and specific fix recommendations, please refer to the full scan report."
echo ""
echo "* **View Full Report:** $(get_json_value "${SCAN_REPORT_PATH}" ".reportUrl // \"[Link to your CI/CD scan report, GitHub Security tab, or scan tool dashboard]\"")"
echo "* **Action Plan:**"
echo "    * Prioritize critical and high-severity vulnerabilities."
echo "    * Address findings by upgrading dependencies, applying patches, refactoring code, or reconfiguring as recommended."
echo "    * Re-run scans after implementing fixes to confirm resolution."
