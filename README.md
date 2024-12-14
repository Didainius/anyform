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
sudo curl -L https://github.com/Didainius/anyform/releases/latest/download/anyform -o /usr/local/bin/anyform
sudo chmod 755 /usr/local/bin/anyform
```

### Use cases

* Perfect for development and testing purposes
* Validate specific bug fixes before official releases
* Access the latest provider features and improvements immediately


### Usage

```shell
anyform [options] <repository-address> [git-commit-version]
```

#### Options

- `--print-configuration`, `-p`: Print the Terraform configuration block.
- `--version`: Print version information.
- `--self-update`, `-U`: Update AnyForm to the latest version.
- `--check-update`: Check if a new version is available.
- `--silent`, `-s`: Run in silent mode (no output except errors).
- `--opentofu`: Install for OpenTofu only (skip Terraform).
- `-h`, `--help`: Show help message.

#### Additional Examples

Install the latest version of a provider:

```shell
anyform https://github.com/hashicorp/terraform-provider-aws
```

Install a specific commit of a provider:

```shell
anyform https://github.com/hashicorp/terraform-provider-aws abc123def
```

Install a provider for OpenTofu only:

```shell
anyform --opentofu https://github.com/opentofu/terraform-provider-example
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
remote: Enumerating objects: 94668, done.
remote: Counting objects: 100% (2096/2096), done.
remote: Compressing objects: 100% (683/683), done.
remote: Total 94668 (delta 1459), reused 1979 (delta 1405), pack-reused 92572 (from 1)
Receiving objects: 100% (94668/94668), 58.59 MiB | 22.11 MiB/s, done.
Resolving deltas: 100% (69288/69288), done.
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
Binary installed to: /Users/user/.terraform.d/plugins/registry.terraform.io/cloudflare/cloudflare/4.45.0-13-g24354ad1e/darwin_arm64/terraform-provider-cloudflare_v4.45.0-13-g24354ad1e
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
./anyform -p https://github.com/cloudflare/terraform-provider-cloudflare/pull/4414
Organization: cloudflare
Provider Name: terraform-provider-cloudflare
Provider Type: cloudflare
Repository Address: https://github.com/cloudflare/terraform-provider-cloudflare
Fetching Pull Request #4414
remote: Enumerating objects: 18, done.
remote: Counting objects: 100% (14/14), done.
remote: Total 18 (delta 14), reused 14 (delta 14), pack-reused 4 (from 1)
Unpacking objects: 100% (18/18), 3.35 KiB | 163.00 KiB/s, done.
From https://github.com/cloudflare/terraform-provider-cloudflare
 * [new ref]             refs/pull/4414/head -> pr-4414
Previous HEAD position was 24354ad1e allow 120m to run the tests
Switched to branch 'pr-4414'
Checked out version: v4.44.0-14-gc4a40be72
go: downloading github.com/hashicorp/terraform-plugin-framework-validators v0.14.0
Binary installed to: /Users/user/.terraform.d/plugins/registry.terraform.io/cloudflare/cloudflare/4.44.0-14-gc4a40be72/darwin_arm64/terraform-provider-cloudflare_v4.44.0-14-gc4a40be72
To use this provider in your Terraform configuration, add the following block:

terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.44.0-14-gc4a40be72"
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

