<div align="center">
    <picture>
        <img src="images/anyform-logo.svg" width="300">
    </picture>
    <p><strong>Install any Terraform Provider straight from source - your gateway to custom provider versions!</strong></p>
   
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" /></a>
</div>

## AnyForm - Any Terraform Provider version from source

A simple tool that installs any Terraform Provider straight from source. You can choose either the
latest version or any specific commit.

### Prerequisites

[Go](https://go.dev/) and [git](https://git-scm.com/) must be installed on your system.

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
Usage: ./anyform [--print-configuration | -p] [--version] [--self-update | -U] [--check-update] [--silent | -s] <repository-address> [git-commit-version]
Options:
  --print-configuration, -p  Print the Terraform configuration block
  --version                  Print version information
  --self-update, -U          Update anyform to the latest version
  --check-update             Check if a new version is available
  --silent, -s               Run in silent mode (no output except errors)
  -h, --help                 Show this help message
Note: Repository address can be:
  - Repository URL: https://github.com/<organization>/terraform-provider-<name>
  - Pull Request URL: https://github.com/<organization>/terraform-provider-<name>/pull/<number>
If git-commit-version is not specified, the latest commit from default branch or PR will be used
```

#### Example

```shell
anyform -p https://github.com/cloudflare/terraform-provider-cloudflare 24354ad
Organization: cloudflare
Provider Name: terraform-provider-cloudflare
Provider Type: cloudflare
Repository Address: https://github.com/cloudflare/terraform-provider-cloudflare
Git Commit Version: 24354ad
HEAD is now at 24354ad1e allow 120m to run the tests
Checked out version: v4.45.0-13-g24354ad1e
Build completed successfully. Output binary: /Users/dainius/.terraform.d/plugins/registry.terraform.io/cloudflare/cloudflare/4.45.0-13-g24354ad1e/darwin_arm64/terraform-provider-cloudflare_v4.45.0-13-g24354ad1e
To use this provider in your Terraform configuration, add the following block:

terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.45.0-13-g24354ad1e"
    }
  }
}
```

#### Example with PR URL

```shell
anyform -p https://github.com/cloudflare/terraform-provider-cloudflare/pull/4511
Organization: cloudflare
Provider Name: terraform-provider-cloudflare
Provider Type: cloudflare
Repository Address: https://github.com/cloudflare/terraform-provider-cloudflare
Fetching Pull Request #4511
remote: Enumerating objects: 9, done.
remote: Counting objects: 100% (9/9), done.
remote: Compressing objects: 100% (4/4), done.
remote: Total 9 (delta 5), reused 9 (delta 5), pack-reused 0 (from 0)
Unpacking objects: 100% (9/9), 3.95 KiB | 506.00 KiB/s, done.
From https://github.com/cloudflare/terraform-provider-cloudflare
 * [new ref]             refs/pull/4511/head -> pr-4511
Previous HEAD position was 24354ad1e allow 120m to run the tests
Switched to branch 'pr-4511'
Checked out version: v4.45.0-21-g2c128b7d5
Build completed successfully. Output binary: /Users/dainius/.terraform.d/plugins/registry.terraform.io/cloudflare/cloudflare/4.45.0-21-g2c128b7d5/darwin_arm64/terraform-provider-cloudflare_v4.45.0-21-g2c128b7d5
To use this provider in your Terraform configuration, add the following block:

terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.45.0-21-g2c128b7d5"
    }
  }
}
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
