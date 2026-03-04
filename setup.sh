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

REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
echo "Repository: ${REPO_NAME}"
echo ""

read -rp "Project display name (default: ${REPO_NAME}): " PROJECT_NAME
PROJECT_NAME="${PROJECT_NAME:-${REPO_NAME}}"

read -rp "JFrog project name (default: test): " JF_PROJECT
JF_PROJECT="${JF_PROJECT:-test}"

read -rp "JFrog build name (default: test-build): " JF_BUILD_NAME
JF_BUILD_NAME="${JF_BUILD_NAME:-test-build}"

read -rp "OIDC provider name (default: gh-dev-test): " OIDC_PROVIDER
OIDC_PROVIDER="${OIDC_PROVIDER:-gh-dev-test}"

read -rp "OIDC audience (default: aerospike/testing): " OIDC_AUDIENCE
OIDC_AUDIENCE="${OIDC_AUDIENCE:-aerospike/testing}"

echo ""
read -rp "GitHub CODEOWNERS (e.g., '@aerospike/team-name'): " CODEOWNERS_VALUE

read -rp "Initial version (default: 0.0.1): " INITIAL_VERSION
INITIAL_VERSION="${INITIAL_VERSION:-0.0.1}"

echo ""
echo "Version strategy:"
echo "  1) VERSION file — version tracked in a file, update manually"
echo "  2) Git tags — create v${INITIAL_VERSION} tag, delete VERSION file"
read -rp "Choose [1/2] (default: 1): " VERSION_STRATEGY
VERSION_STRATEGY="${VERSION_STRATEGY:-1}"

echo ""
echo "=== Applying configuration ==="

# --- Replace CI/CD values in workflow files ---

replace_in_file() {
    local file="$1"
    local old="$2"
    local new="$3"
    if [[ -f "$file" ]]; then
        # Escape characters special in sed replacement: backslash, ampersand, delimiter
        local new_escaped="${new//\\/\\\\}"
        new_escaped="${new_escaped//&/\\&}"
        new_escaped="${new_escaped//|/\\|}"
        sed "s|${old}|${new_escaped}|g" "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
    fi
}

# cicd.yaml: replace JFrog and OIDC values
CICD_FILE=".github/workflows/cicd.yaml"
replace_in_file "$CICD_FILE" "jf-project: test" "jf-project: ${JF_PROJECT}"
replace_in_file "$CICD_FILE" "jf-build-name: test-build" "jf-build-name: ${JF_BUILD_NAME}"
replace_in_file "$CICD_FILE" "oidc-provider-name: gh-dev-test" "oidc-provider-name: ${OIDC_PROVIDER}"
replace_in_file "$CICD_FILE" "oidc-audience: aerospike/testing" "oidc-audience: ${OIDC_AUDIENCE}"

# --- Replace project name placeholders in markdown files ---

PROJECT_NAME_ESCAPED="${PROJECT_NAME//\\/\\\\}"
PROJECT_NAME_ESCAPED="${PROJECT_NAME_ESCAPED//&/\\&}"
PROJECT_NAME_ESCAPED="${PROJECT_NAME_ESCAPED//|/\\|}"
REPO_NAME_ESCAPED="${REPO_NAME//\\/\\\\}"
REPO_NAME_ESCAPED="${REPO_NAME_ESCAPED//&/\\&}"
REPO_NAME_ESCAPED="${REPO_NAME_ESCAPED//|/\\|}"
find . -name "*.md" -not -path "./.git/*" -print0 | while IFS= read -r -d '' file; do
    sed "s|\[PROJECT_NAME\]|${PROJECT_NAME_ESCAPED}|g" "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
    sed "s|\[REPOSITORY_NAME\]|${REPO_NAME_ESCAPED}|g" "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
done

# --- Generate CODEOWNERS ---

cat > .github/CODEOWNERS <<EOF
* ${CODEOWNERS_VALUE}
EOF

# --- Set up versioning ---

if [[ "$VERSION_STRATEGY" == "2" ]]; then
    rm -f VERSION
    if git rev-parse "v${INITIAL_VERSION}" >/dev/null 2>&1; then
        echo "  Git tag v${INITIAL_VERSION} already exists; skipping tag creation"
    else
        git tag "v${INITIAL_VERSION}"
        echo "  Created git tag v${INITIAL_VERSION}"
    fi
    echo "  Deleted VERSION file (using tag-based versioning)"
else
    echo "${INITIAL_VERSION}" > VERSION
    echo "  Updated VERSION file to ${INITIAL_VERSION}"
fi

echo "  Updated .github/workflows/cicd.yaml"
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
