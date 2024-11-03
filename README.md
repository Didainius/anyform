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
./anyform -p https://github.com/cloudflare/terraform-provider-cloudflare
Organization: cloudflare
Provider Name: terraform-provider-cloudflare
Provider Type: cloudflare
Repository Address: https://github.com/cloudflare/terraform-provider-cloudflare
Git Commit Version:
Cloning into '/tmp/terraform-provider-cloudflare-'...
remote: Enumerating objects: 93162, done.
remote: Counting objects: 100% (570/570), done.
remote: Compressing objects: 100% (250/250), done.
remote: Total 93162 (delta 356), reused 523 (delta 318), pack-reused 92592 (from 1)
Receiving objects: 100% (93162/93162), 58.04 MiB | 14.33 MiB/s, done.
Resolving deltas: 100% (68216/68216), done.
No commit version specified, using latest commit from default branch
Already on 'master'
Your branch is up to date with 'origin/master'.
Already up to date.
Using commit: 86cd8749ed6948889800a691dc7d038868c36a7c
Checked out version: v4.45.0-14-g86cd8749e
Build completed successfully. Output binary: /Users/user/.terraform/plugins/darwin_arm64/cloudflare/cloudflare/v4.45.0-14-g86cd8749e/terraform-provider-cloudflare_v4.45.0-14-g86cd8749e
To use this provider in your Terraform configuration, add the following block:

terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "v4.45.0-14-g86cd8749e"
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

