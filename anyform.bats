#!/usr/bin/env bats

# Set up test environment before each test
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
# This is a mock Git implementation for testing the anyform script
# It simulates common Git commands used by anyform without requiring a real Git repository

case "$1" in
    clone)
        # Handle --quiet flag
        repo_url=""
        target_dir=""
        shift # consume 'clone'
        while [ $# -gt 0 ]; do
            case "$1" in 
                --quiet) shift ;; # ignore quiet
                *) 
                  if [ -z "$repo_url" ]; then repo_url="$1"; 
                  elif [ -z "$target_dir" ]; then target_dir="$1"; 
                  fi
                  shift ;;
            esac
        done
        if [ -n "$target_dir" ]; then 
            mkdir -p "$target_dir" || exit 1
            # Simulate creating a .git directory inside the cloned repo
            mkdir -p "$target_dir/.git" || exit 1
        else
            echo "Mock Git Error: Clone target directory not specified" >&2
            exit 1
        fi
        ;;
    fetch)
        # Handle --all, --tags, --quiet, and specific origin fetches
        # Simply echo and succeed for testing purposes
        echo "Mock Git: Fetching... ($*)" >&2
        ;;
    rev-parse)
        shift # consume 'rev-parse'
        verify=false
        quiet=false
        short=false # Added short flag
        ref=""
        while [ $# -gt 0 ]; do
            case "$1" in
                --quiet) quiet=true; shift ;; 
                --verify) verify=true; shift ;; 
                --short) short=true; shift ;; # Handle short flag
                HEAD) ref="HEAD"; shift ;; # Handle HEAD explicitly
                *) ref="$1"; shift ;; 
            esac
        done
        
        if [ "$verify" = true ]; then
            # Fail verification for the specific test commit 'abc123'
            if [[ "$ref" == *"abc123^{commit}"* ]]; then 
                # echo "Mock Git: Failing verification for $ref" >&2
                exit 1
            else
                # echo "Mock Git: Passing verification for $ref" >&2
                exit 0 # Succeed verification for others
            fi
        elif [ "$short" = true ] && [ "$ref" = "HEAD" ]; then
            # Handle git rev-parse --short HEAD - always return abcd123 for consistent testing
            echo "abcd123"
        elif [[ "$ref" == origin/* ]]; then 
             # Simulate getting commit hash for a remote branch - always return abcd123 for consistent testing
             echo "abcd123"
        elif [ -n "$ref" ]; then
             # For all refs, return abcd123 for consistent testing
             echo "abcd123"
        else
            echo "Mock Git Error: rev-parse requires a ref" >&2
            exit 1
        fi
        ;;
    checkout)
        shift # consume 'checkout'
        quiet=false
        target=""
        while [ $# -gt 0 ]; do
            case "$1" in 
                --quiet) quiet=true; shift ;; 
                *) target="$1"; shift ;; 
            esac
        done
        # echo "Mock Git: Checking out $target" >&2
        # Simulate successful checkout
        ;;
    describe)
        shift # consume 'describe'
        tags=false
        exact_match=false
        while [ $# -gt 0 ]; do
            case "$1" in 
                --tags) tags=true; shift ;; 
                --exact-match) exact_match=true; shift ;; 
                *) shift ;; # ignore other args
            esac
        done
        if [ "$exact_match" = true ]; then
            # Succeed only if the test is specifically for a tagged version
            if [[ "$BATS_TEST_NAME" == *"tagged version"* ]]; then
                echo "v1.0.0"
            else
                # Instead of failing with exit 1, return empty to ensure fallback to abcd123
                exit 1
            fi
        else 
            # For all non-exact-match describe calls, return abcd123 for consistent testing
            echo "abcd123"
        fi 
        ;;
    remote)
        # Handle 'remote show origin'
        if [ "$2" = "show" ] && [ "$3" = "origin" ]; then
            echo "* remote origin"
            echo "  Fetch URL: https://github.com/mock/repo.git"
            echo "  Push  URL: https://github.com/mock/repo.git"
            echo "  HEAD branch: main" # Changed to main for better default testing
            echo "  Remote branches:" # ... etc
        else
            echo "Mock Git Error: Unhandled remote command: $*" >&2
            exit 1
        fi
        ;;
    *) 
        echo "Mock Git Error: Unhandled command: $*" >&2
        exit 1
        ;;
esac
exit 0
EOF
    chmod +x "${MOCK_BIN_DIR}/git"

    # Create mock go script
    cat > "${MOCK_BIN_DIR}/go" << 'EOF'
#!/bin/sh
# This is a mock Go implementation for testing the anyform script
# It simulates common Go commands used by anyform without requiring a real Go environment

case "$1" in
    build)
        # Handle go build command with -o flag for output
        output_file=""
        shift # consume 'build'
        while [ $# -gt 0 ]; do
            if [ "$1" = "-o" ]; then
                output_file="$2"
                shift 2
                break
            fi
            shift
        done
        if [ -n "$output_file" ]; then
             # Create empty output file to simulate successful build
             touch "./$output_file" || exit 1 
        else
            echo "Mock Go Build Error: Missing -o argument" >&2
            exit 1
        fi
        ;;
    env)
        # Handle go env command to return platform information
        case "$2" in
            "GOOS")
                # Return operating system (always darwin/macOS for tests)
                echo "darwin"
                ;;
            "GOARCH")
                # Return architecture (always amd64 for tests)
                echo "amd64"
                ;;
        esac
        ;;
    *)
        echo "Mock Go Error: Unhandled command: $*" >&2
        exit 1
        ;;
esac
exit 0
EOF
    chmod +x "${MOCK_BIN_DIR}/go"

    # Create mock curl script with minimal functionality
    cat > "${MOCK_BIN_DIR}/curl" << 'EOF'
#!/bin/sh
# This is a minimal mock curl implementation for testing
# Individual tests can override this using function replacement
echo "Mocked curl"
exit 0
EOF
    chmod +x "${MOCK_BIN_DIR}/curl"

    # Add mock bin to PATH
    PATH="${MOCK_BIN_DIR}:/usr/bin:$PATH"
    
    # Create temporary test directory
    TEST_TEMP_DIR="$(mktemp -d)"
    
    # Mock git repository setup
    mkdir -p "${TEST_TEMP_DIR}/terraform-provider-corner"
    MOCK_REPO="https://github.com/hashicorp/terraform-provider-corner"

    # Set necessary environment variables for testing
    export REPO_ADDRESS=""
    export COMMIT_VERSION=""
    export TEMP_DIR=""

    # Backup original PATH
    ORIGINAL_PATH="$PATH"

    # Prepend MOCK_BIN_DIR to PATH
    PATH="${MOCK_BIN_DIR}:$ORIGINAL_PATH"
}

teardown() {
    # Restore the original PATH
    PATH="$ORIGINAL_PATH"

    # Clean up temporary directory
    rm -rf "${TEST_TEMP_DIR}"
    rm -rf "${MOCK_BIN_DIR}"
    rm -rf "/tmp/terraform-provider-corner"
}

# Function to extract version from the script
get_version() {
    grep '^VERSION=' "$SCRIPT_PATH" | cut -d '"' -f 2
}

# Test basic script operation: should show usage when no arguments are provided
@test "prints usage when no arguments provided" {
    run "$SCRIPT_PATH"
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" =~ "Usage:" ]]
}

# Test --help flag: should show help message and exit with success
@test "prints help message with --help flag" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ "Usage:" ]]
}

# Test --version flag: should show version information
@test "prints version with --version flag" {
    VERSION=$(get_version)
    run "$SCRIPT_PATH" --version
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "AnyForm version ${VERSION}"
}

# Test validation: should reject invalid repository address formats
@test "validates repository address format" {
    run "$SCRIPT_PATH" "invalid-repo-address"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "Error: Unable to extract organization from repository address" ]]
}

# Test happy path: process a valid repository address and install provider
@test "accepts valid repository address" {
    run "$SCRIPT_PATH" "${MOCK_REPO}"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Organization: hashicorp" ]]
    [[ "${output}" =~ "Provider Type: corner" ]]
    [[ "${output}" =~ "Default branch identified as: main" ]] # Check default branch detection
    [[ "${output}" =~ "Using version identifier for build: abcd123" ]] # Check fallback to short hash
    [[ "${output}" =~ "Installing binary to:" ]]
}

# Test configuration printing: should generate correct Terraform config block
@test "handles print configuration flag" {
    run "$SCRIPT_PATH" -p "${MOCK_REPO}"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "required_providers" ]]
    [[ "${output}" =~ "source  = \"registry.terraform.io/hashicorp/corner\"" ]]
    [[ "${output}" =~ "version = \"abcd123\"" ]] 
}

# Test commit version validation: should fail for non-existent commit
@test "validates commit version when provided" {
    run "$SCRIPT_PATH" "${MOCK_REPO}" "abc123"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "Error: Failed to verify commit/ref: abc123" ]]
}

# Test handling of tagged versions: should use the tag as version identifier
@test "processes tagged version correctly" {
    TAGGED_VERSION="v1.0.0"
    run "$SCRIPT_PATH" "${MOCK_REPO}" "${TAGGED_VERSION}"
    
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Checking out version: ${TAGGED_VERSION}" ]]
    [[ "${output}" =~ "Using version identifier for build: abcd123" ]] # Actual version from git rev-parse --short HEAD
    [[ "${output}" =~ "Building binary: terraform-provider-corner_abcd123" ]]
    
    # Check just for the presence of key elements instead of the exact path
    [[ "${output}" =~ "Installing binary to:" ]]
    [[ "${output}" =~ "terraform-provider-corner_abcd123" ]]
}

# Test processing of PR URLs: should fetch and use the PR branch
@test "handles pull request URL" {
    run "$SCRIPT_PATH" "https://github.com/hashicorp/terraform-provider-corner/pull/123"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Fetching Pull Request #123" ]]
    [[ "${output}" =~ "Using HEAD of PR #123 (pr-123)" ]]
    [[ "${output}" =~ "Checking out version: pr-123" ]]
    [[ "${output}" =~ "Using version identifier for build: abcd123" ]] # Fallback to short hash
    [[ "${output}" =~ "Installing binary to:" ]]
}

# Test self-update when already on latest version
@test "checks self-update with current version" {
    VERSION=$(get_version)
    function curl() {
        # Mock curl to return current version as latest
        echo "{\"tag_name\": \"$VERSION\"}"
    }
    export -f curl
    
    run "$SCRIPT_PATH" --self-update
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Already running the latest version"
}

# Test update check when on latest version
@test "check for updates when on latest version" {
    VERSION=$(get_version)
    function curl() {
        # Mock curl to return current version as latest
        echo "{\"tag_name\": \"$VERSION\"}"
    }
    export -f curl
    
    run "$SCRIPT_PATH" --check-update
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "You are running the latest version"
}

# Test update check when a newer version is available
@test "check for updates when update available" {
    VERSION=$(get_version)
    if ! [[ "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        skip "Current version is not in semantic version format"
    fi
    
    function curl() {
        # Mock curl to return a newer version
        if [[ "$*" == *"api.github.com"* ]]; then
            current_version=${VERSION#v}
            IFS='.' read -r major minor patch <<< "$current_version"
            new_patch=$((patch + 1))
            echo "{\"tag_name\": \"v$major.$minor.$new_patch\"}"
        else
            command curl "$@"
        fi
    }
    export -f curl
    
    run "$SCRIPT_PATH" --check-update
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Update available:" ]]
}

# Test dependency check: git is required
@test "fails when git is not installed" {
    # Temporarily set PATH to exclude git
    original_path="$PATH"
    # Create a temporary empty bin dir
    temp_bin="$(mktemp -d)"
    PATH="$temp_bin:/usr/bin:/bin" # Ensure no git is found

    run "$SCRIPT_PATH" "${MOCK_REPO}"
    [ "$status" -eq 1 ] # Should fail with status 1
    [[ "${output}" =~ "Error: git is not installed. Please install git and try again." ]]

    # Restore PATH and cleanup
    PATH="$original_path"
    rm -rf "$temp_bin"
}

# Test dependency check: curl is required
@test "fails when curl is not installed" {
    # Replace mock curl with one that exits with command not found error
    mv "${MOCK_BIN_DIR}/curl" "${MOCK_BIN_DIR}/curl_backup"
    echo -e '#!/bin/sh\nexit 127' > "${MOCK_BIN_DIR}/curl"
    chmod +x "${MOCK_BIN_DIR}/curl"

    run "$SCRIPT_PATH" --self-update

    [ "$status" -eq 1 ]
    [[ "${output}" =~ "Error: curl is not installed. Please install curl to continue." ]]

    # Restore original mock curl
    rm "${MOCK_BIN_DIR}/curl"
    mv "${MOCK_BIN_DIR}/curl_backup" "${MOCK_BIN_DIR}/curl"
}

# Test dependency check: go is required
@test "fails when go is not installed" {
    # Temporarily set PATH to exclude go, but include mock git/curl
    original_path="$PATH"
    # Keep mock git/curl, but exclude go
    PATH="${MOCK_BIN_DIR}:/usr/bin:/bin" 
    # Ensure mock go is not executable
    chmod -x "${MOCK_BIN_DIR}/go" 

    run "$SCRIPT_PATH" "${MOCK_REPO}"
    [ "$status" -eq 1 ] # Should fail with status 1
    [[ "${output}" =~ "Go is not installed. Please install Go and try again." ]]

    # Restore PATH and permissions
    chmod +x "${MOCK_BIN_DIR}/go" 
    PATH="$original_path"
}

# Test --branch flag: uses specified branch instead of default branch
@test "handles --branch flag with valid branch name" {
    run "$SCRIPT_PATH" --branch feature-branch "${MOCK_REPO}"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Using specified branch: feature-branch" ]]
    [[ "${output}" =~ "Using latest commit from feature-branch: abcd123" ]]
    [[ "${output}" =~ "Installing binary to:" ]]
}

# Test --branch flag missing argument
@test "fails when --branch is missing branch name" {
    run "$SCRIPT_PATH" --branch "${MOCK_REPO}"
    [ "$status" -eq 1 ]

    run "$SCRIPT_PATH" -b "${MOCK_REPO}"
    [ "$status" -eq 1 ]
}

# Test --build-flags are passed to go build
@test "passes build flags to go build" {
    # Create a mock go that captures build flags
    cat > "${MOCK_BIN_DIR}/go" << 'EOF'
#!/bin/sh
case "$1" in
    build)
        # Capture args to a file so we can verify
        echo "$@" > /tmp/anyform_test_go_args
        shift
        while [ $# -gt 0 ]; do
            if [ "$1" = "-o" ]; then
                touch "./$2"
                shift 2
                break
            fi
            shift
        done
        ;;
    env)
        case "$2" in
            "GOOS") echo "darwin" ;;
            "GOARCH") echo "amd64" ;;
        esac
        ;;
esac
exit 0
EOF
    chmod +x "${MOCK_BIN_DIR}/go"

    run "$SCRIPT_PATH" --build-flags "-ldflags=-X main.version=custom" "${MOCK_REPO}"
    [ "$status" -eq 0 ]
    [[ "$(cat /tmp/anyform_test_go_args)" =~ "-ldflags=-X" ]]
    rm -f /tmp/anyform_test_go_args
}

# Test --list with empty plugin directory
@test "lists installed providers when none installed" {
    # Override HOME to use a temp directory
    HOME="$TEST_TEMP_DIR"
    export HOME

    run "$SCRIPT_PATH" --list
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "No custom providers installed" ]]
}

# Test --list with mock installed providers
@test "lists installed providers with mock providers" {
    # Create mock plugin directory structure
    PLUGIN_BASE="${TEST_TEMP_DIR}/.terraform.d/plugins"
    mkdir -p "${PLUGIN_BASE}/registry.terraform.io/hashicorp/corner/v1.0.0/darwin_amd64"
    touch "${PLUGIN_BASE}/registry.terraform.io/hashicorp/corner/v1.0.0/darwin_amd64/terraform-provider-corner_v1.0.0"

    HOME="$TEST_TEMP_DIR"
    export HOME

    run "$SCRIPT_PATH" --list
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "corner" ]]
    [[ "${output}" =~ "v1.0.0" ]]
    [[ "${output}" =~ "darwin_amd64" ]]
}

# Test --clean without provider name
@test "fails when --clean is missing provider name" {
    run "$SCRIPT_PATH" --clean
    [ "$status" -eq 1 ]
}

# Test --clean with non-existent provider
@test "reports when provider to clean is not found" {
    HOME="$TEST_TEMP_DIR"
    export HOME
    mkdir -p "${TEST_TEMP_DIR}/.terraform.d/plugins"

    run "$SCRIPT_PATH" --clean nonexistent
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "not found" ]]
}

# Test --clean with a provider and --force
@test "cleans installed provider with --force" {
    PLUGIN_BASE="${TEST_TEMP_DIR}/.terraform.d/plugins"
    mkdir -p "${PLUGIN_BASE}/registry.terraform.io/hashicorp/corner/v1.0.0/darwin_amd64"
    touch "${PLUGIN_BASE}/registry.terraform.io/hashicorp/corner/v1.0.0/darwin_amd64/terraform-provider-corner_v1.0.0"

    HOME="$TEST_TEMP_DIR"
    export HOME

    run "$SCRIPT_PATH" --clean corner --force
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Removed:" ]]
    [ ! -d "${PLUGIN_BASE}/registry.terraform.io/hashicorp/corner" ]
}

# Test --clean-all with --force
@test "cleans all providers with --clean-all --force" {
    PLUGIN_BASE="${TEST_TEMP_DIR}/.terraform.d/plugins"
    mkdir -p "${PLUGIN_BASE}/registry.terraform.io/hashicorp/corner/v1.0.0/darwin_amd64"
    touch "${PLUGIN_BASE}/registry.terraform.io/hashicorp/corner/v1.0.0/darwin_amd64/terraform-provider-corner_v1.0.0"

    HOME="$TEST_TEMP_DIR"
    export HOME

    run "$SCRIPT_PATH" --clean-all --force
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Removed:" ]]
    [ ! -d "${PLUGIN_BASE}" ]
}

# Test --completion generates bash completion
@test "generates bash completion script" {
    run "$SCRIPT_PATH" --completion bash
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "complete -F _anyform_completion anyform" ]]
}

# Test --completion generates zsh completion
@test "generates zsh completion script" {
    run "$SCRIPT_PATH" --completion zsh
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "#compdef anyform" ]]
}

# Test --completion generates fish completion
@test "generates fish completion script" {
    run "$SCRIPT_PATH" --completion fish
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "complete -c anyform" ]]
}

# Test --completion with invalid shell
@test "fails with unsupported completion shell" {
    run "$SCRIPT_PATH" --completion invalid
    [ "$status" -eq 1 ]
}

# Test --completion without shell name
@test "fails when --completion is missing shell name" {
    run "$SCRIPT_PATH" --completion
    [ "$status" -eq 1 ]
}

# Test updated help output includes new flags
@test "help output includes new flags" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--branch" ]]
    [[ "${output}" =~ "--build-flags" ]]
    [[ "${output}" =~ "--clean" ]]
    [[ "${output}" =~ "--clean-all" ]]
    [[ "${output}" =~ "--completion" ]]
    [[ "${output}" =~ "--force" ]]
    [[ "${output}" =~ "--list" ]]
}
