
## What is pre-commit
pre-commit operates as a git hook, commits triggering a set of tools to check your code. You can set what tools to use to scan your local repository using a configuration file. If a tool finds any errors, for example a misconfiguration of a coding language, it will stop the commit from happening. This is a shift left approach that will improve security and best practices in coding.


## How to install

### 1. Install dependencies

* [`pre-commit`](https://pre-commit.com/#install),
  <sub><sup>[`terraform`](https://www.terraform.io/downloads.html),
  <sub><sup>[`git`](https://git-scm.com/downloads),
  <sub><sup>[BASH `3.2.57` or newer](https://www.gnu.org/software/bash/#download),
  <sub><sup>Internet connection (on first run),
  <sub><sup>x86_64 or arm64 compatible operation system,
  <sub><sup>Some hardware where this OS will run,
  <sub><sup>Electricity for hardware and internet connection,
  <sub><sup>Some basic physical laws,
  <sub><sup>Hope that it all will work.
  </sup></sub></sup></sub></sup></sub></sup></sub></sup></sub></sup></sub></sup></sub></sup></sub></sup></sub><br><br>
* [`checkov`](https://github.com/bridgecrewio/checkov) required for `terraform_checkov` hook.
* [`terraform-docs`](https://github.com/terraform-docs/terraform-docs) required for `terraform_docs` hook.
* [`terragrunt`](https://terragrunt.gruntwork.io/docs/getting-started/install/) required for `terragrunt_validate` hook.
* [`terrascan`](https://github.com/tenable/terrascan) required for `terrascan` hook.
* [`TFLint`](https://github.com/terraform-linters/tflint) required for `terraform_tflint` hook.
* [`TFSec`](https://github.com/liamg/tfsec) required for `terraform_tfsec` hook.
* [`Trivy`](https://github.com/aquasecurity/trivy) required for `terraform_trivy` hook.
* [`infracost`](https://github.com/infracost/infracost) required for `infracost_breakdown` hook.
* [`jq`](https://github.com/stedolan/jq) required for `terraform_validate` with `--retry-once-with-cleanup` flag, and for `infracost_breakdown` hook.
* [`tfupdate`](https://github.com/minamijoyo/tfupdate) required for `tfupdate` hook.
* [`hcledit`](https://github.com/minamijoyo/hcledit) required for `terraform_wrapper_module_for_each` hook.

<details><summary><b>Docker</b></summary><br>

**Pull docker image with all hooks**:

```bash
TAG=latest
docker pull ghcr.io/antonbabenko/pre-commit-terraform:$TAG
```

All available tags [here](https://github.com/antonbabenko/pre-commit-terraform/pkgs/container/pre-commit-terraform/versions).

**Build from scratch**:

> [!IMPORTANT]
> To build image you need to have [`docker buildx`](https://docs.docker.com/build/install-buildx/) enabled as default builder.
> Otherwise - provide `TARGETOS` and `TARGETARCH` as additional `--build-arg`'s to `docker build`.

When hooks-related `--build-arg`s are not specified, only the latest version of `pre-commit` and `terraform` will be installed.

```bash
git clone git@github.com:antonbabenko/pre-commit-terraform.git
cd pre-commit-terraform
# Install the latest versions of all the tools
docker build -t pre-commit-terraform --build-arg INSTALL_ALL=true .
```

To install a specific version of individual tools, define it using `--build-arg` arguments or set it to `latest`:

```bash
docker build -t pre-commit-terraform \
    --build-arg PRE_COMMIT_VERSION=latest \
    --build-arg TERRAFORM_VERSION=latest \
    --build-arg CHECKOV_VERSION=2.0.405 \
    --build-arg INFRACOST_VERSION=latest \
    --build-arg TERRAFORM_DOCS_VERSION=0.15.0 \
    --build-arg TERRAGRUNT_VERSION=latest \
    --build-arg TERRASCAN_VERSION=1.10.0 \
    --build-arg TFLINT_VERSION=0.31.0 \
    --build-arg TFSEC_VERSION=latest \
    --build-arg TRIVY_VERSION=latest \
    --build-arg TFUPDATE_VERSION=latest \
    --build-arg HCLEDIT_VERSION=latest \
    .
```

Set `-e PRE_COMMIT_COLOR=never` to disable the color output in `pre-commit`.

</details>






<details><summary><b>Ubuntu 20.04+</b></summary><br>

```bash
sudo apt update
sudo apt install -y unzip software-properties-common python3 python3-pip python-is-python3
python3 -m pip install --upgrade pip
pip3 install --no-cache-dir pre-commit
pip3 install --no-cache-dir checkov
curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz && tar -xzf terraform-docs.tgz terraform-docs && rm terraform-docs.tgz && chmod +x terraform-docs && sudo mv terraform-docs /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E -m 1 "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz && tar -xzf terrascan.tar.gz terrascan && rm terrascan.tar.gz && sudo mv terrascan /usr/bin/ && terrascan init
curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && sudo mv tflint /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/aquasecurity/tfsec/releases/latest | grep -o -E -m 1 "https://.+?tfsec-linux-amd64")" > tfsec && chmod +x tfsec && sudo mv tfsec /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep -o -E -i -m 1 "https://.+?/trivy_.+?_Linux-64bit.tar.gz")" > trivy.tar.gz && tar -xzf trivy.tar.gz trivy && rm trivy.tar.gz && sudo mv trivy /usr/bin
sudo apt install -y jq && \
curl -L "$(curl -s https://api.github.com/repos/infracost/infracost/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > infracost.tgz && tar -xzf infracost.tgz && rm infracost.tgz && sudo mv infracost-linux-amd64 /usr/bin/infracost && infracost auth login
curl -L "$(curl -s https://api.github.com/repos/minamijoyo/tfupdate/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.tar.gz")" > tfupdate.tar.gz && tar -xzf tfupdate.tar.gz tfupdate && rm tfupdate.tar.gz && sudo mv tfupdate /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/minamijoyo/hcledit/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.tar.gz")" > hcledit.tar.gz && tar -xzf hcledit.tar.gz hcledit && rm hcledit.tar.gz && sudo mv hcledit /usr/bin/
```

</details>

<details><summary><b>Windows 10/11</b></summary>

We highly recommend using [WSL/WSL2](https://docs.microsoft.com/en-us/windows/wsl/install) with Ubuntu and following the Ubuntu installation guide. Or use Docker.

> [!IMPORTANT]
> We won't be able to help with issues that can't be reproduced in Linux/Mac.
> So, try to find a working solution and send PR before open an issue.

Otherwise, you can follow [this gist](https://gist.github.com/etiennejeanneaurevolve/1ed387dc73c5d4cb53ab313049587d09):

1. Install [`git`](https://git-scm.com/downloads) and [`gitbash`](https://gitforwindows.org/)
2. Install [Python 3](https://www.python.org/downloads/)
3. Install all prerequisites needed (see above)

Ensure your PATH environment variable looks for `bash.exe` in `%ProgramFiles%\Git\bin` (the one present in `%WINDIR%\System32\bash.exe` does not work with `pre-commit.exe`)

For `checkov`, you may need to also set your `PYTHONPATH` environment variable with the path to your Python modules.
E.g. `%LOCALAPPDATA%\Programs\Python\Python39\Lib\site-packages`

</details>

### 2. Install the pre-commit hook globally

> [!NOTE]
> Not needed if you use the Docker image

```bash
DIR=~/.git-template
git config --global init.templateDir ${DIR}
pre-commit init-templatedir -t pre-commit ${DIR}
```

### 3. Add configs and hooks

Step into the repository you want to have the pre-commit hooks installed and run:

```bash
git init
cat <<EOF > .pre-commit-config.yaml
repos:
- repo: https://github.com/antonbabenko/pre-commit-terraform
  rev: <VERSION> # Get the latest from: https://github.com/antonbabenko/pre-commit-terraform/releases
  hooks:
    - id: terraform_fmt
    - id: terraform_docs
EOF
```

### 4. Run

Execute this command to run `pre-commit` on all files in the repository (not only changed files):

```bash
pre-commit run -a
```

Or, using Docker ([available tags](https://github.com/antonbabenko/pre-commit-terraform/pkgs/container/pre-commit-terraform/versions)):

> [!TIP]
> This command uses your user id and group id for the docker container to use to access the local files.  If the files are owned by another user, update the `USERID` environment variable.  See [File Permissions section](#file-permissions) for more information.

```bash
TAG=latest
docker run -e "USERID=$(id -u):$(id -g)" -v $(pwd):/lint -w /lint ghcr.io/antonbabenko/pre-commit-terraform:$TAG run -a
```

Execute this command to list the versions of the tools in Docker:

```bash
TAG=latest
docker run --rm --entrypoint cat ghcr.io/antonbabenko/pre-commit-terraform:$TAG /usr/bin/tools_versions_info
```


## Available Hooks

There are several [pre-commit](https://pre-commit.com/) hooks to keep Terraform configurations (both `*.tf` and `*.tfvars`) and Terragrunt configurations (`*.hcl`) in a good shape:

| Hook name                                              | Description                                                                                                                                                                                                                                  | Dependencies<br><sup>[Install instructions here](#1-install-dependencies)</sup>      |
| ------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `checkov` and `terraform_checkov`                      | [checkov](https://github.com/bridgecrewio/checkov) static analysis of terraform templates to spot potential security issues. [Hook notes](#checkov-deprecated-and-terraform_checkov)                                                         | `checkov`<br>Ubuntu deps: `python3`, `python3-pip`                                   |
| `infracost_breakdown`                                  | Check how much your infra costs with [infracost](https://github.com/infracost/infracost). [Hook notes](#infracost_breakdown)                                                                                                                 | `infracost`, `jq`, [Infracost API key](https://www.infracost.io/docs/#2-get-api-key) |
| `terraform_docs`                                       | Inserts input and output documentation into `README.md`. Recommended. [Hook notes](#terraform_docs)                                                                                                                                          | `terraform-docs`                                                                     |
| `terraform_docs_replace`                               | Runs `terraform-docs` and pipes the output directly to README.md. **DEPRECATED**, see [#248](https://github.com/antonbabenko/pre-commit-terraform/issues/248). [Hook notes](#terraform_docs_replace-deprecated)                              | `python3`, `terraform-docs`                                                          |
| `terraform_docs_without_`<br>`aggregate_type_defaults` | Inserts input and output documentation into `README.md` without aggregate type defaults. Hook notes same as for [terraform_docs](#terraform_docs)                                                                                            | `terraform-docs`                                                                     |
| `terraform_fmt`                                        | Reformat all Terraform configuration files to a canonical format. [Hook notes](#terraform_fmt)                                                                                                                                               | -                                                                                    |
| `terraform_providers_lock`                             | Updates provider signatures in [dependency lock files](https://www.terraform.io/docs/cli/commands/providers/lock.html). [Hook notes](#terraform_providers_lock)                                                                              | -                                                                                    |
| `terraform_tflint`                                     | Validates all Terraform configuration files with [TFLint](https://github.com/terraform-linters/tflint). [Available TFLint rules](https://github.com/terraform-linters/tflint/tree/master/docs/rules#rules). [Hook notes](#terraform_tflint). | `tflint`                                                                             |
| `terraform_tfsec`                                      | [TFSec](https://github.com/aquasecurity/tfsec) static analysis of terraform templates to spot potential security issues. **DEPRECATED**, use `terraform_trivy`. [Hook notes](#terraform_tfsec-deprecated)                                    | `tfsec`                                                                              |
| `terraform_trivy`                                      | [Trivy](https://github.com/aquasecurity/trivy) static analysis of terraform templates to spot potential security issues. [Hook notes](#terraform_trivy)                                                                                      | `trivy`                                                                              |
| `terraform_validate`                                   | Validates all Terraform configuration files. [Hook notes](#terraform_validate)                                                                                                                                                               | `jq`, only for `--retry-once-with-cleanup` flag                                      |
| `terragrunt_fmt`                                       | Reformat all [Terragrunt](https://github.com/gruntwork-io/terragrunt) configuration files (`*.hcl`) to a canonical format.                                                                                                                   | `terragrunt`                                                                         |
| `terragrunt_validate`                                  | Validates all [Terragrunt](https://github.com/gruntwork-io/terragrunt) configuration files (`*.hcl`)                                                                                                                                         | `terragrunt`                                                                         |
| `terragrunt_providers_lock`                            | Generates `.terraform.lock.hcl` files using [Terragrunt](https://github.com/gruntwork-io/terragrunt).                                                                                                                   | `terragrunt`                                                                         |
| `terraform_wrapper_module_for_each`                    | Generates Terraform wrappers with `for_each` in module. [Hook notes](#terraform_wrapper_module_for_each)                                                                                                                                     | `hcledit`                                                                            |
| `terrascan`                                            | [terrascan](https://github.com/tenable/terrascan) Detect compliance and security violations. [Hook notes](#terrascan)                                                                                                                        | `terrascan`                                                                          |
| `tfupdate`                                             | [tfupdate](https://github.com/minamijoyo/tfupdate) Update version constraints of Terraform core, providers, and modules. [Hook notes](#tfupdate)                                                                                             | `tfupdate`                                                                           |

Check the [source file](https://github.com/antonbabenko/pre-commit-terraform/blob/master/.pre-commit-hooks.yaml) to know arguments used for each hook.



## Hooks we may use or already in use

terraform_docs - This tool auto-generates readme files containing information on modules, providers and resources that gives users an easy-to-read and central page that can be digested faster than reading the code.

terraform fmt - Terraform format will structure your config files so it presents cleanly.

terraform validate - Terraform validate will check to ensure the configuration is correct based on HCL.

tflint - TFLint will check for errors and encourage best practices.

tfsec - TFSec reviews the config files for any security concerns based on best practices and reports to the user how to change them to resolve the error.


### checkov (deprecated) and terraform_checkov

> `checkov` hook is deprecated, please use `terraform_checkov`.

Note that `terraform_checkov` runs recursively during `-d .` usage. That means, for example, if you change `.tf` file in repo root, all existing `.tf` files in the repo will be checked.

1. You can specify custom arguments. E.g.:

    ```yaml
    - id: terraform_checkov
      args:
        - --args=--quiet
        - --args=--skip-check CKV2_AWS_8
    ```

    Check all available arguments [here](https://www.checkov.io/2.Basics/CLI%20Command%20Reference.html).

2. When you have multiple directories and want to run `terraform_checkov` in all of them and share a single config file - use the `__GIT_WORKING_DIR__` placeholder. It will be replaced by `terraform_checkov` hooks with the Git working directory (repo root) at run time. For example:

    ```yaml
    - id: terraform_checkov
      args:
        - --args=--config-file __GIT_WORKING_DIR__/.checkov.yml
    ```

### infracost_breakdown

`infracost_breakdown` executes `infracost breakdown` command and compare the estimated costs with those specified in the hook-config. `infracost breakdown` parses Terraform HCL code, and calls Infracost Cloud Pricing API (remote version or [self-hosted version](https://www.infracost.io/docs/cloud_pricing_api/self_hosted)).

Unlike most other hooks, this hook triggers once if there are any changed files in the repository.

1. `infracost_breakdown` supports all `infracost breakdown` arguments (run `infracost breakdown --help` to see them). The following example only shows costs:

    ```yaml
    - id: infracost_breakdown
      args:
        - --args=--path=./env/dev
      verbose: true # Always show costs
    ```

    <details><summary>Output</summary>

    ```bash
    Running in "env/dev"

    Summary: {
    "unsupportedResourceCounts": {
        "aws_sns_topic_subscription": 1
      }
    }

    Total Monthly Cost:        86.83 USD
    Total Monthly Cost (diff): 86.83 USD
    ```

    </details>

2. Note that spaces are not allowed in `--args`, so you need to split it, like this:

    ```yaml
    - id: infracost_breakdown
      args:
        - --args=--path=./env/dev
        - --args=--terraform-var-file="terraform.tfvars"
        - --args=--terraform-var-file="../terraform.tfvars"
    ```

3. (Optionally) Define `cost constraints` the hook should evaluate successfully in order to pass:

    ```yaml
    - id: infracost_breakdown
      args:
        - --args=--path=./env/dev
        - --hook-config='.totalHourlyCost|tonumber > 0.1'
        - --hook-config='.totalHourlyCost|tonumber > 1'
        - --hook-config='.projects[].diff.totalMonthlyCost|tonumber != 10000'
        - --hook-config='.currency == "USD"'
    ```

    <details><summary>Output</summary>

    ```bash
    Running in "env/dev"
    Passed: .totalHourlyCost|tonumber > 0.1         0.11894520547945205 >  0.1
    Failed: .totalHourlyCost|tonumber > 1           0.11894520547945205 >  1
    Passed: .projects[].diff.totalMonthlyCost|tonumber !=10000              86.83 != 10000
    Passed: .currency == "USD"              "USD" == "USD"

    Summary: {
    "unsupportedResourceCounts": {
        "aws_sns_topic_subscription": 1
      }
    }

    Total Monthly Cost:        86.83 USD
    Total Monthly Cost (diff): 86.83 USD
    ```

    </details>

    * Only one path per one hook (`- id: infracost_breakdown`) is allowed.
    * Set `verbose: true` to see cost even when the checks are passed.
    * Hook uses `jq` to process the cost estimation report returned by `infracost breakdown` command
    * Expressions defined as `--hook-config` argument should be in a jq-compatible format (e.g. `.totalHourlyCost`, `.totalMonthlyCost`)
    To study json output produced by `infracost`, run the command `infracost breakdown -p PATH_TO_TF_DIR --format json`, and explore it on [jqplay.org](https://jqplay.org/).
    * Supported comparison operators: `<`, `<=`, `==`, `!=`, `>=`, `>`.
    * Most useful paths and checks:
        * `.totalHourlyCost` (same as `.projects[].breakdown.totalHourlyCost`) - show total hourly infra cost
        * `.totalMonthlyCost` (same as `.projects[].breakdown.totalMonthlyCost`) - show total monthly infra cost
        * `.projects[].diff.totalHourlyCost` - show the difference in hourly cost for the existing infra and tf plan
        * `.projects[].diff.totalMonthlyCost` - show the difference in monthly cost for the existing infra and tf plan
        * `.diffTotalHourlyCost` (for Infracost version 0.9.12 or newer) or `[.projects[].diff.totalMonthlyCost | select (.!=null) | tonumber] | add` (for Infracost older than 0.9.12)

4. **Docker usage**. In `docker build` or `docker run` command:
    * You need to provide [Infracost API key](https://www.infracost.io/docs/integrations/environment_variables/#infracost_api_key) via `-e INFRACOST_API_KEY=<your token>`. By default, it is saved in `~/.config/infracost/credentials.yml`
    * Set `-e INFRACOST_SKIP_UPDATE_CHECK=true` to [skip the Infracost update check](https://www.infracost.io/docs/integrations/environment_variables/#infracost_skip_update_check) if you use this hook as part of your CI/CD pipeline.

### terraform_docs

1. `terraform_docs` and `terraform_docs_without_aggregate_type_defaults` will insert/update documentation generated by [terraform-docs](https://github.com/terraform-docs/terraform-docs) framed by markers:

    ```txt
    <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

    <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
    ```

    if they are present in `README.md`.

2. It is possible to pass additional arguments to shell scripts when using `terraform_docs` and `terraform_docs_without_aggregate_type_defaults`.

3. It is possible to automatically:
    * create a documentation file
    * extend existing documentation file by appending markers to the end of the file (see item 1 above)
    * use different filename for the documentation (default is `README.md`)
    * use the same insertion markers as `terraform-docs` by default. It will be default in `v2.0`.
      To migrate to `terraform-docs` insertion markers, run in repo root:

      ```bash
      grep -rl 'BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK' . | xargs sed -i 's/BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK/BEGIN_TF_DOCS/g'
      grep -rl 'END OF PRE-COMMIT-TERRAFORM DOCS HOOK' . | xargs sed -i 's/END OF PRE-COMMIT-TERRAFORM DOCS HOOK/END_TF_DOCS/g'
      ```

    ```yaml
    - id: terraform_docs
      args:
        - --hook-config=--path-to-file=README.md        # Valid UNIX path. I.e. ../TFDOC.md or docs/README.md etc.
        - --hook-config=--add-to-existing-file=true     # Boolean. true or false
        - --hook-config=--create-file-if-not-exist=true # Boolean. true or false
        - --hook-config=--use-standard-markers=true     # Boolean. Defaults in v1.x to false. Set to true for compatibility with terraform-docs
    ```

4. You can provide [any configuration available in `terraform-docs`](https://terraform-docs.io/user-guide/configuration/) as an argument to `terraform_doc` hook, for example:

    ```yaml
    - id: terraform_docs
      args:
        - --args=--config=.terraform-docs.yml
    ```

    > **Warning**
    > Avoid use `recursive.enabled: true` in config file, that can cause unexpected behavior.

5. If you need some exotic settings, it can be done too. I.e. this one generates HCL files:

    ```yaml
    - id: terraform_docs
      args:
        - tfvars hcl --output-file terraform.tfvars.model .
    ```

### terraform_fmt

1. `terraform_fmt` supports custom arguments so you can pass [supported flags](https://www.terraform.io/docs/cli/commands/fmt.html#usage). Eg:

    ```yaml
     - id: terraform_fmt
       args:
         - --args=-no-color
         - --args=-diff
         - --args=-write=false
    ```


### terraform_tflint

1. `terraform_tflint` supports custom arguments so you can enable module inspection, enable / disable rules, etc.

    Example:

    ```yaml
    - id: terraform_tflint
      args:
        - --args=--module
        - --args=--enable-rule=terraform_documented_variables
    ```

2. When you have multiple directories and want to run `tflint` in all of them and share a single config file, it is impractical to hard-code the path to the `.tflint.hcl` file. The solution is to use the `__GIT_WORKING_DIR__` placeholder which will be replaced by `terraform_tflint` hooks with the Git working directory (repo root) at run time. For example:

    ```yaml
    - id: terraform_tflint
      args:
        - --args=--config=__GIT_WORKING_DIR__/.tflint.hcl
    ```

3. By default, pre-commit-terraform performs directory switching into the terraform modules for you. If you want to delgate the directory changing to the binary - this will allow tflint to determine the full paths for error/warning messages, rather than just module relative paths. *Note: this requires `tflint>=0.44.0`.* For example:

    ```yaml
    - id: terraform_tflint
          args:
            - --hook-config=--delegate-chdir
    ```

### terraform_validate

> [!IMPORTANT]
> If you use [`TF_PLUGIN_CACHE_DIR`](https://developer.hashicorp.com/terraform/cli/config/config-file#provider-plugin-cache), we recommend enabling `--hook-config=--retry-once-with-cleanup=true` or disabling parallelism (`--hook-config=--parallelism-limit=1`) to avoid [race conditions when `terraform init` writes to it](https://github.com/hashicorp/terraform/issues/31964).

1. `terraform_validate` supports custom arguments so you can pass supported `-no-color` or `-json` flags:

    ```yaml
     - id: terraform_validate
       args:
         - --args=-json
         - --args=-no-color
    ```

2. `terraform_validate` also supports passing custom arguments to its `terraform init`:

    ```yaml
    - id: terraform_validate
      args:
        - --tf-init-args=-upgrade
        - --tf-init-args=-lockfile=readonly
    ```

3. It may happen that Terraform working directory (`.terraform`) already exists but not in the best condition (eg, not initialized modules, wrong version of Terraform, etc.). To solve this problem, you can delete broken `.terraform` directories in your repository:

    **Option 1**

    ```yaml
    - id: terraform_validate
      args:
        - --hook-config=--retry-once-with-cleanup=true     # Boolean. true or false
    ```

    > **Important**
    > The flag requires additional dependency to be installed: `jq`.

    > **Note**
    > Reinit can be very slow and require downloading data from remote Terraform registries, and not all of that downloaded data or meta-data is currently being cached by Terraform.

    When `--retry-once-with-cleanup=true`, in each failed directory the cached modules and providers from the `.terraform` directory will be deleted, before retrying once more. To avoid unnecessary deletion of this directory, the cleanup and retry will only happen if Terraform produces any of the following error messages:

    * "Missing or corrupted provider plugins"
    * "Module source has changed"
    * "Module version requirements have changed"
    * "Module not installed"
    * "Could not load plugin"

    > **Warning**
    > When using `--retry-once-with-cleanup=true`, problematic `.terraform/modules/` and `.terraform/providers/` directories will be recursively deleted without prompting for consent. Other files and directories will not be affected, such as the `.terraform/environment` file.

    **Option 2**

    An alternative solution is to find and delete all `.terraform` directories in your repository:

    ```bash
    echo "
    function rm_terraform {
        find . \( -iname ".terraform*" ! -iname ".terraform-docs*" \) -print0 | xargs -0 rm -r
    }
    " >>~/.bashrc

    # Reload shell and use `rm_terraform` command in the repo root
    ```

   `terraform_validate` hook will try to reinitialize them before running the `terraform validate` command.

    > **Caution**
    > If you use Terraform workspaces, DO NOT use this option ([details](https://github.com/antonbabenko/pre-commit-terraform/issues/203#issuecomment-918791847)). Consider the first option, or wait for [`force-init`](https://github.com/antonbabenko/pre-commit-terraform/issues/224) option implementation.

1. `terraform_validate` in a repo with Terraform module, written using Terraform 0.15+ and which uses provider `configuration_aliases` ([Provider Aliases Within Modules](https://www.terraform.io/language/modules/develop/providers#provider-aliases-within-modules)), errors out.

   When running the hook against Terraform code where you have provider `configuration_aliases` defined in a `required_providers` configuration block, terraform will throw an error like:

   > Error: Provider configuration not present
   > To work with `<resource>` its original provider configuration at provider `["registry.terraform.io/hashicorp/aws"].<provider_alias>` is required, but it has been removed. This occurs when a provider configuration is removed while
   > objects created by that provider still exist in the state. Re-add the provider configuration to destroy `<resource>`, after which you can remove the provider configuration again.

   This is a [known issue](https://github.com/hashicorp/terraform/issues/28490) with Terraform and how providers are initialized in Terraform 0.15 and later. To work around this you can add an `exclude` parameter to the configuration of `terraform_validate` hook like this:

   ```yaml
   - id: terraform_validate
     exclude: '^[^/]+$'
   ```

   This will exclude the root directory from being processed by this hook. Then add a subdirectory like "examples" or "tests" and put an example implementation in place that defines the providers with the proper aliases, and this will give you validation of your module through the example. If instead you are using this with multiple modules in one repository you'll want to set the path prefix in the regular expression, such as `exclude: modules/offendingmodule/[^/]+$`.

   Alternately, you can use [terraform-config-inspect](https://github.com/hashicorp/terraform-config-inspect) and use a variant of [this script](https://github.com/bendrucker/terraform-configuration-aliases-action/blob/main/providers.sh) to generate a providers file at runtime:

   ```bash
   terraform-config-inspect --json . | jq -r '
     [.required_providers[].aliases]
     | flatten
     | del(.[] | select(. == null))
     | reduce .[] as $entry (
       {};
       .provider[$entry.name] //= [] | .provider[$entry.name] += [{"alias": $entry.alias}]
     )
   ' | tee aliased-providers.tf.json
   ```

   Save it as `.generate-providers.sh` in the root of your repository and add a `pre-commit` hook to run it before all other hooks, like so:

   ```yaml
   - repos:
     - repo: local
       hooks:
         - id: generate-terraform-providers
            name: generate-terraform-providers
            require_serial: true
            entry: .generate-providers.sh
            language: script
            files: \.tf(vars)?$
            pass_filenames: false

     - repo: https://github.com/pre-commit/pre-commit-hooks
   [...]
   ```

    > **Tip**
    > The latter method will leave an "aliased-providers.tf.json" file in your repo. You will either want to automate a way to clean this up or add it to your `.gitignore` or both.

