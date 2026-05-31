<div align="center">
    <picture>
        <img src="images/anyform-logo.svg" width="300">
    </picture>
    <p><strong>Install any Terraform Provider straight from source - your gateway to custom provider versions!</strong></p>
   
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" /></a>
  <a href="https://github.com/Didainius/anyform/actions/workflows/test.yml"><img src="https://img.shields.io/github/actions/workflow/status/Didainius/anyform/test.yml?style=for-the-badge" /></a>
  </div>

## AnyForm - Any Terraform Provider version from source

A simple tool that installs any Terraform Provider straight from source. Supports specific commits,
branches, tags, and pull requests — for both Terraform and OpenTofu.

### Prerequisites

[Go](https://go.dev/) and [git](https://git-scm.com/) must be installed on your system.

### Installation

```shell
sudo curl -L https://github.com/Didainius/anyform/releases/latest/download/anyform -o /usr/local/bin/anyform
sudo chmod 755 /usr/local/bin/anyform
```

### Shell Completions

AnyForm can generate tab-completion scripts for bash, zsh, and fish:

```shell
# Bash
anyform --completion bash | sudo tee /usr/local/share/bash-completion/completions/anyform

# Zsh
anyform --completion zsh > ~/.zfunc/_anyform

# Fish
anyform --completion fish > ~/.config/fish/completions/anyform.fish
```

### Use cases

* Perfect for development and testing purposes
* Validate specific bug fixes before official releases
* Access the latest provider features and improvements immediately
* Test provider changes from any branch or pull request


### Usage

```shell
anyform --help
Usage: ./anyform [flags] <repository-address> [git-commit-version]

Build & Install:
  <repository-address>                         GitHub repo URL
  [git-commit-version]                         Specific commit hash or tag

Options:
  --build-flags <flags>                        Pass additional flags to go build
  --branch, -b <name>                          Use a specific branch (instead of default)
  --check-update                               Check if a new version is available
  --clean, -c <provider> [version]              Remove installed provider(s)
  --clean-all                                  Remove all installed providers
  --completion <bash|zsh|fish>                 Generate shell completion script
  --force, -f                                  Skip confirmation prompts
  -h, --help                                   Show this help message
  --list, -l                                   List installed custom providers
  --opentofu                                   Install for OpenTofu only (skip Terraform)
  --print-configuration, -p                    Print the Terraform configuration block
  --self-update, -U                            Update anyform to the latest version
  --silent, -s                                 Run in silent mode (no output except errors)
  --version                                     Print version information

Note: Repository address can be:
  - Repository URL: https://github.com/<organization>/terraform-provider-<name>
  - Pull Request URL: https://github.com/<organization>/terraform-provider-<name>/pull/<number>
If git-commit-version is not specified, the latest commit from default branch or PR will be used
```

### Examples

#### Install from a specific commit

```shell
anyform -p https://github.com/cloudflare/terraform-provider-cloudflare 24354ad
```

Installs the provider built from commit `24354ad` and prints the config block.

#### Install from a branch

```shell
anyform --branch feature-branch https://github.com/hashicorp/terraform-provider-aws
```

Checks out the latest commit on `feature-branch` instead of the default branch.

#### Pass custom build flags

```shell
anyform --build-flags='-ldflags="-X main.version=custom"' https://github.com/cloudflare/terraform-provider-cloudflare
```

Passes custom linker flags to `go build` for version injection or other build-time customization.

#### Install from a Pull Request

```shell
anyform -p https://github.com/cloudflare/terraform-provider-cloudflare/pull/4414
```

Fetches and builds the PR head. You can also specify a specific commit on the PR branch.

#### OpenTofu only

```shell
anyform --opentofu -p https://github.com/cloudflare/terraform-provider-cloudflare
```

Installs the provider to the OpenTofu registry path (`registry.opentofu.org`) instead of
the Terraform registry path, and prints an OpenTofu-compatible config block.

#### List installed providers

```shell
anyform --list
```

```
Installed custom providers:

  registry.terraform.io:
    cloudflare/cloudflare     4.45.0-13-g24354ad1e      darwin_arm64
    hashicorp/aws             5.0.0-3-gabcdef1           darwin_arm64

  registry.opentofu.org:
    cloudflare/cloudflare     4.45.0-13-g24354ad1e      darwin_arm64
```

#### Remove installed providers

```shell
# Remove all versions of a specific provider
anyform --clean cloudflare --force

# Remove a specific version only
anyform --clean cloudflare v4.45.0-13-g24354ad1e --force

# Remove everything (will prompt for confirmation)
anyform --clean-all
```

#### Update AnyForm itself

```shell
# Check for updates
anyform --check-update

# Update to latest
anyform --self-update
```

### Testing

Tests are written using [Bats](https://github.com/bats-core/bats-core) (Bash Automated Testing System).
The suite contains 39 tests covering core functionality, error handling, and all features.

```shell
# On macOS
brew install bats-core

# On Ubuntu/Debian
apt-get install bats

bats anyform.bats
```

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
