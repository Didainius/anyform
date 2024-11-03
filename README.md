<div align="center">
    <picture>
        <img src="images/anyform-logo.png" width="250">
    </picture>
    <p><strong>Install any Terraform Provider straight from source - your gateway to custom provider versions!</strong></p>
   
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" /></a>
</div>

## AnyForm


A simple tool that installs any Terraform Provider straight from source. You can choose either the
latest version or any specific commit.

### Requisites

[Go](https://go.dev/) and [git](https://git-scm.com/) should be available.

### Installation

You can install AnyForm directly using curl:

```shell
curl -L https://github.com/Didainius/anyform/releases/latest/download/anyform -o /usr/local/bin/anyform
chmod +x /usr/local/bin/anyform
```

### Use cases

* Perfect for development and testing purposes
* Validate specific bug fixes before official releases
* Access the latest provider features and improvements immediately


### Usage

```shell
Usage: ./anyform [--print-configuration | -p] <repository-address> [git-commit-version]
Options:
  --print-configuration, -p  Print the Terraform configuration block
  -h, --help                 Show this help message
Note: If git-commit-version is not specified, the latest commit from default branch will be used
```

#### Example

```shell
$ anyform  https://github.com/hashicorp/terraform-provider-google
Organization: hashicorp
Provider Name: terraform-provider-google
Provider Type: google
Repository Address: https://github.com/hashicorp/terraform-provider-google
No commit version specified, using latest commit from default branch
From https://github.com/hashicorp/terraform-provider-google
 * branch                main       -> FETCH_HEAD
Using commit: ca051856a75ed90d44920a111a25c5078d7fe8e8
HEAD is now at ca051856a Magician vcr eap cmd (#12024) (#20168)
Checked out version: v5.29.0-1239-gca051856a
Build completed successfully. Output binary: /Users/dainius/.terraform/plugins/darwin_arm64/hashicorp/google/v5.29.0-1239-gca051856a/terraform-provider-google_v5.29.0-1239-gca051856a
```

### Testing

Tests are written using [Bats](https://github.com/bats-core/bats-core) (Bash Automated Testing System). To run the tests:

1. Install Bats:
   ```shell
   # On macOS
   brew install bats-core

   # On Ubuntu/Debian
   apt-get install bats

   # Using npm
   npm install -g bats
   ```

2. Make the test file executable:
   ```shell
   chmod +x anyform.bats
   ```

3. Run the tests:
   ```shell
   bats anyform.bats
   ```

The test suite covers basic functionality, error handling, and various input scenarios.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

