#!/usr/bin/env bash
set -euo pipefail

# Template setup script for aerospike-repo
#
# Run this after creating a new repository from the aerospike-repo template.
# It replaces the template's working test values with your project's values.

echo "=== Aerospike Repository Template Setup ==="
echo ""
echo "This script replaces the template's default values with your project's values."
echo "Press Ctrl+C to cancel at any time."
echo ""

# --- Collect values ---

read -rp "Project display name (e.g., 'Aerospike Client Python'): " PROJECT_NAME
read -rp "Repository name (e.g., 'aerospike-client-python'): " REPO_NAME
read -rp "JFrog project name (e.g., 'client-python'): " JF_PROJECT
read -rp "JFrog build name (e.g., 'aerospike-client-python'): " JF_BUILD_NAME
read -rp "OIDC provider name (e.g., 'gh-prod'): " OIDC_PROVIDER
read -rp "OIDC audience (e.g., 'aerospike/client-python'): " OIDC_AUDIENCE

echo ""
echo "CodeQL language options: cpp, csharp, go, java-kotlin, javascript-typescript, python, ruby, swift"
read -rp "CodeQL language (e.g., 'python'): " CODEQL_LANG

read -rp "GitHub CODEOWNERS (e.g., '@aerospike/team-name'): " CODEOWNERS_VALUE

echo ""
echo "=== Applying configuration ==="

# --- Replace CI/CD values in workflow files ---

replace_in_file() {
    local file="$1"
    local old="$2"
    local new="$3"
    if [[ -f "$file" ]]; then
        sed -i "s|${old}|${new}|g" "$file"
    fi
}

# cicd.yaml: replace JFrog and OIDC values
CICD_FILE=".github/workflows/cicd.yaml"
replace_in_file "$CICD_FILE" "jf-project: test" "jf-project: ${JF_PROJECT}"
replace_in_file "$CICD_FILE" "jf-build-name: test-build" "jf-build-name: ${JF_BUILD_NAME}"
replace_in_file "$CICD_FILE" "oidc-provider-name: gh-dev-test" "oidc-provider-name: ${OIDC_PROVIDER}"
replace_in_file "$CICD_FILE" "oidc-audience: aerospike/testing" "oidc-audience: ${OIDC_AUDIENCE}"

# codeql.yml: replace language
CODEQL_FILE=".github/workflows/codeql.yml"
replace_in_file "$CODEQL_FILE" "language: \\[python\\]" "language: [${CODEQL_LANG}]"
replace_in_file "$CODEQL_FILE" "/language:python" "/language:${CODEQL_LANG}"

# --- Replace project name placeholders in markdown files ---

find . -name "*.md" -not -path "./.git/*" -print0 | while IFS= read -r -d '' file; do
    sed -i "s|\[PROJECT_NAME\]|${PROJECT_NAME}|g" "$file"
    sed -i "s|\[REPOSITORY_NAME\]|${REPO_NAME}|g" "$file"
done

# --- Generate CODEOWNERS ---

cat > .github/CODEOWNERS <<EOF
* ${CODEOWNERS_VALUE}
EOF

echo "  Updated .github/workflows/cicd.yaml"
echo "  Updated .github/workflows/codeql.yml"
echo "  Updated markdown files with project name"
echo "  Generated .github/CODEOWNERS"

# --- Cleanup prompt ---

echo ""
read -rp "Delete setup files (setup.sh and SETUP.md)? [y/N]: " DELETE_SETUP
if [[ "${DELETE_SETUP,,}" == "y" ]]; then
    rm -f setup.sh SETUP.md
    echo "  Deleted setup.sh and SETUP.md"
fi

echo ""
echo "=== Setup complete! ==="
echo ""
echo "Remaining manual steps:"
echo ""
echo "  1. Update the build-script in .github/workflows/cicd.yaml"
echo "     The current script creates a dummy artifact. Replace it with your"
echo "     actual build commands."
echo ""
echo "  2. Add required secrets to your GitHub repository settings:"
echo "     - GPG_SECRET_KEY   (GPG private key for artifact signing)"
echo "     - GPG_PUBLIC_KEY   (GPG public key)"
echo "     - GPG_PASS         (GPG key passphrase)"
echo ""
echo "  3. (Optional) Add NuGet signing secrets if publishing .nupkg files:"
echo "     - ES_USERNAME, ES_PASSWORD, CREDENTIAL_ID, ES_TOTP_SECRET"
echo ""
echo "  4. Uncomment your package ecosystem in .github/dependabot.yml"
echo "     (pip, npm, gomod, or docker)"
echo ""
echo "  5. Review and customize README.md for your project"
echo ""
echo "  6. (Optional) Add matrix-json to cicd.yaml for multi-distro builds"
echo ""
echo "For CI/CD documentation, see:"
echo "  https://github.com/aerospike/shared-workflows"
