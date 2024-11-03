#!/bin/sh

# Function to print usage
print_usage() {
    echo "Usage: $0 [--print-configuration | -p] <repository-address> <git-commit-version>"
    echo "Options:"
    echo "  --print-configuration, -p  Print the Terraform configuration block"
    echo "  -h, --help                 Show this help message"
}

# Check if the correct number of arguments are provided
if [ "$#" -lt 2 ]; then
    print_usage
    exit 1
fi

# Initialize flag variable
PRINT_CONFIG=false

# Parse arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        --print-configuration|-p)
            PRINT_CONFIG=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            if [ -z "$REPO_ADDRESS" ]; then
                REPO_ADDRESS=$1
            elif [ -z "$COMMIT_VERSION" ]; then
                COMMIT_VERSION=$1
            else
                print_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [ -z "$REPO_ADDRESS" ] || [ -z "$COMMIT_VERSION" ]; then
    print_usage
    exit 1
fi

# Extract provider information and organization from repository address
GITHUB_PATTERN="https://github.com/([^/]+)/"
PROVIDER_PATTERN="terraform-provider-([^/]+)"

# Extract organization from GitHub URL
if [[ $REPO_ADDRESS =~ $GITHUB_PATTERN ]]; then
    ORGANIZATION="${BASH_REMATCH[1]}"
else
    echo "Error: Unable to extract organization from repository address"
    echo "Repository address must be in format: https://github.com/<organization>/terraform-provider-<name>"
    exit 1
fi

# Extract provider information
if [[ $REPO_ADDRESS =~ $PROVIDER_PATTERN ]]; then
    PROVIDER_NAME="terraform-provider-${BASH_REMATCH[1]}"
    PROVIDER_TYPE="${BASH_REMATCH[1]}"
else
    echo "Error: Unable to extract provider name from repository address"
    echo "Repository name must be in format: terraform-provider-<name>"
    exit 1
fi

echo "Organization: $ORGANIZATION"
echo "Provider Name: $PROVIDER_NAME"
echo "Provider Type: $PROVIDER_TYPE"

# Check if git is installed
if ! command -v git > /dev/null 2>&1; then
    echo "git is not installed. Please install git and try again."
    exit 1
fi

# Check if go is installed
if ! command -v go > /dev/null 2>&1; then
    echo "Go is not installed. Please install Go and try again."
    exit 1
fi

# Print the provided arguments
echo "Repository Address: $REPO_ADDRESS"
echo "Git Commit Version: $COMMIT_VERSION"

# Create and handle temporary directory
TEMP_DIR="/tmp/${PROVIDER_NAME}-${COMMIT_VERSION}"
if [ -d "$TEMP_DIR" ]; then
    echo "Directory $TEMP_DIR already exists. Updating repository..."
    cd $TEMP_DIR
    git fetch --all --tags
    if [ $? -ne 0 ]; then
        echo "Failed to update repository"
        exit 1
    fi
else
    mkdir -p $TEMP_DIR
    git clone $REPO_ADDRESS $TEMP_DIR
    if [ $? -ne 0 ]; then
        echo "Failed to clone repository"
        exit 1
    fi
    cd $TEMP_DIR
fi

# Checkout the specific commit
git checkout $COMMIT_VERSION
if [ $? -ne 0 ]; then
    echo "Failed to checkout commit $COMMIT_VERSION"
    exit 1
fi

# Emit the version tag that was checked out
CHECKED_OUT_VERSION=$(git describe --tags)
echo "Checked out version: $CHECKED_OUT_VERSION"

# Perform go build with verbose flag
OUTPUT_BINARY="${PROVIDER_NAME}_${CHECKED_OUT_VERSION}"
go build -v -o $OUTPUT_BINARY
if [ $? -ne 0 ]; then
    echo "Failed to build"
    exit 1
fi

# Determine the local .terraform path based on GOOS and GOARCH in the user's home directory
GOOS=$(go env GOOS)
GOARCH=$(go env GOARCH)
VERSION=$CHECKED_OUT_VERSION
TERRAFORM_PATH="$HOME/.terraform/plugins/${GOOS}_${GOARCH}/${ORGANIZATION}/${PROVIDER_TYPE}/${VERSION}"

# Create the directory if it doesn't exist
mkdir -p $TERRAFORM_PATH

# Move the built binary to the .terraform path
mv $OUTPUT_BINARY $TERRAFORM_PATH/
if [ $? -ne 0 ]; then
    echo "Failed to move binary to $TERRAFORM_PATH"
    exit 1
fi

echo "Build completed successfully. Output binary: $TERRAFORM_PATH/$OUTPUT_BINARY"

# Only print the configuration block if --print-configuration was provided
if [ "$PRINT_CONFIG" = true ]; then
    echo "To use this provider in your Terraform configuration, add the following block:"
    echo "
terraform {
  required_providers {
    $PROVIDER_TYPE = {
      source = \"$ORGANIZATION/$PROVIDER_TYPE\"
      version = \"$VERSION\"
    }
  }
}
"
fi