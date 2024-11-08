#!/usr/bin/env bats

setup() {
    # Get the absolute path of the script directory
    SCRIPT_DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    SCRIPT_PATH="${SCRIPT_DIR}/anyform"
    
    # Ensure the script is executable
    chmod +x "$SCRIPT_PATH"
    
    # Create mock bin directory
    MOCK_BIN_DIR="$(mktemp -d)"
    mkdir -p "${MOCK_BIN_DIR}"
    
    # Create mock git script
    cat > "${MOCK_BIN_DIR}/git" << 'EOF'
#!/bin/sh
case "$1" in
    "clone")
        mkdir -p "/tmp/terraform-provider-corner"
        ;;
    "init"|"add"|"commit"|"tag")
        return 0
        ;;
    "fetch")
        echo "Fetching..."
        ;;
    "rev-parse")
        if [ "$2" = "--quiet" ] && [ "$3" = "--verify" ] && [ "$4" = "abc123^{commit}" ]; then
            # Explicitly fail for test commit
            exit 1
        fi
        if [ "$2" = "--quiet" ] && [ "$3" = "--verify" ]; then
            # For other commits, check if they exist
            echo "$4" | grep -q "abc123" && exit 1 || exit 0
        fi
        echo "master"
        ;;
    "checkout")
        echo "Switching to $2"
        ;;
    "describe")
        echo "v1.0.0"
        ;;
    "symbolic-ref")
        echo "refs/remotes/origin/master"
        ;;
    *)
        echo "Git command $1"
        ;;
esac
exit 0
EOF
    chmod +x "${MOCK_BIN_DIR}/git"

    # Create mock go script
    cat > "${MOCK_BIN_DIR}/go" << 'EOF'
#!/bin/sh
case "$1" in
    "build")
        touch terraform-provider-corner_v1.0.0
        ;;
    "env")
        case "$2" in
            "GOOS")
                echo "darwin"
                ;;
            "GOARCH")
                echo "amd64"
                ;;
        esac
        ;;
esac
exit 0
EOF
    chmod +x "${MOCK_BIN_DIR}/go"

    # Add mock bin to PATH
    PATH="${MOCK_BIN_DIR}:$PATH"
    
    # Create temporary test directory
    TEST_TEMP_DIR="$(mktemp -d)"
    
    # Mock git repository setup
    mkdir -p "${TEST_TEMP_DIR}/terraform-provider-corner"
    MOCK_REPO="https://github.com/hashicorp/terraform-provider-corner"
}

teardown() {
    # Clean up temporary directory
    rm -rf "${TEST_TEMP_DIR}"
    rm -rf "${MOCK_BIN_DIR}"
    rm -rf "/tmp/terraform-provider-corner"
}

# Function to extract version from the script
get_version() {
    grep '^VERSION=' "$SCRIPT_PATH" | cut -d '"' -f 2
}

# Mock functions to override external commands
mock_git() {
    case "$1" in
        "clone")
            mkdir -p "/tmp/terraform-provider-corner"
            ;;
        "fetch")
            return 0
            ;;
        "rev-parse")
            echo "abcd1234"
            ;;
        "checkout")
            return 0
            ;;
        "describe")
            echo "v1.0.0"
            ;;
        *)
            return 0
            ;;
    esac
}

mock_go_build() {
    echo "Mocked go build"
    touch terraform-provider-corner_v1.0.0
    return 0
}

@test "prints usage when no arguments provided" {
    run "$SCRIPT_PATH"
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" =~ "Usage:" ]]
}

@test "prints help message with --help flag" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ "Usage:" ]]
}

@test "prints version with --version flag" {
    VERSION=$(get_version)
    run "$SCRIPT_PATH" --version
    echo "output: $output, version: $VERSION"  # Debug output
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "AnyForm version ${VERSION}"
}

@test "validates repository address format" {
    run "$SCRIPT_PATH" "invalid-repo-address"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "Error: Unable to extract organization from repository address" ]]
}

@test "accepts valid repository address" {
    run "$SCRIPT_PATH" "${MOCK_REPO}"
    
    echo "output: $output"
    echo "status: $status"
    
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Organization: hashicorp" ]]
    [[ "${output}" =~ "Provider Type: corner" ]]
}

@test "handles print configuration flag" {
    run "$SCRIPT_PATH" -p "${MOCK_REPO}"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "required_providers" ]]
}

@test "validates commit version when provided" {
    # No need to export mock functions as we're using PATH
    run "$SCRIPT_PATH" "${MOCK_REPO}" "abc123"
    
    echo "output: $output"
    echo "status: $status"
    
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "Failed to verify commit" ]]
}

@test "processes tagged version correctly" {
    export -f mock_go_build
    cd "${TEST_TEMP_DIR}/terraform-provider-corner"
    TAGGED_VERSION="v1.0.0"
    run "$SCRIPT_PATH" "${MOCK_REPO}" "${TAGGED_VERSION}"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Checked out version: ${TAGGED_VERSION}" ]]
}

@test "handles pull request URL" {
    run "$SCRIPT_PATH" "https://github.com/hashicorp/terraform-provider-corner/pull/123"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Fetching Pull Request #123" ]]
    [[ "${output}" =~ "Organization: hashicorp" ]]
    [[ "${output}" =~ "Provider Type: corner" ]]
}

@test "fails gracefully with invalid PR URL" {
    run "$SCRIPT_PATH" "https://github.com/hashicorp/terraform-provider-corner/pull/abc"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "Error: Invalid pull request number" ]]
}

@test "checks self-update with current version" {
    VERSION=$(get_version)
    # Mock curl to return current version
    function curl() {
        echo "{\"tag_name\": \"$VERSION\"}"
    }
    export -f curl
    
    run "$SCRIPT_PATH" --self-update
    echo "output: $output"  # Debug output
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Already running the latest version"
}

@test "check for updates when on latest version" {
    VERSION=$(get_version)
    function curl() {
        echo "{\"tag_name\": \"$VERSION\"}"
    }
    export -f curl
    
    run "$SCRIPT_PATH" --check-update
    echo "output: $output"  # Debug output
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "You are running the latest version"
}

@test "check for updates when update available" {
    VERSION=$(get_version)
    if ! [[ "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        skip "Current version is not in semantic version format"
    fi
    
    # Calculate next version by incrementing patch number
    NEW_VERSION="v$(echo $VERSION | sed 's/^v//' | awk -F. '{print $1"."$2"."$3+1}')"
    
    function curl() {
        # Ensure we return a valid version string
        echo "{\"tag_name\": \"$NEW_VERSION\"}"
    }
    export -f curl
    
    run "$SCRIPT_PATH" --check-update
    echo "output: $output"  # Debug output
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Update available: $VERSION -> $NEW_VERSION" ]]
    [[ "$output" =~ "Run 'anyform --self-update' to update" ]]
}
