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
Usage: ./anyform [--print-configuration | -p] <repository-address> [git-commit-version]
Options:
  --print-configuration, -p  Print the Terraform configuration block
  -h, --help                 Show this help message
Note: If git-commit-version is not specified, the latest commit from default branch will be used
```

#### Example

```shell
anyform -p https://github.com/cloudflare/terraform-provider-cloudflare
Organization: cloudflare
Provider Name: terraform-provider-cloudflare
Provider Type: cloudflare
Repository Address: https://github.com/cloudflare/terraform-provider-cloudflare
Cloning into '/tmp/terraform-provider-cloudflare'...
remote: Enumerating objects: 93219, done.
remote: Counting objects: 100% (655/655), done.
remote: Compressing objects: 100% (240/240), done.
remote: Total 93219 (delta 435), reused 618 (delta 413), pack-reused 92564 (from 1)
Receiving objects: 100% (93219/93219), 58.05 MiB | 21.21 MiB/s, done.
Resolving deltas: 100% (68267/68267), done.
No commit version specified, using latest commit from default branch
From https://github.com/cloudflare/terraform-provider-cloudflare
 * branch                master     -> FETCH_HEAD
Using commit: 86cd8749ed6948889800a691dc7d038868c36a7c
Note: switching to '86cd8749ed6948889800a691dc7d038868c36a7c'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -c with the switch command. Example:

  git switch -c <new-branch-name>

Or undo this operation with:

  git switch -

Turn off this advice by setting config variable advice.detachedHead to false

HEAD is now at 86cd8749e get rid of cache
Checked out version: v4.45.0-14-g86cd8749e
Build completed successfully. Output binary: /Users/user/.terraform.d/plugins/registry.terraform.io/cloudflare/cloudflare/4.45.0-14-g86cd8749e/darwin_arm64/terraform-provider-cloudflare_v4.45.0-14-g86cd8749e
To use this provider in your Terraform configuration, add the following block:

terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.45.0-14-g86cd8749e"
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

