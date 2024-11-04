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
Usage: ./anyform [--print-configuration | -p] [--version] <repository-address> [git-commit-version]
Options:
  --print-configuration, -p  Print the Terraform configuration block
  --version                  Print version information
  -h, --help                 Show this help message
Note: If git-commit-version is not specified, the latest commit from default branch will be used
```

#### Example

```shell
anyform -p https://github.com/cloudflare/terraform-provider-cloudflare 24354ad
Organization: cloudflare
Provider Name: terraform-provider-cloudflare
Provider Type: cloudflare
Repository Address: https://github.com/cloudflare/terraform-provider-cloudflare
Git Commit Version: 24354ad
Cloning into '/tmp/terraform-provider-cloudflare'...
remote: Enumerating objects: 93310, done.
remote: Counting objects: 100% (746/746), done.
remote: Compressing objects: 100% (274/274), done.
remote: Total 93310 (delta 500), reused 687 (delta 470), pack-reused 92564 (from 1)
Receiving objects: 100% (93310/93310), 58.10 MiB | 11.98 MiB/s, done.
Resolving deltas: 100% (68332/68332), done.
Note: switching to '24354ad'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -c with the switch command. Example:

  git switch -c <new-branch-name>

Or undo this operation with:

  git switch -

Turn off this advice by setting config variable advice.detachedHead to false

HEAD is now at 24354ad1e allow 120m to run the tests
Checked out version: v4.45.0-13-g24354ad1e
Build completed successfully. Output binary: /Users/user/.terraform.d/plugins/registry.terraform.io/cloudflare/cloudflare/4.45.0-13-g24354ad1e/darwin_arm64/terraform-provider-cloudflare_v4.45.0-13-g24354ad1e
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

