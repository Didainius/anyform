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
    "fetch")
        echo "Fetching..."
        ;;
    "rev-parse")
        if [ "$2" = "--quiet" ] && [ "$3" = "--verify" ] && [ "$4" = "abc123^{commit}" ]; then
            # Simulate non-existent commit
            exit 1
        elif [ "$2" = "--quiet" ] && [ "$3" = "--verify" ]; then
            # For other commits, assume they exist
            exit 0
        else
            echo "master"
        fi
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
    cd "${TEST_TEMP_DIR}/terraform-provider-corner"
    git init
    touch main.go
    git add main.go
    git commit -m "Initial commit"
    git tag -a "v1.0.0" -m "Version 1.0.0"
    MOCK_REPO="https://github.com/hashicorp/terraform-provider-corner"
}

teardown() {
    # Clean up temporary directory
    rm -rf "${TEST_TEMP_DIR}"
    rm -rf "${MOCK_BIN_DIR}"
    rm -rf "/tmp/terraform-provider-corner"
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

@test "handles missing git command" {
    # Save original PATH
    ORIGINAL_PATH="$PATH"
    
    # Create a temporary directory for PATH manipulation
    TEMP_PATH_DIR="$(mktemp -d)"
    
    # Create a fake PATH that excludes git but keeps other essential commands
    mkdir -p "$TEMP_PATH_DIR/bin"
    for cmd in $(echo "$ORIGINAL_PATH" | tr ':' '\n' | grep -v "git"); do
        if [ -d "$cmd" ]; then
            for file in "$cmd"/*; do
                if [ -x "$file" ] && [ ! "$(basename "$file")" = "git" ]; then
                    ln -sf "$file" "$TEMP_PATH_DIR/bin/"
                fi
            done
        fi
    done
    
    # Set the new PATH without git
    export PATH="$TEMP_PATH_DIR/bin"
    
    # Run the test
    run "$SCRIPT_PATH" "${MOCK_REPO}"
    
    # Restore original PATH
    export PATH="$ORIGINAL_PATH"
    rm -rf "$TEMP_PATH_DIR"
    
    # Assert
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "git is not installed" ]]
}

@test "handles missing go command" {
    # Save original PATH
    ORIGINAL_PATH="$PATH"
    
    # Create a temporary directory for PATH manipulation
    TEMP_PATH_DIR="$(mktemp -d)"
    
    # Create a fake PATH that excludes go but keeps other essential commands
    mkdir -p "$TEMP_PATH_DIR/bin"
    for cmd in $(echo "$ORIGINAL_PATH" | tr ':' '\n' | grep -v "go"); do
        if [ -d "$cmd" ]; then
            for file in "$cmd"/*; do
                if [ -x "$file" ] && [ ! "$(basename "$file")" = "go" ]; then
                    ln -sf "$file" "$TEMP_PATH_DIR/bin/"
                fi
            done
        fi
    done
    
    # Set the new PATH without go
    export PATH="$TEMP_PATH_DIR/bin"
    
    # Run the test
    run "$SCRIPT_PATH" "${MOCK_REPO}"
    
    # Restore original PATH
    export PATH="$ORIGINAL_PATH"
    rm -rf "$TEMP_PATH_DIR"
    
    # Assert
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "Go is not installed" ]]
}