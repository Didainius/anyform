#!/bin/sh

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <terraform-provider-name> <git-commit-version>"
    exit 1
fi

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

# Assign arguments to variables
PROVIDER_NAME=$1
COMMIT_VERSION=$2

# Print the provided arguments
echo "Terraform Provider Name: $PROVIDER_NAME"
echo "Git Commit Version: $COMMIT_VERSION"

# Create a temporary directory
TEMP_DIR="/tmp/${PROVIDER_NAME}-${COMMIT_VERSION}"
if [ -d "$TEMP_DIR" ]; then
    echo "Directory $TEMP_DIR already exists. Using existing directory."
else
    mkdir -p $TEMP_DIR
fi

# Clone the repository into the temporary directory
if [ ! -d "$TEMP_DIR/.git" ]; then
    git clone https://github.com/hashicorp/$PROVIDER_NAME.git $TEMP_DIR
    if [ $? -ne 0 ]; then
        echo "Failed to clone repository"
        exit 1
    fi
fi

# Change to the temporary directory
cd $TEMP_DIR

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
OUTPUT_BINARY="${PROVIDER_NAME}-${CHECKED_OUT_VERSION}-${COMMIT_VERSION}"
go build -v -o $OUTPUT_BINARY
if [ $? -ne 0 ]; then
    echo "Failed to build"
    exit 1
fi

# Determine the local .terraform path based on GOOS and GOARCH in the user's home directory
GOOS=$(go env GOOS)
GOARCH=$(go env GOARCH)
NAMESPACE="hashicorp"
TYPE=$(echo $PROVIDER_NAME | sed 's/^terraform-provider-//')
VERSION=$CHECKED_OUT_VERSION
TERRAFORM_PATH="$HOME/.terraform/plugins/${GOOS}_${GOARCH}/${NAMESPACE}/${TYPE}/${VERSION}"

# Create the directory if it doesn't exist
mkdir -p $TERRAFORM_PATH

# Move the built binary to the .terraform path
mv $OUTPUT_BINARY $TERRAFORM_PATH/
if [ $? -ne 0 ]; then
    echo "Failed to move binary to $TERRAFORM_PATH"
    exit 1
fi

echo "Build completed successfully. Output binary: $TERRAFORM_PATH/$OUTPUT_BINARY"
